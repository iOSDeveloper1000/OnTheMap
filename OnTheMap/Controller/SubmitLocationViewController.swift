//
//  SubmitLocationViewController.swift
//  OnTheMap
//
//  Created by Arno Seidel on 22.12.20.
//

import Foundation
import UIKit
import MapKit


class SubmitLocationViewController: UIViewController {

    var submissionData: GeoData!

    var refToFindLocationVC: FindLocationViewController!


    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presentPinOnMap()
    }

    
    @IBAction func submitButtonPressed(_ sender: Any) {

        self.handleSubmission()

    }


    // MARK: Helper and callback methods
    
    func presentPinOnMap() {

        // Initialize location pin
        let annotation = MKPointAnnotation()

        if let data = submissionData {
            annotation.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            annotation.title = data.mapString
            annotation.subtitle = data.mediaUrl

            // Present pin on local map
            detailMap.showAnnotations([annotation], animated: true)
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .internalError, detailedDescription: "No data for submission found.")
        }
    }

    func handleSubmission() {

        self.indicateNetworkActivity(true)

        // Ask user for overwriting existing data in case of successive try
        if NetworkClient.Auth.lastLocation != nil {
            let alertVC = UIAlertController(title: "Do you like to update existing data?", message: "Press UPDATE to overwrite existing location or NEW POST to create a new location.", preferredStyle: .alert)

            alertVC.addAction(UIAlertAction(title: "UPDATE", style: .default, handler: {
                (action) in
                NetworkClient.updateLocation(geoLocation: self.submissionData, completion: self.handlePostResponse(success:errorMessage:))
            }))

            alertVC.addAction(UIAlertAction(title: "NEW POST", style: .default, handler: { (action) in
                NetworkClient.postNewLocation(geoLocation: self.submissionData!, completion: self.handlePostResponse(success:errorMessage:))
            }))

            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alertVC, animated: true, completion: nil)

        } else {
            NetworkClient.postNewLocation(geoLocation: self.submissionData!, completion: self.handlePostResponse(success:errorMessage:))
        }
    }

    func indicateNetworkActivity(_ waiting: Bool) {
        if waiting {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        submitButton.isEnabled = !waiting
    }

    func handlePostResponse(success: Bool, errorMessage: ErrorMessage?) {
        self.indicateNetworkActivity(false)

        if success {
            // Pop to Table/Map ViewController
            self.refToFindLocationVC?.submissionSuccessful = true
            self.navigationController?.popViewController(animated: true)

        } else {
            FailureHandling.showFailure(onTopOf: self, case: .submissionFailed, detailedDescription: errorMessage!)
        }
    }
}
