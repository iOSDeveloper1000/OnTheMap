//
//  GetLocationsResponse.swift
//  OnTheMap
//
//  Created by Arno Seidel on 21.12.20.
//

import Foundation


struct GetLocationsResponse: Codable {
    
    let results: [StudentInformation]
    
    enum CodingKeys: String, CodingKey {
        case results
    }

}
