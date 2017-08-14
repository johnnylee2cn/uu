//
//  notoCardViewController.swift
//  UU
//
//  Created by admin on 2017/7/28.
//  Copyright © 2017年 L. All rights reserved.
//

import UIKit

class notoCardViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var notoCollectionView: UICollectionView!
    
    var model:[notoModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.tabBar.isHidden = true
        
        notoCollectionView.delegate = self
        notoCollectionView.dataSource = self
        notoCollectionView.frame = CGRect(x:0 , y: (self.navigationController?.navigationBar.frame.maxY)!, width: width, height: height - (self.navigationController?.navigationBar.bounds.height)!)
        self.notoCollectionView.collectionViewLayout = self.setupCollectionFlowlayout()
        self.notoCollectionView.showsVerticalScrollIndicator = false
        self.notoCollectionView.showsHorizontalScrollIndicator = false
        self.notoCollectionView.isPagingEnabled = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       //  self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCollectionFlowlayout() -> (UICollectionViewFlowLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = self.notoCollectionView.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        return flowLayout
    }
    
    //MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notoCardCell", for: indexPath) as! notoCardCollectionViewCell
        let value = model[indexPath.row]
        
        cell.textView.attributedText = value.text
        cell.countLabel.text = "第\((indexPath.row)+1)篇"
        cell.textView.backgroundColor = UIColor(red: 16/255, green: 134/255, blue: 184/255, alpha: 0.6)
       // cell.bgView
        
        return cell
        
    }
    
    
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if notoCollectionView.contentOffset.x == 0 {
//            self.notoCollectionView.contentOffset.x = CGFloat(2 * self.model.count - 1) * self.notoCollectionView.bounds.width
//            
//        }
//        //当到达最后一个cell时,重新设置contentOffset.x的值
//        if notoCollectionView.contentOffset.x == CGFloat(3 * self.model.count - 1) * self.notoCollectionView.bounds.width {
//            self.notoCollectionView.contentOffset.x = CGFloat(self.model.count - 1) * self.notoCollectionView.bounds.width
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
