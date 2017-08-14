//
//  contactPeopleTableViewCell.swift
//  UU
//
//  Created by admin on 2017/6/3.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class contactPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var headImage: UIImageView!
    
    @IBOutlet weak var badgeLeadingMargin: NSLayoutConstraint!
    @IBOutlet weak var badgeTopMargin: NSLayoutConstraint!
    @IBOutlet weak var badgetrailingMargin: NSLayoutConstraint!
    @IBOutlet weak var badgeButtomMargin: NSLayoutConstraint!
    
    var labelTopLayoutConstant: CGFloat!
    var labelLeadingLayoutConstant: CGFloat!
    var labelTrailingLayoutConstant: CGFloat!
    var labelBottomLayoutConstant: CGFloat!
    var viewFrameY:CGFloat!
    var viewFrameX:CGFloat!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        //头像设置圆角
        headImage.layer.cornerRadius = 15
        headImage.clipsToBounds = true
        setBadgeLabel()

    }

    func setBadgeLabel(){
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = NSTextAlignment.center
        badgeLabel.isUserInteractionEnabled = true
        let tap = UIPanGestureRecognizer(target: self, action: #selector(slideLabel))
        badgeLabel.addGestureRecognizer(tap)
        labelTopLayoutConstant = badgeTopMargin.constant
        labelBottomLayoutConstant = badgeButtomMargin.constant
        labelLeadingLayoutConstant = badgeLeadingMargin.constant
        labelTrailingLayoutConstant = badgetrailingMargin.constant
    }
    
    func slideLabel(sender:UIPanGestureRecognizer){
        
        if sender.state == .began{
            viewFrameY = sender.view?.frame.origin.y
            viewFrameX = sender.view?.frame.origin.x
            
        }else if sender.state == .changed{
            let y1 = sender.translation(in: sender.view?.superview).y
            
            badgeTopMargin.constant = labelTopLayoutConstant + y1
            badgeButtomMargin.constant = labelBottomLayoutConstant - y1
            
            
            let x1 = sender.translation(in: sender.view?.superview).x
            badgeLeadingMargin.constant = labelLeadingLayoutConstant + x1
            badgetrailingMargin.constant = labelTrailingLayoutConstant - x1
            
        }else if sender.state == .ended{
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                () -> Void in
                self.badgeLabel.frame.origin.y = self.viewFrameY
                self.badgeLabel.frame.origin.x = self.viewFrameX
            }, completion: { (success) -> Void in
                if success {
                    //回弹动画结束后恢复默认约束值
                    self.badgeTopMargin.constant = self.labelTopLayoutConstant
                    self.badgeLeadingMargin.constant = self.labelLeadingLayoutConstant
                    self.badgetrailingMargin.constant = self.labelTrailingLayoutConstant
                    self.badgeButtomMargin.constant = self.labelBottomLayoutConstant
                    self.badgeLabel.isHidden = true
                }
            })
            return
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
