//
//  NoteViewController.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import UserNotifications

protocol NoteViewControllerDelegate: class {
    
    func noteViewDidSave()
    
}

final class NoteViewController: UIViewController {
    
    @IBOutlet weak var notebookNameButton: UIButton!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var creationDateTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint! // 150
    
    private var delegate: NoteViewControllerDelegate?
    private var expirationDate: Date?
    private var datePicker: UIDatePicker!
    private let dateFormatter = DateFormatter()
    private let imageMaxHeight: CGFloat = 150
    private var minHeight: CGFloat!
    private var maxHeight: CGFloat!
    
    private let rotationKeyPath = "layer.presentationLayer.transform.rotation.z"
    
    private struct ImageContent {
        var imageView: UIImageView!
        var image: Image?
    }
    
    // User location
    private lazy var locationManager: CLLocationManager! = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        return manager
    }()
    
    // Core data
    private var notebooks: [Notebook]
    private var note: Note?
    private var noteImages: [ImageContent] = []
    
    // MARK: - Inicialization
    init(notebooks: [Notebook], note: Note, delegate: NoteViewControllerDelegate?) {
        self.notebooks = notebooks
        self.note = note
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        title = note.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        minHeight = imageMaxHeight * 0.7
        maxHeight = imageMaxHeight * 1.3
        noteTitleTextField.tintColor = EverpobreColors.primary
        noteTextView.tintColor = EverpobreColors.secondary
        noteTextView.layer.cornerRadius = 3
        noteTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        noteTextView.clipsToBounds = true
        noteTextView.isScrollEnabled = false
        noteTextView.delegate = self
        mapView.layer.cornerRadius = 3
        mapView.clipsToBounds = true
        mapView.isHidden = true
        mapViewHeightConstraint.constant = 0
        expirationDateTextField.delegate = self
        notebookNameButton.layer.cornerRadius = 5
        notebookNameButton.clipsToBounds = true
        
        // Save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItem?.tintColor = EverpobreColors.secondary
        
        // Date picker
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: view.frame.width, height: 216))
        datePicker.setValue(EverpobreColors.black, forKeyPath: "textColor")
        datePicker.backgroundColor = EverpobreColors.clearGray
        datePicker.minimumDate = Date() //.addingTimeInterval(60 * 60 * 24) // 1 Día
        datePicker.date = Date()
        expirationDateTextField.inputView = datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = EverpobreColors.primary
        toolBar.barTintColor = EverpobreColors.black
        toolBar.sizeToFit()
        
        // Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("accept", comment: ""), style: .plain, target: self, action: #selector(doneDateAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(cancelDateAction))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        expirationDateTextField.inputAccessoryView = toolBar
        
        // Tool bar
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = EverpobreColors.black
        let barTextButton = UIBarButtonItem(title: NSLocalizedString("note.moreoptions", comment: ""), style: .plain, target: nil, action: nil)
        barTextButton.tintColor = .white
        barTextButton.isEnabled = false
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixed.width = 10
        let mapBarButton = UIBarButtonItem(image: UIImage(named: "map"), style: .plain, target: self, action: #selector(addLocationAction))
        mapBarButton.tintColor = EverpobreColors.secondary
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhotoAction))
        photoBarButton.tintColor = EverpobreColors.secondary
        setToolbarItems([barTextButton, flexible, mapBarButton, fixed, photoBarButton], animated: false)
        
        // Data
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        setData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let mapHeight = mapViewHeightConstraint, mapHeight.constant != 0 {
            locationManager?.stopUpdatingLocation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        for noteImage in noteImages {
            fixNoteTextPosition(image: noteImage.imageView)
        }
    }
    
    // MARK: - Private methods
    
    private func setData() {
        
        creationDateTextField.isUserInteractionEnabled = false
        if let note = note {
            notebookNameButton.setTitle(note.notebook.title?.uppercased() ?? "", for: .normal)
            noteTitleTextField.text = note.title
            noteTextView.text = note.content
            creationDateTextField.text = dateFormatter.string(from: note.creationDate)
            if let expirationDate = note.expirationDate {
                if expirationDate <= Date() {
                    note.expirationDate = nil
                    expirationDateTextField.text = ""
                } else {
                    expirationDateTextField.text = dateFormatter.string(from: expirationDate)
                }
            }
            if let latitude = note.latitude, let longitude = note.longitude, latitude != 0, longitude != 0 {
                showMap(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue))
            } else {
                hideMap()
            }
            if let images = note.image.allObjects as? [Image] {
                for image in images {
                    let width = image.width as! CGFloat
                    let height = image.height as! CGFloat
                    let x = image.x as! CGFloat
                    let y = image.y as! CGFloat
                    let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
                    if let rotation = image.rotation {
                        imageView.transform = CGAffineTransform(rotationAngle: rotation as! CGFloat)
                    }                    
                    addImageViewToNote(imageView: imageView, image: image.image, imageData: image)
                }
            }
        } else {
            creationDateTextField.text = dateFormatter.string(from: Date())
        }
    }
    
    @IBAction func notebookNameButtonAction(_ sender: Any) {
        
        let pickerView = SelectNotebookViewController(notebooks: notebooks, delegate: self, action: .moveNote)
        pickerView.modalPresentationStyle = .overCurrentContext
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @objc private func addPhotoAction(sender: AnyObject) {
        
        let photoOptionsAlert = UIAlertController(title: NSLocalizedString("note.addphoto", comment: ""), message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        cameraAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("photolibrary", comment: ""), style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        photoLibraryAction.setValue(EverpobreColors.gray, forKey: "titleTextColor")
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil)
        cancelAction.setValue(EverpobreColors.primary, forKey: "titleTextColor")
        
        photoOptionsAlert.addAction(cameraAction)
        photoOptionsAlert.addAction(photoLibraryAction)
        photoOptionsAlert.addAction(cancelAction)
        
        if let popoverController = photoOptionsAlert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(photoOptionsAlert, animated: true, completion: nil)
    }
    
    @objc private  func addLocationAction() {
        
        if mapView.isHidden {
            locationManager?.startUpdatingLocation()
        } else {
            hideMap()
        }
    }
    
    private func showMap(coordinate: CLLocationCoordinate2D) {
        
        mapView.isHidden = false
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        
        let addressAnnotation = MKPointAnnotation()
        addressAnnotation.coordinate = coordinate
        mapView.addAnnotation(addressAnnotation)
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapViewHeightConstraint.constant = 150
    }
    
    private func hideMap() {
        
        mapView.isHidden = true
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        mapViewHeightConstraint.constant = 0
    }
    
    private func fixNoteTextPosition(image: UIImageView) {
        
        var rect = scrollView.convert(image.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
    }
    
    @objc private func closeKeyboard() {
        
        view.endEditing(true)
    }
    
    @objc private func doneDateAction() {
        expirationDateTextField.resignFirstResponder()
        expirationDateTextField.text = dateFormatter.string(from: datePicker.date)
        expirationDate = datePicker.date
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            if !granted {
                print("Error activando notificaciones")
            } else {
                center.getNotificationSettings { (settings) in
                    if settings.authorizationStatus == .authorized {
                        self.addNotification(date: self.expirationDate!)
                    }
                }
            }
        }
    }
    
    private func addNotification(date: Date) {

        let content = UNMutableNotificationContent()
        content.title = String(format: NSLocalizedString("notification.title", comment: ""), note!.title)
        content.body = String(format: NSLocalizedString("notification.body", comment: ""), dateFormatter.string(from: date))
        content.sound = UNNotificationSound.default()
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "EverpobreNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let _ = error {
                print("Error creando la notificación local")
            }
        })
    }
    
    @objc private func cancelDateAction() {
        expirationDateTextField.resignFirstResponder()
    }
    
    @objc private func saveAction() {
        
        // La nota debe tener título y contenido como mínimo
        if noteTitleTextField.text!.isEmpty || noteTextView.text.isEmpty {
            
            let saveNoteAlert = UIAlertController(title: NSLocalizedString("note.alert.saveerror.title", comment: ""), message: NSLocalizedString("note.alert.saveerror.body", comment: ""), preferredStyle: .alert)
            saveNoteAlert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .cancel, handler: nil))
            present(saveNoteAlert, animated: true, completion: nil)
            
        } else {
            
            if let note = note {
                // Se actualiza la nota
                note.title = noteTitleTextField.text!
                note.content = noteTextView.text
                if let expirationDate = expirationDate {
                    note.expirationDate = expirationDate
                }
                
                if let map = mapView, !map.annotations.isEmpty, let annotation = map.annotations.first {
                    note.latitude = NSNumber(value: annotation.coordinate.latitude)
                    note.longitude = NSNumber(value: annotation.coordinate.longitude)
                } else {
                    note.latitude = nil
                    note.longitude = nil
                }
                
                var newImages: [Image] = []
                for (index, noteImage) in noteImages.enumerated() {
                    if let image = noteImage.image {
                        // La imagen ya existe
                        image.height = NSNumber(value: Float(noteImage.imageView.frame.height))
                        image.width = NSNumber(value: Float(noteImage.imageView.frame.width))
                        image.x = NSNumber(value: Float(noteImage.imageView.frame.origin.x))
                        image.y = NSNumber(value: Float(noteImage.imageView.frame.origin.y))
                        let imageRotation = (noteImage.imageView.value(forKeyPath: rotationKeyPath) as? NSNumber)?.floatValue ?? 0.0
                        if imageRotation != 0.0 {
                            image.rotation = NSNumber(value: imageRotation)
                        }
                    } else {
                        // Creamos una nueva imagen
                        var newNoteImage = noteImage
                        newNoteImage.image = createImageWithView(imageView: noteImage.imageView)
                        newImages.append(newNoteImage.image!)
                        noteImages[index] = newNoteImage
                    }
                }
                if !newImages.isEmpty {
                    note.addImage(NSSet(array: newImages))
                }
                
                // Se guarda
                if Container.default.viewContext.hasChanges {
                    do {
                        try Container.default.viewContext.save()
                        view.endEditing(true)
                        delegate?.noteViewDidSave()
                    } catch {
                        // FIXME: Se ha producido un error
                        return
                    }
                }
                
            }
        }
    }
    
    private func createImageWithView(imageView: UIImageView) -> Image {
        
        let image = Image(context: Container.default.viewContext,
                          image: imageView.image!,
                          height: imageView.frame.height,
                          width: imageView.frame.width,
                          x: imageView.frame.origin.x,
                          y: imageView.frame.origin.y,
                          note: note!)
        let imageRotation = (imageView.value(forKeyPath: rotationKeyPath) as? NSNumber)?.floatValue ?? 0.0
        if imageRotation != 0.0 {
            image.rotation = NSNumber(value: imageRotation)
        }
        
        return image
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension NoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageRatio = image.size.width / image.size.height
        let imageWidth = imageMaxHeight * imageRatio
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: imageWidth, height: imageMaxHeight))
        
        addImageViewToNote(imageView: imageView, image: image, imageData: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func moveNoteImage(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began || gesture.state == UIGestureRecognizerState.changed {
            let translation = gesture.translation(in: view)
            gesture.view?.transform = (gesture.view?.transform)!.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
            
            fixNoteTextPosition(image: gesture.view as! UIImageView)
        }
    }
    
    @objc private func zoomNoteImage(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began || gesture.state == UIGestureRecognizerState.changed {
            let newImageHeight = gesture.view!.frame.height * gesture.scale
            if newImageHeight >= minHeight && newImageHeight <= maxHeight {
                gesture.view?.transform = (gesture.view?.transform)!.scaledBy(x: gesture.scale, y: gesture.scale)
                gesture.scale = 1.0
                
                fixNoteTextPosition(image: gesture.view as! UIImageView)
            }
        }
    }
    
    @objc private func rotateNoteImage(gesture: UIRotationGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began || gesture.state == UIGestureRecognizerState.changed {
            let rotation = gesture.rotation
            gesture.view?.transform = (gesture.view?.transform)!.rotated(by: rotation)
            gesture.rotation = 0
            
            fixNoteTextPosition(image: gesture.view as! UIImageView)
        }
    }
    
    private func addImageViewToNote(imageView: UIImageView, image: UIImage, imageData: Image?) {
        
        imageView.tag = noteImages.count
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        let moveViewGesture = UIPanGestureRecognizer(target: self, action: #selector(moveNoteImage))
        imageView.addGestureRecognizer(moveViewGesture)
        let rotateViewGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNoteImage))
        imageView.addGestureRecognizer(rotateViewGesture)
        let zoomViewGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomNoteImage))
        imageView.addGestureRecognizer(zoomViewGesture)
        noteTextView.addSubview(imageView)
        noteTextView.bringSubview(toFront: imageView)
        var noteImage = ImageContent()
        noteImage.imageView = imageView
        if let imageData = imageData {
            noteImage.image = imageData
        }
        noteImages.append(noteImage)
        
        fixNoteTextPosition(image: imageView)
    }
    
}

