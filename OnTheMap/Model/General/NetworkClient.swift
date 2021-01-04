//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation


typealias ErrorMessage = String

class NetworkClient {
    
    struct Auth {
        
        static var sessionId = ""
        static var userKey = ""
        
        static var firstName = ""
        static var lastName = ""
        
        static var lastLocation: StudentInformation? = nil

    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
        static var limit = 100
        
        case session
        case userData
        case getLocations
        case postLocation
        case updateLocation(String)
        
        var stringValue: String {
            switch self {
            case .session:
                return Endpoints.base + "/session"
            case .userData:
                return Endpoints.base + "/users/" + Auth.userKey
            case .getLocations:
                return Endpoints.base + "/StudentLocation?limit=\(Endpoints.limit)&order=-updatedAt"
            case .postLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation(let objectId):
                return Endpoints.base + "/StudentLocation/" + objectId
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }


    class func taskForGETRequest<ResponseType:Decodable>(url: URL, isUdacityAPI: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, StatusResponse?, Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }

            let decoder = JSONDecoder()
            let newData = isUdacityAPI ? data.subdata(in: 5..<data.count) : data

            do {
                let responseBody = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseBody, nil, nil)
                }
            } catch {
                do { // catch HTTP Error response
                    let responseBody = try decoder.decode(StatusResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, responseBody, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    class func taskForPOSTRequest<RequestType:Encodable, ResponseType:Decodable>(url: URL, isUdacityAPI: Bool, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, StatusResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if isUdacityAPI {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            let newData = isUdacityAPI ? data.subdata(in: 5..<data.count) : data
            
            do {
                let responseBody = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseBody, nil, nil)
                }
            } catch {
                do { // catch HTTP Error response
                    let responseBody = try decoder.decode(StatusResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, responseBody, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func postUdacitySession(username: String, password: String, completion: @escaping (Bool, ErrorMessage?) -> Void) {
        let requestObj = SessionRequest(udacity: UdacityCredentials(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.session.url, isUdacityAPI: true, body: requestObj, responseType: SessionResponse.self) { (responseObj, status, error) in
            if error == nil {
                Auth.sessionId = responseObj?.session.id ?? ""
                Auth.userKey = responseObj?.account?.key ?? ""
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Reset user authentification data
            Auth.sessionId = ""
            Auth.userKey = ""
            Auth.firstName = ""
            Auth.lastName = ""
            Auth.lastLocation = nil
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            let newData = data.subdata(in: 5..<data.count)
            
            do {
                _ = try decoder.decode(SessionResponse.self, from: newData)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, ErrorMessage?) -> Void) {
        taskForGETRequest(url: Endpoints.userData.url, isUdacityAPI: true, responseType: UserData.self) { (responseObj, status, error) in
            if error == nil {
                Auth.firstName = responseObj?.firstName ?? ""
                Auth.lastName = responseObj?.lastName ?? ""
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func getLocations(completion: @escaping (Bool, ErrorMessage?) -> Void) {
        taskForGETRequest(url: Endpoints.getLocations.url, isUdacityAPI: false, responseType: GetLocationsResponse.self) { (responseObj, status, error) in
            if error == nil {
                DataBackend.locations = responseObj?.results ?? []
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func postNewLocation(geoLocation: GeoData, completion: @escaping (Bool, ErrorMessage?) -> Void) {
        let requestBody = StudentInformation(geoData: geoLocation, firstName: Auth.firstName, lastName: Auth.lastName, uniqueKey: Auth.userKey)
        taskForPOSTRequest(url: Endpoints.postLocation.url, isUdacityAPI: false, body: requestBody, responseType: PostLocationResponse.self) { (responseObj, status, error) in
            if error == nil {
                Auth.lastLocation = StudentInformation(baseObj: requestBody, objectId: responseObj?.objectId ?? "", createdAt: responseObj?.createdAt ?? "", updatedAt: nil)
                completion(true, nil)
            } else {
                if let status = status {
                    completion(false, status.message)
                } else {
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    class func updateLocation(geoLocation: GeoData, completion: @escaping (Bool, ErrorMessage?) -> Void) {
        var request = URLRequest(url: Endpoints.updateLocation(Auth.lastLocation!.objectId!).url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestObj = StudentInformation(geoData: geoLocation, firstName: Auth.firstName, lastName: Auth.lastName, uniqueKey: Auth.userKey, objectId: Auth.lastLocation!.objectId!, createdAt: Auth.lastLocation!.createdAt!)
        request.httpBody = try! JSONEncoder().encode(requestObj)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error?.localizedDescription)
                }
                return
            }

            let decoder = JSONDecoder()

            do {
                let responseBody = try decoder.decode(PutLocationResponse.self, from: data)
                Auth.lastLocation = requestObj
                Auth.lastLocation?.updatedAt = responseBody.updatedAt
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do { // catch HTTP Error response
                    let responseBody = try decoder.decode(StatusResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(false, responseBody.message)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
}
