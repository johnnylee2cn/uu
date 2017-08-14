//
//  routeLineTableViewCell.swift
//  UU
//
//  Created by admin on 2017/7/18.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class routeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    @IBOutlet weak var searchStyle: UILabel!
    
    var startLatitude:CGFloat!
    var startlongitude:CGFloat!
    var endLatitude:CGFloat!
    var endLongitude:CGFloat!
    var style:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
