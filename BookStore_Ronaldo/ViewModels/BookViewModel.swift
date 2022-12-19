//
//  BookViewModel.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 18/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import Foundation
import UIKit

class BookViewModel: NSObject {
    
    // MARK: - Data
    private let maxResults = 12
    private var startIndex: Int = 0
    private var books:[Book] = []
    private var filterByFavorites = false
    
    // MARK: - Fetch data
    func fetchData(completion: ((Bool) -> Void)? = nil) {
        
        if !filterByFavorites {
            print("Fetching data for \(startIndex) ...")
            APIServices.sharedInstance.fetchBooks(maxResults: maxResults, startIndex: startIndex) { [weak self] result in
                if let items = result {
                    self?.books.append(contentsOf: items)
                    self?.fetchFavorites()
                    self?.startIndex += 10
                    completion?(true)
                }
                else {
                    completion?(false)
                }
            }
        }
        
    }
    
    // MARK: - Table View
    func numberOfRowsInSection(section: Int) -> Int {
        
        switch section {
        case 0:
            var count = books.count
            if filterByFavorites {
                count = books.filter({ $0.isFavorite == true }).count
            }
            return count
            
        default:
            return books.count >= maxResults ? 1 : 0
        }
        
    }
    
    func infoForRowAt(indexPath: IndexPath) -> VolumeInfo? {
        
        guard indexPath.row < books.count
            else { return nil }
        
        switch indexPath.section {
        case 0:
            var info: VolumeInfo?
            if filterByFavorites {
                
                let filtered = books.filter({ $0.isFavorite == filterByFavorites })
                
                guard filtered.count > 0,
                    indexPath.row < filtered.count
                    else { return nil }
                
                info = filtered[indexPath.row].volumeInfo
                
            }
            else {
                info = books[indexPath.row].volumeInfo
            }
            return info
            
        default:
            return nil
        }
        
    }
    
    func updateBottomLoader(indexPath: IndexPath, completion: @escaping () -> Void) {
        guard !books.isEmpty else { return }
        
        if indexPath.section == 1 {
            fetchData { success in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func object(at indexPath: IndexPath) -> Book {
        return books[indexPath.row]
    }
    
    // MARK: - Core Data
    func favoriteBook(book: Book) -> Bool {
        
        if let info = DataManager.sharedInstance.retrieveBook(by: book.id) {
            let isFavorite = info.value(forKey: "isFavorite") as? Bool
            return DataManager.sharedInstance.updateBook(id: book.id, isFavorite: !isFavorite!)
        }
        else {
            return DataManager.sharedInstance.insertBook(id: book.id, isFavorite: true)
        }
        
    }
    
    func filterByFavorites(completion: @escaping () -> Void) -> Bool {
        filterByFavorites = !filterByFavorites
        completion()
        return filterByFavorites
    }
    
    func fetchFavorites() {
        
        if let favorites = DataManager.sharedInstance.retrieveFavoriteBooks() {
            for item in favorites {
                
                if let row = books.index(where: { $0.id == item.value(forKey: "id") as? String }) {
                    books[row].isFavorite = (item.value(forKey: "isFavorite") as? Bool)!
                    
                }
                
            }
        }
        
    }
    
}
