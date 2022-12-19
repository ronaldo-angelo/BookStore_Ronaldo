//
//  APIServices.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 17/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import UIKit
import Foundation

class APIServices {
    
    // MARK: - Data
    public static let sharedInstance = APIServices()
    private var isFetching = false
    
    // MARK: - Mehtods
    func loadImage(imageURL: String?, completion: @escaping (UIImage?) -> Void) {
        
        guard
            let imageURL = imageURL,
            let url = URL(string: imageURL.replacingOccurrences(of: "http:", with: "https:"))
            else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil)
            }
            else if let data = data {
                if let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType,
                    mimeType.hasPrefix("image"),
                    let image = UIImage(data: data) {
                    completion(image)
                }
            }
            else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func fetchBooks(maxResults: Int = 20, startIndex: Int = 0, completion: @escaping ([Book]?) -> Void) {
        
        if isFetching {
            return
        }
        isFetching = true
        
        var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "ios"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "startIndex", value: "\(startIndex)")
        ]
        
        guard let url = components.url else {
            completion(nil)
            isFetching = false
            return
        }

        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if error != nil {
                completion(nil)
            } else if let data = data {
                let dataValues = try! JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                if let itensArray = dataValues["items"] as? NSArray {
                    let users = BookJsonDecoder.covert(items: itensArray)
                    completion(users)
                }
            } else {
                completion(nil)
            }
            
            self.isFetching = false
        }
        
        task.resume()
    }
    
}
