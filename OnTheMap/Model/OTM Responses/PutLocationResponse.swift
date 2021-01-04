//
//  PutLocationResponse.swift
//  OnTheMap
//
//  Created by Arno Seidel on 23.12.20.
//

import Foundation


struct PutLocationResponse: Codable {

    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case updatedAt
    }

}
