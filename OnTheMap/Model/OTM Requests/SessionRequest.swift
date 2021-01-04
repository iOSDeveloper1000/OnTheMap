//
//  SessionRequest.swift
//  OnTheMap
//
//  Created by Arno Seidel on 16.12.20.
//

import Foundation


struct UdacityCredentials: Codable {
    
    let username: String
    let password: String
    
}

struct SessionRequest: Codable {
    
    let udacity: UdacityCredentials
    
}