// MARK: - CLLocationManagerDelegate
extension NoteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            showMap(coordinate: coordinate)
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension NoteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    
    // El salto de línea cierra el teclado
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}

// MARK: - SelectNotebookViewController
extension NoteViewController: SelectNotebookViewControllerDelegate {
    
    func selectNotebookDidSelected(notebook: Notebook, action: NotebookPickerAction, exclude: Notebook?) {
        
        if action == .moveNote {
            if notebook != self.note!.notebook {
                let alert = UIAlertController(title: NSLocalizedString("note.alert.movenote.tite", comment: ""), message: String(format: NSLocalizedString("note.alert.movenote.body", comment: ""), "\(notebook.title!.uppercased())"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: { (action) in

                    notebook.addNote(NSSet(object: self.note!))
                    
                    // Se guarda
                    let context = Container.default.viewContext
                    if context.hasChanges {
                        do {
                            try context.save()
                            self.setData()
                            self.delegate?.noteViewDidSave()
                        } catch {
                            // FIXME: Se ha producido un error
                            fatalError("Error moviendo la nota de libreta")
                        }
                    }
                    
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - BooksTableViewControllerDelegate
extension NoteViewController: BooksTableViewControllerDelegate {
    
    func booksTableViewDidSelectNote(notebooks: [Notebook], note: Note) {
        self.notebooks = notebooks
        self.note = note
        for image in noteImages {
            image.imageView.image = nil
        }
        noteImages = []
        noteTextView.textContainer.exclusionPaths = []
        title = note.title
        setData()
    }

}
