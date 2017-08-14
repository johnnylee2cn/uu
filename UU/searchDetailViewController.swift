//
//  searchDetailViewController.swift
//  UU
//
//  Created by admin on 2017/5/19.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud

class searchDetailViewController: UIViewController {

    var detailDataSource:searchModel!
    var image:UIImage!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        getTimeAndName()
        addLine()
      
    }
    
    //得到用户名和时间
    func getTimeAndName(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.short
        let date = detailDataSource.time
        let dateString = dateFormatter.string(from: date)
        time.text = dateString
        name.text = detailDataSource.userName
        textView.attributedText = detailDataSource.text
        titleLabel.text = detailDataSource.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)//字体加粗
        titleLabel.textAlignment = NSTextAlignment.center//文字居中
        headImage.image = image
        headImage.layer.cornerRadius = 20
        headImage.clipsToBounds = true
    }
    
    func addLine(){
        let line = lineView()
        line.frame = CGRect(x: 0, y: self.time.frame.maxY, width: width, height: 2)
        self.view.addSubview(line)

    }
    
//    //得到文本
//    func getText(){
//        textView.text = detailDataSource["articleText"] as! String
//        
//        if detailDataSource["articleImage"] != nil{
//            if let imgFile = detailDataSource["articleImage"] as? AVFile{
//                imgFile.getDataInBackground({ (data, error) in
//                    if let imgArray = data{
//                        OperationQueue.main.addOperation {
//                            let image = NSKeyedUnarchiver.unarchiveObject(with: imgArray) as! Array<Any>
//                            self.getImage(image: image as! [UIImage])
//                        }
//                    }
//                })
//            }
//        }else{
//            textView.text = detailDataSource["articleText"] as! String
//            textView.isEditable = false
//            
//        }
//    }
//    
//    //得到图片
//    func getImage(image:[UIImage]){
//        for i in 0..<image.count{
//            let attachment = NSTextAttachment()
//            attachment.image = image[i] as? UIImage
//            attachment.bounds = CGRect(x: 0, y: 0, width: 100.CGFloatValue, height: 100.CGFloatValue)
//            let attstr = NSAttributedString(attachment: attachment)
//            let mutableStr = NSMutableAttributedString(attributedString:self.textView.attributedText)
//            let selectedRange = self.textView.selectedRange
//            mutableStr.insert(attstr, at: selectedRange.location)
//            
//            mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 24), range: NSMakeRange(0, mutableStr.length))
//            let newSelectedRange = NSMakeRange(selectedRange.location - 1, 0)
//            self.textView.attributedText = mutableStr
//            self.textView.selectedRange = newSelectedRange
//            self.textView.isEditable = false
//            
//            
//        }
//
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
