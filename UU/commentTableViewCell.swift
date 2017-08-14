//
//  commentTableViewCell.swift
//  UU
//
//  Created by admin on 2017/5/17.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class commentTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var headImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headImage.layer.cornerRadius = 15
        headImage.clipsToBounds = true
        //textView.endEditing(true)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
