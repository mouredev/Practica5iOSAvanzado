//
//  AppDelegate.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Core Data
    private let context = Container.default.viewContext

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Default appearance
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: EverpobreColors.clearGray, NSAttributedStringKey.font: UIFont.init(name: "Lobster-Regular", size: 25.0)!]
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = EverpobreColors.black
        UINavigationBar.appearance().tintColor = EverpobreColors.clearGray
        
        // Repository

        let notebooksRequest = Notebook.fetchRequest() as! NSFetchRequest<Notebook>
        notebooksRequest.fetchBatchSize = 100
        notebooksRequest.sortDescriptors = [NSSortDescriptor(key: NotebookAttributes.favorite.rawValue, ascending: false), NSSortDescriptor(key: NotebookAttributes.title.rawValue, ascending: true)]

        guard let notebooks = try? context.fetch(notebooksRequest) else {
            // FIXME: Se ha producido un error
            fatalError("Error buscando libretas")
        }
        
        var userNotebooks = notebooks
        
        if notebooks.isEmpty {
            
            // Libreta por defecto
            let creationDate = Date()
            let notebook = Notebook(context: context, title: NSLocalizedString("books.mynotebook", comment: ""), creationDate: creationDate, favorite: true)
            let note = Note(context: context, notebook: notebook, title: NSLocalizedString("note.mynote", comment: ""), content: "", creationDate: creationDate)
            notebook.addNoteObject(note)
            
            // Se guarda
            if context.hasChanges {
                do {
                    try context.save()
                    userNotebooks.append(notebook)
                } catch {
                    // FIXME: Se ha producido un error
                    fatalError("Error creando la libreta por defecto")
                }
            }
        }
        
        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = EverpobreColors.primary
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        // Controllers
        let splitViewController = UISplitViewController()
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = self
        let note = userNotebooks.first!.note.allObjects.first! as! Note        
        let booksViewController = BooksTableViewController(request: notebooksRequest)
        let noteViewController = NoteViewController(notebooks: userNotebooks, note: note, delegate: booksViewController)
        if(!splitViewController.isCollapsed && UIDevice.current.userInterfaceIdiom != .phone) {
            booksViewController.delegate = noteViewController
        }
        splitViewController.viewControllers = [booksViewController.wrappedInNavigation(), noteViewController.wrappedInNavigation()]
        window?.rootViewController = splitViewController
        
        return true
    }

}

// MARK: - UISplitViewControllerDelegate
extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

