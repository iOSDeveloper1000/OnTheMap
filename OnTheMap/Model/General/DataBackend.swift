//
//  DataBackend.swift
//  OnTheMap
//
//  Created by Arno Seidel on 02.01.21.
//

import Foundation
import UIKit
import MapKit


class DataBackend {
    
    static var locations = [StudentInformation]()

    static var mapAnnotations: [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for location in DataBackend.locations {
            // Initialize MKPointAnnotation object for each student location
            let latitude = CLLocationDegrees(location.latitude)
            let longitude = CLLocationDegrees(location.longitude)

            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaUrl
            
            annotations.append(annotation)
        }
        
        return annotations
    }

    static var ownLocations: [StudentInformation] {
        if NetworkClient.Auth.userKey == "" {
            return []
        } else {
            return DataBackend.locations.filter { (info) -> Bool in
                return info.uniqueKey == NetworkClient.Auth.userKey
            }
        }
    }

}
