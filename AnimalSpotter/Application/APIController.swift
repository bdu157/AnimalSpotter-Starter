//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}



class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    // create function for sign up
    func signUp(with user: User, completion:@escaping (Error?) -> ()) {
        //create endpoint URL
        let signUpURL = self.baseUrl.appendingPathComponent("users/signup")
    
        // set up request
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")   //overwrite value
        
        //initialize JSON Encoder
        let jsonEncoder = JSONEncoder()
        
        //Encode the data, catch errors
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        // create data task, handle bad response and errors
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Error?)->()) {
        let loginURL = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user objects: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                NSLog("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    // create function for fetching all animal names
    func fetchAllAnimalNames(completion:@escaping (Result<[String], NetworkError>) -> Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAuth))
            return
        }
        let allAnimalsURL = self.baseUrl.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    
    // create function for fetching details for individual animal
    func fetchDetailsForAnimal(for animalName: String, completion:@escaping (Result<Animal, NetworkError>) -> Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAuth))
            return
        }
        let animalURL = self.baseUrl.appendingPathComponent("animals/\(animalName)")
        
        var request = URLRequest(url: animalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .secondsSince1970
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    
    // create function to fetch image
    func fetchImage(at urlString: String, completion:@escaping (Result<UIImage, NetworkError>)->Void) {
        let imageURL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let image = UIImage(data: data)!
            completion(.success(image))
        }.resume()
    }
}




/*
 
 setValue sets the initial value of the header. addValue adds upon the initial value from what I am understanding.. So in the bearer case we are adding that to the original value that was set in the header letting it know that we are authenticated..
 
 From SL - Moin Uddin to Everyone: (07:17 PM)
 
 GET /presence/alice HTTP/1.1  Host: server.example.com Authorization: Bearer mF_9.B5f-4.1JqM, Basic YXNkZnNhZGZzYWRmOlZLdDVOMVhk
 The comma in the above example is appending
 in authorization. So this is addValue()
 
 
 
 */
