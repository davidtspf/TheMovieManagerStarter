//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

// code for working with the API

import Foundation

class TMDBClient {
    
    // my API key off of https://www.themoviedb.org/settings/api
    static let apiKey = "b2c47a5c90915e435e6edeff43d5fd95"
    
    // authentication
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    // in order to make requests
    enum Endpoints {
        // endpoints constructed with the base URL
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        // get the watchlist
        case getWatchlist
        case getRequestToken
        
        // this associated value generates the full path
        var stringValue: String {
            switch self {
            case .getWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken:
                return Endpoints.base + "/autentication/token/new" + Endpoints.apiKeyParam
            }
        }
        
        // converts the string property (stringValue) into a URL
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // method to return the watchlist; the typepath is an array of type Movie
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        // get an http get request
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            
            // parse the json, aka completion handler
            do {
                // the json is parsed into MovieResults
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        // get an http get request
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) {
            data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            
            // parse the json, aka completion handler
            do {
                // the json is parsed into MovieResults
                let responseObject = try decoder.decode(ResponseTokenResponse.self, from: data)
                Auth.requestToken = responseObject.requestToken
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }
    
}
