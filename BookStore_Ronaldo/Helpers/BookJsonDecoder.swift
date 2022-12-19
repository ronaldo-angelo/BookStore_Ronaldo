//
//  BookJsonDecoder.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 18/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import Foundation

struct BookJsonDecoder {
    @available(*, unavailable) private init() {}
    
    static func covert(items: NSArray) -> [Book] {
        
        var info: [Book] = []
        
        for item in items {
            
            if let itemDictionary = item as? [String: Any] {
                let id = itemDictionary["id"] as? String
                
                let volumeInfo = itemDictionary["volumeInfo"] as? [String: Any]
                let title = volumeInfo?["title"] as? String
                let authors = volumeInfo?["authors"] as? [String]
                let description = volumeInfo?["description"] as? String
                let imageLinks = volumeInfo?["imageLinks"] as? [String: Any]
                let smallThumbnail = imageLinks?["smallThumbnail"] as? String
                let thumbnail = imageLinks?["thumbnail"] as? String
                
                let saleInfo = itemDictionary["saleInfo"] as? [String: Any]
                let buyLink = saleInfo?["buyLink"] as? String
                
                let links = ImageLinks(smallThumbnail: smallThumbnail, thumbnail: thumbnail)
                let volume = VolumeInfo(title: title, authors: authors, description: description, imageLinks: links)
                let sale = SaleInfo(buyLink: buyLink)
                let bookInfo = Book(id: id!, volumeInfo: volume, saleInfo: sale, isFavorite: false)
                info.append(bookInfo)
            }
            
        }
        
        return info
    }
}
