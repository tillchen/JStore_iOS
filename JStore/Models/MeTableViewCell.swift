//
//  MeTableViewCell.swift
//  JStore
//
//  Created by Till Chen on 1/18/20.
//  Copyright © 2020 Tianyao Chen. All rights reserved.
//

import UIKit

class MeTableViewCell: UITableViewCell {


    @IBOutlet var mImageView: UIImageView!
    @IBOutlet var mLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
