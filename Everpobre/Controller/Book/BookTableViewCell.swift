//
//  BookTableViewCell.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit

protocol BookTableViewCellDelegate {
    
    func bookTableViewCellFavoriteDidChange(notebook: Notebook)
    
}

final class BookTableViewCell: UITableViewCell {
    
    var delegate: BookTableViewCellDelegate?
    var notebook: Notebook!

    @IBOutlet weak var notebookNameLabel: UILabel!
    @IBOutlet weak var notebookCreationDateLabel: UILabel!
    @IBOutlet weak var notebookNotesNumberLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private let dateFormatter = DateFormatter()
    
    static let CELL_NAME = "bookcell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // UI
        notebookNameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        notebookCreationDateLabel.font = UIFont.preferredFont(forTextStyle: .body)
        notebookNotesNumberLabel.font = UIFont.preferredFont(forTextStyle: .body)
        notebookNameLabel.adjustsFontSizeToFitWidth = true
        notebookCreationDateLabel.adjustsFontSizeToFitWidth = true
        notebookNotesNumberLabel.adjustsFontSizeToFitWidth = true
        
        // Data
        dateFormatter.dateStyle = .long
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func teto(_ sender: Any) {
        print("teto")
    }
    @IBAction func favoriteButtonAction(_ sender: Any) {
        
        if !notebook.favorite!.boolValue {
            favoriteButton.setImage(UIImage(named: "star"), for: .normal)
            notebook.favorite = true
            
            delegate?.bookTableViewCellFavoriteDidChange(notebook: notebook)
        }
    }
    
}
