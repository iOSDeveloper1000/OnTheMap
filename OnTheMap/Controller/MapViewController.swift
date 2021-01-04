//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation
import UIKit
import MapKit


// MARK: MapViewController: UIViewController, MKMapViewDelegate

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Download data only if it is not available
        if !DataBackend.locations.isEmpty {
            self.map.addAnnotations(DataBackend.mapAnnotations)
        } else {
            NetworkClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))
        }
    }


    // MARK: Actions

    @IBAction func refreshButtonPressed(_ sender: Any) {

        NetworkClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))

    }

    @IBAction func addButtonPressed(_ sender: Any) {

        NetworkClient.getUserData(completion: self.handleUserDataResponse(success:errorMessage:))

    }

    @IBAction func logoutButtonPressed(_ sender: Any) {

        // Delete user session
        NetworkClient.deleteSession { (success, error) in
            
            // Clear data in app and destruct backend object
            DataBackend.locations = []

            self.dismiss(animated: true, completion: nil)
        }
    }
    

    // MARK: MKMapView delegate
    //      --> guided by code of PinSample application
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "locationPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView != nil {
            pinView?.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView,
           let url = URL(string: (view.annotation?.subtitle ?? "")!) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if !success {
                    DispatchQueue.main.async {
                        FailureHandling.showFailure(onTopOf: self, case: .invalidUrl, detailedDescription: "Given url cannot be opened.")
                    }
                }
            }
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .invalidUrl, detailedDescription: "Given string has no proper url format.")
        }
    }


    // MARK: Helper and callback methods

    func handleDownloadResponse(success: Bool, errorMessage: ErrorMessage?) {
        if success {
            // Remove former annotations and load freshly downloaded map annotations
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotations(DataBackend.mapAnnotations)
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .dataDownloadFailed, detailedDescription: errorMessage!)
        }
    }

    func handleUserDataResponse(success: Bool, errorMessage: ErrorMessage?) {
        if success {
            self.performSegue(withIdentifier: "userDataSuccessfulFromMap", sender: nil)
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .userDownloadFailed, detailedDescription: errorMessage!)
        }
    }

}
