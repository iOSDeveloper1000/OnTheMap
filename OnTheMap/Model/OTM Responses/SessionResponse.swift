//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Arno Seidel on 16.12.20.
//

import Foundation


struct AccountInfo: Codable {

    let registered: Bool
    let key: String

}

struct SessionInfo: Codable {

    let id: String
    let expiration: String

}

struct SessionResponse: Codable {
    
    let account: AccountInfo?
    let session: SessionInfo
    
}
