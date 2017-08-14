//
//  ageSelecteViewController.swift
//  UU
//
//  Created by admin on 2017/5/9.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit
protocol ageResult {
    func ageSelect(age:String)
}

class ageSelecteViewController: UIViewController {
    
    @IBOutlet weak var dateBirthdayTextfield: UITextField!
    @IBOutlet weak var dateSelect: UIDatePicker!
    
    @IBAction func selectButton(_ sender: UIButton) {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.unitsStyle = .full
            dateComponentsFormatter.allowedUnits = [.year]
            let autoFormattedDifference = dateComponentsFormatter.string(from: dateSelect.date, to: Date())
      
            dateBirthdayTextfield.text = autoFormattedDifference
            delegate?.ageSelect(age: autoFormattedDifference!)
        
    }
    var delegate:ageResult?
    var isY = true

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveButton))
        self.navigationItem.rightBarButtonItem = button
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if isY == false{
            let line = lineView()
            line.frame = CGRect(x: self.dateBirthdayTextfield.frame.minX, y: self.dateBirthdayTextfield.frame.maxY, width: self.dateBirthdayTextfield.frame.width, height: 2)
            self.view.addSubview(line)
        }
        self.isY = false
    }
    

    func saveButton(){
        if dateBirthdayTextfield.text != ""{
        
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
            
        }else{
            let actionSheet = UIAlertController(title: "提示", message: "请选择时间", preferredStyle: .alert)
            let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
            actionSheet.addAction(back)
            present(actionSheet, animated: true, completion: nil)
        }
        
   }
    
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
//extension ageSelecteViewController:UIPickerViewDelegate{
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        <#code#>
//    }
//}
