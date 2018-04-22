//
//  BooksTableViewController.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit
import CoreData

protocol BooksTableViewControllerDelegate: class {
    
    func booksTableViewDidSelectNote(notebooks: [Notebook], note: Note)
    
}

final class BooksTableViewController: CoreDataTableViewController {
    
    weak var delegate: BooksTableViewControllerDelegate?
    
    private let dateFormatter = DateFormatter()
    private let request: NSFetchRequest<Notebook>
    
    private var favoriteNotebook: Notebook!
    
    // MARK: - Inicialization
    init(request: NSFetchRequest<Notebook>) {
        self.request = request
        super.init()
        
        title = NSLocalizedString("books.title", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSFetchedResultsController
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Container.default.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = frc
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        // Table
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: BookTableViewCell.CELL_NAME)
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: NoteTableViewCell.CELL_NAME)
        
        // Tool bar
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = EverpobreColors.black
        let barTextButton = UIBarButtonItem(title: NSLocalizedString("books.options", comment: ""), style: .plain, target: nil, action: nil)
        barTextButton.tintColor = .white
        barTextButton.isEnabled = false
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixed.width = 10
        let deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAction))
        deleteBarButton.tintColor = EverpobreColors.secondary
        let newNoteBarButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNoteAction))
        newNoteBarButton.tintColor = EverpobreColors.secondary
        self.setToolbarItems([barTextButton, flexible, deleteBarButton, fixed, newNoteBarButton], animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // HACK: - Para eliminar el text del botón volver
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Private methods
    
    @objc private func deleteAction(sender: AnyObject, forEvent event: UIEvent) {
        
        if event.allTouches?.first?.tapCount == 1 {
            
            // Tap
            tableView.isEditing = !tableView.isEditing
            
        } else {
            
            // Long press
            
            let deleteOptionsAlert = UIAlertController(title: NSLocalizedString("books.noteoptions.title", comment: ""), message: nil, preferredStyle: .actionSheet)
            
            let notebookAction = UIAlertAction(title: NSLocalizedString("books.deleteoptions.deletenotebook", comment: ""), style: .default) { (alertAction) in
                
                if let fc = self.fetchedResultsController {
                    let notebooks = fc.fetchedObjects!
                    let pickerView = SelectNotebookViewController(notebooks: notebooks, delegate: self, action: .deleteNotebook)
                    pickerView.modalPresentationStyle = .overCurrentContext
                    self.present(pickerView, animated: true, completion: nil)
                }
            }
            notebookAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
            
            let noteAction = UIAlertAction(title: NSLocalizedString("books.deleteoptions.deletenote", comment: ""), style: .default) { (alertAction) in
                self.tableView.isEditing = true
            }
            noteAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil)
            cancelAction.setValue(EverpobreColors.primary, forKey: "titleTextColor")
            
            deleteOptionsAlert.addAction(notebookAction)
            deleteOptionsAlert.addAction(noteAction)
            deleteOptionsAlert.addAction(cancelAction)
            
            if let popoverController = deleteOptionsAlert.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
            
            present(deleteOptionsAlert, animated: true, completion: nil)
        }
    }
    
    @objc private func addNoteAction(sender: AnyObject, forEvent event: UIEvent) {
        
        if event.allTouches?.first?.tapCount == 1 {
            
            // Tap
            createNote(notebook: favoriteNotebook)
            
        } else {
            
            // Long press
            let noteOptionsAlert = UIAlertController(title: NSLocalizedString("books.noteoptions.title", comment: ""), message: nil, preferredStyle: .actionSheet)
            
            let noteAction = UIAlertAction(title: NSLocalizedString("books.noteoptions.createnotenotebook", comment: ""), style: .default) { (alertAction) in
                
                if let fc = self.fetchedResultsController {
                    let notebooks = fc.fetchedObjects!
                    let pickerView = SelectNotebookViewController(notebooks: notebooks, delegate: self, action: .addNote)
                    pickerView.view.tag = NotebookPickerAction.addNote.rawValue
                    pickerView.modalPresentationStyle = .overCurrentContext
                    self.present(pickerView, animated: true, completion: nil)
                }
            }
            noteAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
            
            let notebookAction = UIAlertAction(title: NSLocalizedString("books.noteoptions.createnotebook", comment: ""), style: .default) { (alertAction) in
                
                let newNotebookAlert = UIAlertController(title: NSLocalizedString("books.noteoptions.createnotebook", comment: ""), message: NSLocalizedString("books.noteoptions.createnotebook.body", comment: ""), preferredStyle: .alert)
                
                let acceptNewNotebookAction = UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default) { (alertAction) in
                    let textField = newNotebookAlert.textFields![0] as UITextField
                    if !textField.text!.isEmpty {
                        self.createNotebook(title: textField.text!)
                    }
                }
                newNotebookAlert.addTextField { (textField) in
                    textField.placeholder = NSLocalizedString("books.mynotebook", comment: "")
                }
                newNotebookAlert.addAction(acceptNewNotebookAction)
                newNotebookAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                self.present(newNotebookAlert, animated: true, completion: nil)
            }
            notebookAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil)
            cancelAction.setValue(EverpobreColors.primary, forKey: "titleTextColor")
            
            noteOptionsAlert.addAction(noteAction)
            noteOptionsAlert.addAction(notebookAction)
            noteOptionsAlert.addAction(cancelAction)
            
            if let popoverController = noteOptionsAlert.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
            
            present(noteOptionsAlert, animated: true, completion: nil)
        }
    }
    
    private func createNote(notebook: Notebook) {
        
        let context = Container.default.viewContext
        let note = Note(context: context, notebook: notebook, title: NSLocalizedString("note.mynote", comment: ""), content: "", creationDate: Date())
        notebook.addNoteObject(note)
        
        // Se guarda
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // FIXME: Se ha producido un error
                fatalError("Error creando la libreta por defecto")
            }
        }
    }
    
    private func createNotebook(title: String) {
        
        let context = Container.default.viewContext
        let creationDate = Date()
        let notebook = Notebook(context: context, title: title, creationDate: creationDate, favorite: false)
        let note = Note(context: Container.default.viewContext, notebook: notebook, title: NSLocalizedString("note.mynote", comment: ""), content: "", creationDate: creationDate)
        notebook.addNoteObject(note)
        
        // Se guarda
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // FIXME: Se ha producido un error
                fatalError("Error creando la libreta por defecto")
            }
        }
    }
    
    private func deleteNote(note: Note) {
        
        // Se borra la nota
        let context = Container.default.viewContext
        context.delete(note) // La marca para borrar, no funcionaría sin hacer commit de cambios
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // FIXME: Se ha producido un error
                return
            }
        }
    }
    
    private func deleteNotebook(notebook: Notebook) {
        
        // Se borra el notebook
        let context = Container.default.viewContext
        context.delete(notebook)
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // FIXME: Se ha producido un error
                return
            }
        }
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BooksTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = fetchedResultsController, let count = fc.fetchedObjects?.count {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController {
            let notebook = fc.object(at: IndexPath(row: section, section: 0))
            return notebook.notes.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.CELL_NAME) as! BookTableViewCell
        if let notebook = self.fetchedResultsController?.object(at: IndexPath(row: section, section: 0)) {
            
            cell.delegate = self
            cell.notebook = notebook
            
            cell.notebookNameLabel.text = notebook.title?.uppercased() ?? ""
            cell.notebookCreationDateLabel.text = dateFormatter.string(from: notebook.creationDate!)
            let notesNumber = notebook.noteSet().count
            cell.notebookNotesNumberLabel.text = notesNumber > 1
                ? String(format: NSLocalizedString("books.notes.count", comment: ""), String(notesNumber))
                : String(format: NSLocalizedString("books.note.count", comment: ""), String(notesNumber))
            if notebook.favorite!.boolValue {
                cell.favoriteButton.setImage(UIImage(named: "star"), for: .normal)
                favoriteNotebook = notebook
            } else {
                cell.favoriteButton.setImage(UIImage(named: "star_gray"), for: .normal)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.CELL_NAME, for: indexPath) as! NoteTableViewCell
        if let notebook = self.fetchedResultsController?.object(at: IndexPath(row: indexPath.section, section: 0)) {
            let note = notebook.notes[indexPath.row]
            cell.noteNumberLabel.text = "\(indexPath.row + 1)"
            cell.noteTitleLabel.text = "\(note.title)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let notebooks = self.fetchedResultsController?.fetchedObjects {
            let note = notebooks[indexPath.section].notes[indexPath.row]
            
            if(splitViewController!.isCollapsed && UIDevice.current.userInterfaceIdiom == .phone) {
                // Estamos en iPhone
                
                let noteViewController = NoteViewController(notebooks: notebooks, note: note, delegate: self)
                
                // Hacer un push
                navigationController?.pushViewController(noteViewController, animated: true)
            }
            
            self.delegate?.booksTableViewDidSelectNote(notebooks: notebooks, note: note)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            if let notebook = self.fetchedResultsController?.object(at: IndexPath(row: indexPath.section, section: 0)) {
                let note = notebook.notes[indexPath.row]
                deleteNote(note: note)
            }
        }
    }
    
}

