//
//  SelectNotebookViewController.swift
//  Everpobre
//
//  Created by Brais Moure on 19/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit

protocol SelectNotebookViewControllerDelegate: class {
    
    func selectNotebookDidSelected(notebook: Notebook, action: NotebookPickerAction, exclude: Notebook?)
    
}

enum NotebookPickerAction: Int {
    case addNote = 0
    case deleteNotebook = 1
    case moveNotes = 2
    case moveNote = 3
}

final class SelectNotebookViewController: UIViewController {

    private let notebooks: [Notebook]
    private weak var delegate: SelectNotebookViewControllerDelegate?
    private var action: NotebookPickerAction
    private var exclude: Notebook?
    
    @IBOutlet weak var pickerView: UIPickerView!

    // MARK: - Inicialization
    init(notebooks: [Notebook], delegate: SelectNotebookViewControllerDelegate?, action: NotebookPickerAction, exclude: Notebook? = nil) {
        self.notebooks = notebooks
        self.delegate = delegate
        self.action = action
        self.exclude = exclude
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        pickerView.dataSource = self
        pickerView.delegate = self
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    @IBAction func acceptButtonAction(_ sender: Any) {
        
        let row = pickerView.selectedRow(inComponent: 0)
        let notebook = notebooks[row]
        if let exclude = exclude {
            if exclude != notebook {
                delegate?.selectNotebookDidSelected(notebook: notebook, action: action, exclude: exclude)
                cancelButtonAction(sender)
            }
        } else {
            delegate?.selectNotebookDidSelected(notebook: notebook, action: action, exclude: exclude)
            cancelButtonAction(sender)
        }

    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }    
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension SelectNotebookViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notebooks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: notebooks[row].title?.uppercased() ?? "", attributes: [NSAttributedStringKey.foregroundColor: EverpobreColors.black])
    }
    
}
