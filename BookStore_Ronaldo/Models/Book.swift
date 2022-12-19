//
//  Book.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 18/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

struct Book {
    let id: String
    let volumeInfo: VolumeInfo?
    let saleInfo: SaleInfo?
    var isFavorite: Bool = false
}

struct VolumeInfo {
    let title: String?
    let authors: [String]?
    let description: String?
    let imageLinks: ImageLinks?
}

struct ImageLinks {
    let smallThumbnail: String?
    let thumbnail: String?
}

struct SaleInfo {
    let buyLink: String?
}
