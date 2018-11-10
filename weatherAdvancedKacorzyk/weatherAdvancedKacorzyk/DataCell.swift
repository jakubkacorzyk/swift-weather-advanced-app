//
//  DataCell.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 10/11/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import UIKit

class DataCell: UITableViewCell {
    
    @IBOutlet weak var label: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func congigureCell(text: String) {
        
        label.text = text
    }
}
