//
//  PostLocationResponse.swift
//  OnTheMap
//
//  Created by Arno Seidel on 22.12.20.
//

import Foundation


struct PostLocationResponse: Codable {

    let objectId: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case objectId
        case createdAt
    }

}
