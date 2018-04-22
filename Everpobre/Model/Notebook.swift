import Foundation
import CoreData

@objc(Notebook)
open class Notebook: _Notebook {

}

extension Notebook {

    convenience init(context: NSManagedObjectContext, title: String, creationDate: Date, favorite: Bool, notes: [Note]? = nil) {
        
        self.init(context: context)
        
        // Data
        self.title = title
        self.creationDate = creationDate
        self.favorite = favorite ? 1 : 0
        
        // Notes
        if let notes = notes {
            self.addNote(NSSet(array: notes))
        }
    }
    
    var notes: [Note] {
        get {
            var notes = self.note.allObjects as! [Note]
            notes.sort { (n1, n2) -> Bool in
                return n1.creationDate < n2.creationDate
            }
            return notes
        }
    }

}
