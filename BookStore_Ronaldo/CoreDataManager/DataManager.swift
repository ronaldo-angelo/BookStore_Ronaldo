//
//  DataManager.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 19/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import CoreData
import UIKit

class DataManager {
    
    // MARK: - Data
    public static let sharedInstance = DataManager()
    
    private lazy var bookEntity: NSEntityDescription = {
        let managedContext = self.getContext()
        return NSEntityDescription.entity(forEntityName: "BookEntity", in: managedContext!)!
    }()
    
    // MARK: - Context
    private func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Data management methods
    func retrieveFavoriteBooks() -> [NSManagedObject]? {
        guard let managedContext = getContext() else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookEntity")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if result.count > 0 {
                
                let favorites = result.filter { $0.value(forKey: "isFavorite") as? Bool == true }
                if favorites.count > 0 {
                    return favorites
                }
                
            }
        } catch let error as NSError {
            print("Retrieving failed. \(error)")
        }
        return nil
    }

    func insertBook(id: String, isFavorite: Bool? = false) -> Bool {
        guard let managedContext = getContext() else { return false }
        let info = NSManagedObject(entity: bookEntity, insertInto: managedContext)
        info.setValue(id, forKey: "id")
        info.setValue(isFavorite, forKey: "isFavorite")
        
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Failed to save: \(error)")
        }
        
        return false
    }
    
    func retrieveBook(by id: String) -> NSManagedObject? {
        guard let managedContext = getContext() else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookEntity")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if result.count > 0 {
                
                for (index, item) in result.enumerated() {
                    if item.value(forKey: "id") as? String == id {
                        return result[index]
                    }
                }
                
            }
        } catch let error as NSError {
            print("Retrieving failed. \(error)")
        }
        return nil
    }
    
    func updateBook(id: String, isFavorite: Bool) -> Bool {
        guard let managedContext = getContext() else { return false }
        
        do {
            
            let info = retrieveBook(by: id)
            info?.setValue(id, forKey: "id")
            info?.setValue(isFavorite, forKey: "isFavorite")
            try managedContext.save()
            return true
            
        } catch let error as NSError {
            print("Failed to save: \(error)")
        }

        return false
    }

}
