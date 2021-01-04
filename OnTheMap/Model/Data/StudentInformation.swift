//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation


struct StudentInformation: Codable {
    
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mapString: String?
    let mediaUrl: String
    let uniqueKey: String
    let objectId: String?
    let createdAt: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case longitude
        case latitude
        case mapString
        case mediaUrl = "mediaURL"
        case uniqueKey
        case objectId
        case createdAt
        case updatedAt
    }

    init(geoData: GeoData, firstName: String, lastName: String, uniqueKey: String, objectId: String? = nil, createdAt: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.longitude = geoData.longitude
        self.latitude = geoData.latitude
        self.mapString = geoData.mapString
        self.mediaUrl = geoData.mediaUrl
        self.uniqueKey = uniqueKey
        self.objectId = objectId
        self.createdAt = createdAt
        self.updatedAt = nil
    }

    init(baseObj: StudentInformation, objectId: String, createdAt: String, updatedAt: String?) {
        self.firstName = baseObj.firstName
        self.lastName = baseObj.lastName
        self.longitude = baseObj.longitude
        self.latitude = baseObj.latitude
        self.mapString = baseObj.mapString
        self.mediaUrl = baseObj.mediaUrl
        self.uniqueKey = baseObj.uniqueKey
        self.objectId = objectId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
