//
//  ConversationTableViewCell.swift
//  Chating App
//
//  Created by administrator on 08/01/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageIV: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageIV.layer.cornerRadius = 50
        userImageIV.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
