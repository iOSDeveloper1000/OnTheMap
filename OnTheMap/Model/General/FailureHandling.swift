//
//  FailureHandling.swift
//  OnTheMap
//
//  Created by Arno Seidel on 02.01.21.
//

import Foundation
import UIKit


class FailureHandling {
    
    enum FailureCases {
        case loginFailed
        case invalidUrl
        case dataDownloadFailed
        case userDownloadFailed
        case locationNotFound
        case submissionFailed
        case internalError
        
        var title: String {
            switch self {
            case .loginFailed:
                return "Login failed"
            case .invalidUrl:
                return "URL invalid"
            case .dataDownloadFailed:
                return "Data download failed"
            case .userDownloadFailed:
                return "User data not found"
            case .locationNotFound:
                return "Location not found"
            case .submissionFailed:
                return "Submission failed"
            case .internalError:
                return "Internal error"
            }
        }
    }
    
    class func showFailure(onTopOf controller: UIViewController, case failure: FailureCases, detailedDescription: String = "Unknown error") {
        let alertVC = UIAlertController(title: failure.title, message: detailedDescription, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        controller.present(alertVC, animated: true, completion: nil)
    }
    
}
