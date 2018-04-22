//
//  CoreDataTableViewController.swift
//  Everpobre
//
//  Created by Brais Moure on 19/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController {
    
    var fetchedResultsController : NSFetchedResultsController<Notebook>?{
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// MARK: - Subclass responsability
extension CoreDataTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Must be implemented by subclass")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fatalError("Must be implemented by subclass")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Must be implemented by subclass")
    }
    
}

// MARK: - Fetches
extension CoreDataTableViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension CoreDataTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}
