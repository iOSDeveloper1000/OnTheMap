//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation
import UIKit
import CoreLocation


// MARK: FindLocationViewController: UIViewController

class FindLocationViewController: UIViewController {

    var submissionSuccessful: Bool = false

    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide view controllers for posting after successful post
        if submissionSuccessful {
            self.submissionSuccessful = false
            self.dismiss(animated: true, completion: nil)
        }
    }


    // MARK: Actions
    
    @IBAction func findButtonPressed(_ sender: Any) {
        
        self.indicateNetworkActivity(true)
        submissionSuccessful = false
        
        CLGeocoder().geocodeAddressString(self.locationTextfield.text ?? "", in: nil, completionHandler: self.handleGeocodeResponse(placemarks:error:))
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)

    }


    // MARK: Helper and callback methods

    func indicateNetworkActivity(_ waiting: Bool) {
        if waiting {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        locationTextfield.isEnabled = !waiting
        linkTextfield.isEnabled = !waiting
        findButton.isEnabled = !waiting
    }

    func handleGeocodeResponse(placemarks: [CLPlacemark]?, error: Error?) {
        DispatchQueue.main.async {
            self.indicateNetworkActivity(false)
            
            if let placemarks = placemarks,
                let location = placemarks.first?.location {
                // Instantiate and present SubmitLocationViewController
                let submitLocationVC = self.storyboard?.instantiateViewController(identifier: "SubmitLocationViewController") as! SubmitLocationViewController
                submitLocationVC.submissionData = GeoData(mapString: self.locationTextfield?.text ?? "", mediaUrl: self.linkTextfield?.text ?? "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                submitLocationVC.refToFindLocationVC = self
                
                self.navigationController!.pushViewController(submitLocationVC, animated: true)
            } else {
                FailureHandling.showFailure(onTopOf: self, case: .locationNotFound, detailedDescription: error?.localizedDescription ?? "")
            }
        }
    }
}
