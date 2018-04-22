//
//  NoteTableViewCell.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit

final class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var noteNumberLabel: UILabel!
    @IBOutlet weak var noteTitleLabel: UILabel!
    
    static let CELL_NAME = "notecell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // UI
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
        noteNumberLabel.layer.cornerRadius = noteNumberLabel.bounds.height / 2
        noteNumberLabel.clipsToBounds = true
        noteNumberLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        noteTitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        noteNumberLabel.adjustsFontSizeToFitWidth = true
        noteTitleLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // UI
        let color = selected ? EverpobreColors.secondary : EverpobreColors.clearGray
        noteTitleLabel.textColor = color
    }
    
}
