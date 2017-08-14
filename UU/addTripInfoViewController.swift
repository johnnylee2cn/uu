//
//  addTripInfoViewController.swift
//  UU
//
//  Created by admin on 2017/5/16.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import TZImagePickerController

protocol reloadView {
    func reload(bool:Bool)
}

class addTripInfoViewController: UIViewController,TZImagePickerControllerDelegate {
    @IBOutlet weak var titleLabel: UITextField!

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var lineSegmented: UISegmentedControl!
    
    @IBOutlet weak var addImage: UIImageView!
    
    @IBOutlet weak var map: UIButton!
    
    @IBOutlet weak var activityIndictor: UIActivityIndicatorView!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var eiditLabel: UILabel!
    
    @IBAction func mapAdress(_ sender: UIButton) {
        if map.currentTitle == ""{
        let defaults2 = UserDefaults.standard
        let objectData2 = defaults2.data(forKey: "city")
        let city = NSKeyedUnarchiver.unarchiveObject(with: objectData2!) as! String
        map.setTitle(city, for: .normal)
        }else{
        map.setTitle("", for: .normal)
        }
    }
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var imageView:UIImageView!
    var imgArray:Array<UIImage>! = []
    var imgViewArray:Array<UIImageView>! = []
    var closeImgArray:Array<UIImageView>! = []
    var imgDataArray:Array<Data> = []
    var x:CGFloat! = nil
    var y:CGFloat! = nil
    var tagArray = [0,1,2]
    var doubleClickCount = 0
    var name:String! = ""
     var a = true
    var delegate:reloadView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setToolBar()
        addName()
        makeLine()
        let barButtonRight = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveDataToCloud))
        let imageBarButton = UIBarButtonItem(image: UIImage(named:"照相机"), style: .plain, target: self, action: #selector(openImage))
        self.navigationItem.rightBarButtonItems = [barButtonRight,imageBarButton]
        
        
        addImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openImage))
        addImage.addGestureRecognizer(gesture)
       
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //制造线条
    func makeLine(){
        let line = lineView()
        line.frame = CGRect(x: 0, y: self.titleLabel.frame.maxY, width: self.view.bounds.width, height: 2)
        self.view.addSubview(line)
        
        let line2 = lineView()
        line2.frame = CGRect(x: 0, y: self.textView.frame.maxY, width: self.view.bounds.width, height: 2)
        self.view.addSubview(line2)

    }
    
    //将控件与工具栏键盘关联
    func setToolBar(){
        textView.inputAccessoryView = AddToolBar()
        textView.delegate = self
        titleLabel.inputAccessoryView = AddToolBar()
    }
    
    //收起键盘
    func AddToolBar() -> UIToolbar {
        let toolBar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
        toolBar.backgroundColor = UIColor.gray
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneNum))
        toolBar.items = [spaceBtn, barBtn]
        return toolBar
    }
    
    func doneNum() {
        self.view.endEditing(false)
    }
    
    //MARK: - 与云数据交互
    func saveDataToCloud(){
        activityIndictor.alpha = 1
        activityIndictor.startAnimating()
        saveLabel.isHidden = false
        //遍历class
        let cloudObject = AVObject(className: "searchTripInfo")
        cloudObject["userName"] = name
        cloudObject["articleTitle"] = titleLabel.text ?? " "
        cloudObject["articleText"] = textView.text ?? "  "
        if lineSegmented.selectedSegmentIndex == 0{
            cloudObject["onTheLine"] = false
        }else{
            cloudObject["onTheLine"] = true
        }
        if map.currentTitle != ""{
            cloudObject["userAddress"] = map.titleLabel?.text
        }else{
            cloudObject["userAddress"] = "未设置"
        }
        
        if imgArray.count != 0{
            let imgDataArray = NSKeyedArchiver.archivedData(withRootObject: imgArray) as NSData
            let imgFile = AVFile(name: titleLabel.text, data: imgDataArray as Data)
            cloudObject["articleImage"] = imgFile
            
        }
        cloudObject.saveInBackground { (succeed, error) in
            if succeed{
                self.saveSuccess()
            }else{
                self.saveError(error:error!)
            }
        }
    }
    
    //如果保存成功
    func saveSuccess(){
                print("云端保存成功")
                self.activityIndictor.stopAnimating()
                self.activityIndictor.isHidden = true
                self.saveLabel.isHidden = true
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                self.delegate?.reload(bool: true)

    }
    
    func saveError(error:Error){
                print(error )
                self.activityIndictor.stopAnimating()
                self.activityIndictor.isHidden = true
                self.saveLabel.isHidden = true
                let menu = UIAlertController(title: "云端保存失败", message: "", preferredStyle: .alert)
                let back = UIAlertAction(title: "确认", style: .cancel, handler: nil)
                menu.addAction(back)
                self.present(menu, animated: true, completion: nil)

    }

    //打开相册
    func openImage(){
        let actionMenu = UIAlertController(title: "提示", message: "添加图片", preferredStyle: .actionSheet)
        let image = UIAlertAction(title: "打开相册", style: .default) { (_) in
            self.openLibrary()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionMenu.addAction(image)
        actionMenu.addAction(cancel)
        
        present(actionMenu, animated: true, completion: nil)
    }
    
    //打开相册
    func openLibrary(){
        let photoBrowser = TZImagePickerController(maxImagesCount: 3, delegate: self)
        present(photoBrowser!, animated: true, completion: nil)

    }
    
      //添加图片框右移
    func pictureRight(){
        guard addImage.frame.origin.x > 320 - addImage.frame.width else{
            return addImage.frame = CGRect(x: addImage.frame.origin.x + addImage.frame.width, y: addImage.frame.origin.y, width: addImage.frame.width, height: addImage.frame.height)}
        
        addImage.frame = CGRect(x: 0 , y: addImage.frame.origin.y + addImage.frame.width, width: addImage.frame.width, height: addImage.frame.height)
    }
    
    //imgView常按
    func longClick(tap:UILongPressGestureRecognizer){
        tap.view?.subviews[0].isHidden = false
    }
    
    //删除图片的方法
    func closeImage(tap:UITapGestureRecognizer){
        let actionMenu = UIAlertController(title: "提示", message: "是否删除图片", preferredStyle: .alert)
        let no = UIAlertAction(title: "取消", style: .cancel) { (_) in
            tap.view?.isHidden = true
        }
        let yes = UIAlertAction(title: "确定", style: .default) { (_) in
            
            self.sidesImageCount(tap:tap)
            
            
            
        }
        actionMenu.addAction(no)
        actionMenu.addAction(yes)
        present(actionMenu, animated: true, completion: nil)
    }
    
    //确定两侧图片数量
    func sidesImageCount(tap:UITapGestureRecognizer){
        //num代表右边图片数量，count代表左边图片数量
        var count = 0
            var num = 0
            var number = 0
            let x = self.width - (tap.view?.superview?.frame.minX)!
        for value in self.closeImgArray{
                print("value\(value.frame.minX)")
                if self.width.IntValue - (value.superview?.frame.minX)!.IntValue > (x.IntValue){
                    count += 1
                    
                }else if self.width.IntValue - (value.superview?.frame.minX)!.IntValue < (x.IntValue){
                    num += 1
                    
                }else{
                    number += 1
                }
            }
        getCount(count: count)
    }
    
    //得到两侧图片数量
    func getCount(count:Int){
        if count  == 0{
            
            whenCountIsZero()
        }else if count == 1{
            whenCountIsOneOrTwoOrThreeOrFour(number: 1)
            
        }else if count == 2{
            whenCountIsOneOrTwoOrThreeOrFour(number: 2)
        }else if count == 3{
            whenCountIsOneOrTwoOrThreeOrFour(number: 3)
        }else if count == 4{
            whenCountIsOneOrTwoOrThreeOrFour(number: 4)
        }
    }
    
    //当count为0
    func whenCountIsZero(){
        for value in self.imgViewArray{
                print(self.width.IntValue - (value.frame.minX).IntValue)
                if self.width.IntValue - (value.frame.minX).IntValue <= (x.IntValue){
                    value.frame.origin.x = (value.frame.origin.x) - (self.addImage.frame.width)
                }
            }
            self.imgViewArray[0].isHidden = true
            self.closeImgArray.remove(at: 0)
            self.imgViewArray.remove(at: 0)
            self.imgArray.remove(at: 0)
            self.addImage.frame.origin.x = self.addImage.frame.origin.x - self.addImage.frame.width
    }
    
    func whenCountIsOneOrTwoOrThreeOrFour(number:Int){
        for value in self.imgViewArray{
                if self.width.IntValue - (value.frame.minX).IntValue < (x.IntValue){
                    value.frame.origin.x = (value.frame.origin.x) - (value.frame.width)
                }
            }
            self.addImage.frame.origin.x = self.addImage.frame.origin.x - self.addImage.frame.width
            self.imgViewArray[number].isHidden = true
            //  pictureLeft(imageViewID: 0)
            self.closeImgArray.remove(at: number)
            self.imgViewArray.remove(at: number)
            self.imgArray.remove(at: number)
        }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        for value in photos{
            
            getImageForArray(image: value)
            pictureRight()
            a = false
        }

    }
    
    func getImageForArray(image:UIImage){
        imageView = UIImageView(frame: addImage.frame)
        imageView.frame = CGRect(x:addImage.frame.origin.x , y: addImage.frame.origin.y, width: addImage.frame.width, height: addImage.frame.height)
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        imgViewArray.append(imageView)
        
        //imageVIew常按手势
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longClick(tap:)))
        imageView.addGestureRecognizer(longTap)
        let imgData = UIImageJPEGRepresentation(imageView.image!, 0.3)
        self.imgDataArray.append(imgData!)
        self.imgArray.append(imageView.image!)
        addCloseImage(imageView: imageView)
        self.view.addSubview(imageView)
        
    }
    
    func addCloseImage(imageView:UIImageView){
    //每个添加的imageView上面添加一张小图片
            let closeImgView = UIImageView()
            closeImgView.frame = CGRect(x: self.view.frame.minX, y: 0, width: 20, height: 20)
            closeImgView.image = UIImage(named: "叉")
            closeImgView.isUserInteractionEnabled = true
            closeImgView.isHidden = true
        
        //添加点击事件
            let target = UITapGestureRecognizer(target: self, action: #selector(closeImage(tap: )))
            closeImgView.addGestureRecognizer(target)
            closeImgArray.append(closeImgView)
            imageView.addSubview(closeImgView)

    }
    
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //保存提示菜单
    func menu(){
        let actionAlert = UIAlertController(title: "提示", message: "标题或者内容未输入", preferredStyle: .alert)
        let actionTotal = UIAlertAction(title: "返回", style: .destructive, handler: nil)
        actionAlert.addAction(actionTotal)
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    func addName() {
        let defaults = UserDefaults.standard
        let object = defaults.data(forKey: "name")
        name = NSKeyedUnarchiver.unarchiveObject(with: object!) as! String
    }

    //保存提示菜单


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension addTripInfoViewController:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.eiditLabel.isHidden = true
        return true
    }
}
