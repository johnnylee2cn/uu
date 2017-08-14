//
//  detailCityViewController.swift
//  UU
//
//  Created by admin on 2017/7/22.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class detailCityViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var detailPlan:BMKTransitRouteLine!
    var planArray:[BMKTransitStep] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        planArray = [(detailPlan.steps as! [BMKTransitStep])[0]]
        for value in detailPlan.steps as! [BMKTransitStep]{
            planArray.append(value)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return planArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCityCell", for: indexPath) as! detailCityPlanTableViewCell
        let value = planArray[indexPath.row]
        
        cell.detailLabel.text = value.instruction
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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
