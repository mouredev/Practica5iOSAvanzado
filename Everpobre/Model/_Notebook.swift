// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notebook.swift instead.

import Foundation
import CoreData

public enum NotebookAttributes: String {
    case creationDate = "creationDate"
    case favorite = "favorite"
    case title = "title"
}

public enum NotebookRelationships: String {
    case note = "note"
}

open class _Notebook: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Notebook"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Notebook.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var creationDate: Date?

    @NSManaged open
    var favorite: NSNumber?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var note: NSSet

    open func noteSet() -> NSMutableSet {
        return self.note.mutableCopy() as! NSMutableSet
    }

}

extension _Notebook {

    open func addNote(_ objects: NSSet) {
        let mutable = self.note.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.note = mutable.copy() as! NSSet
    }

    open func removeNote(_ objects: NSSet) {
        let mutable = self.note.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.note = mutable.copy() as! NSSet
    }

    open func addNoteObject(_ value: Note) {
        let mutable = self.note.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.note = mutable.copy() as! NSSet
    }

    open func removeNoteObject(_ value: Note) {
        let mutable = self.note.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.note = mutable.copy() as! NSSet
    }

}

