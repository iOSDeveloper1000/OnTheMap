//
//  StatusResponse.swift
//  OnTheMap
//
//  Created by Arno Seidel on 23.12.20.
//

import Foundation


struct StatusResponse: Codable {
    
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "status"
        case message = "error"
    }

}
