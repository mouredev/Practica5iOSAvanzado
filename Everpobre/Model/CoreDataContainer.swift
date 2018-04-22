//
//  CoreDataContainer.swift
//  Everpobre
//
//  Created by Brais Moure on 17/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import Foundation
import CoreData

struct Container {
    
    // Default es una palabra reservada, si la ponemos entre `` podremos usarla. Un singleton por defecto es lazy.
    //static let `default` = NSPersistentContainer(name: "Everpobre")
    static let `default` : NSPersistentContainer = {
        
        // Custom implementation
        let persistentContainer = NSPersistentContainer(name: "Everpobre")
        persistentContainer.loadPersistentStores(completionHandler: { (description, error) in
            
            if let error = error {
                // TODO: Loggear esto en Crashlytics o semejante.
                fatalError("Error: loadPersistentStores")
            }
        })
        return persistentContainer
    }()
    
        
    
}
