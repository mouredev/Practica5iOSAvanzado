import UIKit
import CoreData

@objc(Image)
open class Image: _Image {

}

extension Image {
    
    var image: UIImage {
        get {
            // NSData -> UIImage
            return UIImage(data: self.imageData as Data)!
        }
        set {
            // UIImage -> NSData
            self.imageData = UIImageJPEGRepresentation(newValue, 1)! as NSData
        }
    }
    
    convenience init(context: NSManagedObjectContext, image: UIImage, height: CGFloat, width: CGFloat, x: CGFloat, y: CGFloat, rotation: CGFloat? = nil, zoom: CGFloat? = nil, note: Note) {
        
        self.init(context: context)
        
        // Data
        self.image = image
        self.height = NSNumber(value: Float(height))
        self.width = NSNumber(value: Float(width))
        self.x = NSNumber(value: Float(x))
        self.y = NSNumber(value: Float(y))
        if let rotation = rotation {
            self.rotation = NSNumber(value: Float(rotation))
        }
        if let zoom = zoom {
            self.zoom = NSNumber(value: Float(zoom))
        }
        
        // Note
        self.note = note
    }

}