// MARK: - NoteViewControllerDelegate
extension BooksTableViewController: NoteViewControllerDelegate {
    
    func noteViewDidSave() {
        tableView.reloadData()
    }
    
}

// MARK: - BookTableViewCellDelegate
extension BooksTableViewController: BookTableViewCellDelegate {
    
    func bookTableViewCellFavoriteDidChange(notebook: Notebook) {
        favoriteNotebook.favorite = false
        favoriteNotebook = notebook
        
        // Se guarda
        if Container.default.viewContext.hasChanges {
            do {
                try Container.default.viewContext.save()
                view.endEditing(true)
            } catch {
                // FIXME: Se ha producido un error
                return
            }
        }
    }
    
}

// MARK: - SelectNotebookViewController
extension BooksTableViewController: SelectNotebookViewControllerDelegate {
    
    func selectNotebookDidSelected(notebook: Notebook, action: NotebookPickerAction, exclude: Notebook?) {
        switch action {
        case .addNote:
            self.createNote(notebook: notebook)
            break
        case .deleteNotebook:
            if let fc = self.fetchedResultsController {
                let notebooks = fc.fetchedObjects!
                if notebooks.count == 1 || notebook.favorite!.boolValue {
                    let alert = UIAlertController(title: NSLocalizedString("books.alert.deleteerror.title", comment: ""), message: NSLocalizedString("books.alert.deleteerror.body", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                } else {
                    // Alert que nos pregunta si queremos eliminar las notas o añadirlas a otro notebook existente
                    let alert = UIAlertController(title: NSLocalizedString("books.deleteoptions.deletenotebook", comment: ""), message: NSLocalizedString("books.noteoptions.title", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("books.alert.movenotes", comment: ""), style: .default, handler: { (action) in
                        if let fc = self.fetchedResultsController {
                            let notebooks = fc.fetchedObjects!
                            let pickerView = SelectNotebookViewController(notebooks: notebooks, delegate: self, action: .moveNotes, exclude: notebook)
                            pickerView.modalPresentationStyle = .overCurrentContext
                            self.present(pickerView, animated: true, completion: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("books.alert.deleteall", comment: ""), style: .default, handler: { (action) in
                        self.deleteNotebook(notebook: notebook)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            break
        case .moveNotes:
            if let exclude = exclude {
                notebook.addNote(exclude.note)
                deleteNotebook(notebook: exclude)
            }
            break
        case .moveNote:
            // Not supported
            break
        }
    }
    
}
