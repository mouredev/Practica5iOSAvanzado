// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Note.swift instead.

import Foundation
import CoreData

public enum NoteAttributes: String {
    case content = "content"
    case creationDate = "creationDate"
    case expirationDate = "expirationDate"
    case latitude = "latitude"
    case longitude = "longitude"
    case title = "title"
}

public enum NoteRelationships: String {
    case image = "image"
    case notebook = "notebook"
}

open class _Note: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Note"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Note.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var content: String

    @NSManaged open
    var creationDate: Date

    @NSManaged open
    var expirationDate: Date?

    @NSManaged open
    var latitude: NSNumber?

    @NSManaged open
    var longitude: NSNumber?

    @NSManaged open
    var title: String

    // MARK: - Relationships

    @NSManaged open
    var image: NSSet

    open func imageSet() -> NSMutableSet {
        return self.image.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var notebook: Notebook

}

extension _Note {

    open func addImage(_ objects: NSSet) {
        let mutable = self.image.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.image = mutable.copy() as! NSSet
    }

    open func removeImage(_ objects: NSSet) {
        let mutable = self.image.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.image = mutable.copy() as! NSSet
    }

    open func addImageObject(_ value: Image) {
        let mutable = self.image.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.image = mutable.copy() as! NSSet
    }

    open func removeImageObject(_ value: Image) {
        let mutable = self.image.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.image = mutable.copy() as! NSSet
    }

}

