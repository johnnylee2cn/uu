//
//  detailMassPlanViewController.swift
//  UU
//
//  Created by admin on 2017/7/22.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class detailMassPlanViewController: UIViewController {

    var detailPlan:BMKMassTransitRouteLine!
    var planArray:[BMKMassTransitSubStep] = []
    
    var step:[BMKMassTransitStep] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        if let steps = detailPlan.steps{
           self.step = (steps as? [BMKMassTransitStep])!
           for subStep in step{
             for value in (subStep.steps as? [BMKMassTransitSubStep])!{
                 planArray.append(value)
                        }
                    }
                    tableView.reloadData()
                }
            
      
        // Do any additional setup after loading the view.
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

extension detailMassPlanViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "massDetail", for: indexPath) as? detailTrainTableViewCell
        let value = planArray[indexPath.row]
        cell?.planLabel.text = value.instructions
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
