//
//  NotoBookViewController.swift
//  UU
//
//  Created by admin on 2017/3/22.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
import AVOSCloud
import TZImagePickerController

protocol reload {
    func successToCloud(bool:Bool)
}

class NotoBookViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate {
   
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var activityIndictor: UIActivityIndicatorView!
    
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var noto:MyNotoBook!
    var imageView:UIImageView!
    var imgArray:Array<UIImage>! = []
    var imgViewArray:Array<UIImageView>! = []
    var imgDataArray:Array<Data> = []
    var closeImgArray:Array<UIImageView>! = []
    var name = ""
    var bool = false
    var a = true
    var x:CGFloat! = nil
    var y:CGFloat! = nil
    var doubleClickCount = 0
   // var closeImgView:UIImageView!
    var tagArray = [0,1,2]

    var delegate:reload?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndictor.isHidden = true
        textView.delegate = self
        addName()
       
        let saveButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveToCloud))
        let imageButton = UIBarButtonItem(image: UIImage(named:"照相机"), style: .plain, target: self, action: #selector(doAddPicture))
        
        self.navigationItem.rightBarButtonItems = [saveButton,imageButton]
      }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveToCloud(){
        activityIndictor.isHidden = false        
        activityIndictor.startAnimating()
        saveLabel.isHidden = false
        //遍历class
        let cloudObject = AVObject(className: "UserNoto")
        cloudObject["userName"] = name
        if textView.text != ""{
        cloudObject["notoText"] = textView.text
        }else{
        cloudObject["notoText"] = "  "
        }
        if imgArray.count != 0{
        let imgDataArray = NSKeyedArchiver.archivedData(withRootObject: imgArray) as NSData
       
        let imgFile = AVFile(name: name, data: imgDataArray as Data)
        cloudObject["notoImage"] = imgFile

        }
        cloudObject.saveInBackground { (succeed, error) in
            if succeed{
                self.activityIndictor.stopAnimating()
                self.saveLabel.isHidden = true
                self.activityIndictor.isHidden = true
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                print("云端保存成功")
                self.delegate?.successToCloud(bool: true)
                
            }else{
                print(error ?? "位置错误")
            }
        }
    }

    //MARK: - 和相册交互
    
    
    func closeAddPicture(){
        let actionSheet = UIAlertController(title: "提示", message: "", preferredStyle: .alert)
        let message = UIAlertAction(title: "最多只能选择三张图片", style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: "返回", style: .cancel, handler: nil)
        actionSheet.addAction(message)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    //添加图片提示
    func doAddPicture(){
        print(imgViewArray.count)
        if imgViewArray.count<=2{
        let actionSheet = UIAlertController(title: "添加图片", message: "", preferredStyle: .actionSheet)
        let image = UIAlertAction(title: "打开相册", style: .default) { (_) in
            self.openLibrary()
        }
        let camera = UIAlertAction(title: "打开相机", style: .default) { (_) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionSheet.addAction(image)
        actionSheet.addAction(camera)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        }else{
            closeAddPicture()
        }
    }
    
    //打开相册
    func openLibrary(){
        let photoBrowser = TZImagePickerController(maxImagesCount: 3, delegate: self)
        present(photoBrowser!, animated: true, completion: nil)
        
        
    }
    //打开相机
    func openCamera(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
         let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = .camera
            picker.delegate = self
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
                //每选择一张图片，添加一个imageView放置图片
          for value in photos{
               getImageForArray(image: value)
            
                
                pictureRight()
                a = false
        }
    }
    
    func getImageForArray(image:UIImage){
        imageView = UIImageView(frame: picture.frame)
        imageView.frame = CGRect(x:picture.frame.origin.x , y: picture.frame.origin.y, width: picture.frame.width, height: picture.frame.height)
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
    
    //添加图片框右移
    func pictureRight(){
        guard picture.frame.origin.x > 320 - picture.frame.width else{
            return picture.frame = CGRect(x: picture.frame.origin.x + picture.frame.width, y: picture.frame.origin.y, width: picture.frame.width, height: picture.frame.height)}
        
        picture.frame = CGRect(x: 0 , y: picture.frame.origin.y + picture.frame.width, width: picture.frame.width, height: picture.frame.height)
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
                value.frame.origin.x = (value.frame.origin.x) - (self.picture.frame.width)
            }
        }
        self.imgViewArray[0].isHidden = true
        self.closeImgArray.remove(at: 0)
        self.imgViewArray.remove(at: 0)
        self.imgArray.remove(at: 0)
        self.picture.frame.origin.x = self.picture.frame.origin.x - self.picture.frame.width
    }
    
    func whenCountIsOneOrTwoOrThreeOrFour(number:Int){
        for value in self.imgViewArray{
            if self.width.IntValue - (value.frame.minX).IntValue < (x.IntValue){
                value.frame.origin.x = (value.frame.origin.x) - (value.frame.width)
            }
        }
        self.picture.frame.origin.x = self.picture.frame.origin.x - self.picture.frame.width
        self.imgViewArray[number].isHidden = true
        //  pictureLeft(imageViewID: 0)
        self.closeImgArray.remove(at: number)
        self.imgViewArray.remove(at: number)
        self.imgArray.remove(at: number)
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
    
    
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

extension NotoBookViewController:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeHolderLabel.isHidden = true
        return true
    }
}
