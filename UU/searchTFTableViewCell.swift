//
//  searchTFTableViewCell.swift
//  UU
//
//  Created by admin on 2017/5/16.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit



class searchTFTableViewCell: UITableViewCell {

    var name:String! = ""
    var myView = dropDownView()//自己绘制的线条
    var walkInfo:UIButton!
    var infoButton:UIButton!//查看用户资料
    var detailButton:UIButton!//跳转详情页面的button
    var likeView = UITextView()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
   
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var labeltext: UILabel!
    
    
    @IBOutlet weak var userAdress: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var headImage: UIImageView!

   
    @IBOutlet weak var menuButton: UIButton!
    @IBAction func heartClick(_ sender: UIButton) {
            }
    
    @IBAction func menu(_ sender: UIButton) {
        if myView.isHidden == true{
        menuButton.setImage(UIImage(named:"下拉箭头-2"), for: .normal)
            myView.isHidden = false
        }
        else{
            menuButton.setImage(UIImage(named:"下拉箭头"), for: .normal)
            myView.isHidden = true
        }
    }
    
    
        
    func homeOrRoad(){
        let defaults = UserDefaults.standard
        let objects = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: objects!) as!String
        if name == nameLabel.text{
            if walkInfo.titleLabel?.text == "正在路上"{
                walkInfo.setTitle("正在筹备", for: .normal)
            }else{
                walkInfo.setTitle("正在路上", for: .normal)
            }
        }

    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoView.frame.origin = CGPoint(x: infoView.frame.origin.x, y: 0)
        myView = dropDownView(frame:CGRect(x: 250, y: menuButton.frame.maxY+5, width: 52, height: 95))//自己绘制的线条

        headImage.layer.cornerRadius = 20
        headImage.clipsToBounds = true
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(heartLongClick(tap:)))
        heartButton.addGestureRecognizer(tap)
        
        myView.isHidden = true
        setButton()
        setWalkInfo()
        setdetailButton()
        self.addSubview(myView)
        
        self.likeView.frame.origin = CGPoint(x: 0, y: 0)
        self.likeView.frame.size = CGSize(width: self.bounds.width, height: self.bounds.height - 30)
        self.likeView.backgroundColor = UIColor(red:104/255, green: 104/255, blue: 104/255, alpha: 1)
        self.likeView.isHidden = true
        self.addSubview(self.likeView)
        // Initialization code
    }
    
    //爱心按钮常按事件
    func heartLongClick(tap:UILongPressGestureRecognizer){
        if likeView.isHidden == true{
            likeView.isHidden = false
        }else{
            likeView.isHidden = true
        }
    }
    
    //  设置查看资料按钮
    func setButton(){
        infoButton = UIButton(frame: CGRect(x: 0, y: 5, width: 52, height: 29))
        infoButton.setTitle("查看资料", for: .normal)
        infoButton.backgroundColor = UIColor(red:237/255, green: 212/255, blue: 179/255, alpha: 0.8)
        infoButton.setTitleColor(UIColor.red, for: .highlighted)
        infoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        myView.addSubview(infoButton)
    }

    func setWalkInfo(){
        walkInfo = UIButton(frame: CGRect(x: 0, y: 36, width: 52, height: 29))
        walkInfo.backgroundColor = UIColor(red:237/255, green: 212/255, blue: 179/255, alpha: 0.8)
        walkInfo.setTitleColor(UIColor.red, for: .highlighted)
        walkInfo.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        walkInfo.setTitle("正在路上", for: .normal)
        walkInfo.addTarget(self, action: #selector(homeOrRoad), for: .touchUpInside)
        myView.addSubview(walkInfo)
    }
    //跳往详情页面按钮
    func setdetailButton(){
        detailButton = UIButton(frame: CGRect(x: 0, y: 66, width: 52, height: 29))
        detailButton.backgroundColor = UIColor(red:237/255, green: 212/255, blue: 179/255, alpha: 0.8)
        detailButton.setTitleColor(UIColor.red, for: .highlighted)
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        detailButton.setTitle("详细查看", for: .normal)
        myView.addSubview(detailButton)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class dropDownView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 0.1)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //width = 52  height 60
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8 )
        context?.setAllowsAntialiasing(true)
        
        //-------
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 5))
        context?.addLine(to: CGPoint(x: 30, y: 5))
        context?.strokePath()
        //          /
        //---------
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 30, y: 5))
        context?.addLine(to: CGPoint(x: 35, y: 0))
        context?.strokePath()
        
        //          /\
        //---------
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 35, y: 0))
        context?.addLine(to: CGPoint(x: 40, y: 5))
        context?.strokePath()
        
        //          /\
        //---------    --
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 40, y: 5))
        context?.addLine(to: CGPoint(x: 52, y: 5))
        context?.strokePath()
        
        
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 5))
        context?.addLine(to: CGPoint(x: 0, y: 95))
        context?.strokePath()
        
        //          /
        //---------
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: 95))
        context?.addLine(to: CGPoint(x: 52, y: 95))
        context?.strokePath()
        
        //          /
        //---------
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 52, y: 95))
        context?.addLine(to: CGPoint(x: 52, y: 5))
        context?.strokePath()
    }
}
