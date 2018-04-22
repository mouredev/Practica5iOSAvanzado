import Foundation
import CoreData

@objc(Note)
open class Note: _Note {

}

extension Note {
    
    convenience init(context: NSManagedObjectContext, notebook: Notebook, title: String, content: String, creationDate: Date, expirationDate: Date? = nil, latitude: Double? = nil, longitude: Double? = nil, images: [Image]? = nil) {
        
        self.init(context: context)
        
        // Notebook
        self.notebook = notebook
        
        // Data
        self.title = title
        self.content = content
        self.creationDate = creationDate
        self.expirationDate = expirationDate
        
        // Map
        if let latitude = latitude, let longitude = longitude {
            self.latitude = NSNumber(value: latitude)
            self.longitude = NSNumber(value: longitude)
        }
        
        // Images
        if let images = images {
            self.addImage(NSSet(array: images))
        }
    }
    
}
