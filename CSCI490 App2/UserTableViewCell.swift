//
//  UserTableViewCell.swift
//  Test App
//
//  Created by Ron Ward on 2/22/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
