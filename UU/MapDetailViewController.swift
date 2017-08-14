//
//  MapDetailViewController.swift
//  UU
//
//  Created by admin on 2017/3/26.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class MapDetailViewController: UIViewController {

    var imageName = ["icecream-4","cup","shop","鱼"]
    var titleName = ["甜点","下午茶","超市","美食"]
    var bu:Array<UIButton> = []
    
    @IBAction func rMap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "cMap", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "selectAddressName")
        buttonMake()
        tapped()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonMake(){
        var button:UIButton!
        for i in 0..<imageName.count{
        
        let a =  scaleImage(UIImage(named: imageName[i])!, 0.1)
        button = UIButton()
        button.frame = CGRect(x: 0 + i*50, y: 30, width: 50, height: 50)
        button.center = CGPoint(x: 20 + i.CGFloatValue*30.CGFloatValue, y: 70)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10) //文字大小
        button.setTitleColor(UIColor.orange, for: UIControlState.normal) //文字颜色
        button.tag = i * 100
        button.set(image: a, title: titleName[i], titlePosition: .bottom,
                 additionalSpacing: 10.0, state: .normal)
        bu.append(button)
        self.view.addSubview(button)
        
        }
    }
    

    func scaleImage(_ image:UIImage,_ scaleSize:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContext(CGSize(width:image.size.width*scaleSize,height: image.size.height*scaleSize))
        image.draw(in: CGRect(x:0,y: 0,width: image.size.width*scaleSize, height:image.size.height*scaleSize))
        let scaledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
   
    func tapped(){
      //  print("ssss")
        //button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        bu[0].addTarget(self, action: #selector(ta), for: .touchUpInside)
        bu[1].addTarget(self, action: #selector(ta1), for: .touchUpInside)
        bu[2].addTarget(self, action: #selector(ta2), for: .touchUpInside)
        bu[3].addTarget(self, action: #selector(ta3), for: .touchUpInside)
    }
    
    func ta()  {
        let defaults = UserDefaults.standard
        let lableData = NSKeyedArchiver.archivedData(withRootObject: bu[0].titleLabel?.text ?? "未显示")
        defaults.set(lableData, forKey: "selectAddressName")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func ta1()  {
        let defaults = UserDefaults.standard
        let lableData = NSKeyedArchiver.archivedData(withRootObject: bu[1].titleLabel?.text ?? "未显示")
        defaults.set(lableData, forKey: "selectAddressName")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func ta2()  {
        let defaults = UserDefaults.standard
        let lableData = NSKeyedArchiver.archivedData(withRootObject: bu[2].titleLabel?.text ?? "未显示")
        defaults.set(lableData, forKey: "selectAddressName")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func ta3()  {
        let defaults = UserDefaults.standard
        let lableData = NSKeyedArchiver.archivedData(withRootObject: bu[3].titleLabel?.text ?? "未显示")
        defaults.set(lableData, forKey: "selectAddressName")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIButton{
    @objc func set(image anImage: UIImage?, title: String,
                   titlePosition: UIViewContentMode, additionalSpacing: CGFloat, state: UIControlState){
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)
        
        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }
    
    private func positionLabelRespectToImage(title: String, position: UIViewContentMode,
                                             spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(attributes: [NSFontAttributeName: titleFont!])
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
}
