//
//  PostTableViewCell.swift
//  JStore
//
//  Created by Till Chen on 1/7/20.
//  Copyright © 2020 Tianyao Chen. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet var mImage: UIImageView!
    @IBOutlet var mTitle: UILabel!
    @IBOutlet var mSeller: UILabel!
    @IBOutlet var mPrice: UILabel!
    @IBOutlet var mCategory: UILabel!
    @IBOutlet var mDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
