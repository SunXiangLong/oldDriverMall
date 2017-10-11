//
//  goodsCategoryVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/16.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON
import MJRefresh
import PKHUD
import IBAnimatable
class goodsCategoryCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var name: AnimatableLabel!
    var text:String?{
        didSet{
            name.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
class goodsCategoryCell: UITableViewCell {
    
    
    @IBOutlet weak var goods_name: UILabel!
    @IBOutlet weak var goods_icon: UIImageView!
    @IBOutlet weak var goods_price: UILabel!
    @IBOutlet weak var goods_originalPrice: UILabel!
    var model:goodsModel?{
        
        didSet{
            goods_icon.setImage(with: model?.goods_thumb_img)
            goods_price.text = "￥" + model!.shop_price
            goods_originalPrice.text = "￥" + model!.market_price
            goods_name.text = model?.goods_name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
class goodsCategoryVC: baseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noGoodsViewTop: NSLayoutConstraint!
    @IBOutlet weak var noGoodsView: UIView!
    
    
   
    var  pusVC:((_ good_id:Int) -> Void)?
    var page = 1
    var selectIndex = 0
    
    var isAn = false {
        didSet{
            if isAn{
               let num1 = ((self.childModel?.child_categories.count)! + 2)/4
               let num2 = ((self.childModel?.child_categories.count)! + 2)%4
                var num:CGFloat = 0.0
                if num2 == 0  {
                    num = CGFloat(num1 * 30 + (num1 + 1) * 10)
                }else{
                num = CGFloat((num1 + 1) * 30 + (num1 + 2) * 10)
                }
                self.headView.mj_h = num
                 noGoodsViewTop.constant = num
                 tableView.tableHeaderView = self.headView
            }else{
                var num:CGFloat = 0.0
                if (self.childModel?.child_categories.count)! > 3 {
                     num = CGFloat(2 * 30 + (2 + 1) * 10)
                }else{
                    num = CGFloat(30 + (1 + 1) * 10)
                }
                
                self.headView.mj_h = num
                noGoodsViewTop.constant = num
                tableView.tableHeaderView = self.headView
            }
                
            self.collectionView.reloadData()
        }
    
    }
    var childModel:childCategories?
    var goodsModelList:[goodsModel]?
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView.init()
        tableView.delegate = self
        
        loadMoreData(defaultCatId: childModel!.cat_id)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize.init(width: (UIScreenWidth - 54)/4, height: 30)
        collectionView.collectionViewLayout = layout
        collectionView.delegate  = self
        isAn = false
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

extension goodsCategoryVC{
    
    func collectionBatch(arr:[String]) -> Observable<Bool> {
        
        return dropsMallAddTokenProviderHUD.request(.collectionBatch(arr: arr))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .asObservable()
            .map{
                
                $0["status"]["code"].intValue == 200  
                
        }
    }
    func loadMoreData(defaultCatId:String) {
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            
            return Disposables.create()
        }
        
        
        let  data =   just.startWith(page).flatMapFirst{
            dropsMallAddTokenProvider.request(.goodsCategory(ID: defaultCatId,page: $0))
                .filter(statusCode: 200)
                .mapJSON()
                .map{
                    JSON.init($0)
                }
                .filter{
                    $0["status"]["code"].intValue == 200  
                }
                .map{
                    
                    $0["data"].arrayValue.map{
                        goodsModel.init(json: $0)
                    }
                    
                }.filter{ modelList in
                    self.tableView.mj_footer.endRefreshing()
                    
                    if self.page == 1{
                        
                        if modelList.count ==  0 {
                            
                          self.noGoodsView.isHidden = false
                        
                        }else{
                            self.noGoodsView.isHidden = true
                        }
                    
                    
                    }
                    
                    if modelList.count >  0 {
                        self.page = self.page + 1
                    }else{
                     self.tableView.mj_footer.endRefreshingWithNoMoreData()
                       
                        
                    }
                    return true
            }
            
        }
        
       
        
        data.scan([]){$0+$1}
            .filter{ arr in
                
                return true
            }.subscribe(onNext: { (goodsModelList) in
                self.goodsModelList = goodsModelList
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        
    }
    
    func loadData(cat_id:String,row:Int)  {
        selectIndex = row
        page = 1
        collectionView.reloadData()
        tableView.mj_footer.resetNoMoreData()
        loadMoreData(defaultCatId: cat_id)
    }

}
extension goodsCategoryVC:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.childModel!.child_categories.count > 7 {
            if isAn {
                return self.childModel!.child_categories.count + 2
            }
            return 8
        }
        return self.childModel!.child_categories.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goodsCategoryCollCell", for: indexPath) as! goodsCategoryCollCell
      
        if indexPath.item == 0 {
           cell.text = "全部"
            
        }else{
        
            if self.childModel!.child_categories.count > 7 {
                
                if isAn {
                    if indexPath.row > (self.childModel?.child_categories.count)!{
                        cell.text = "收起"
                    }else{
                        cell.text = self.childModel!.child_categories[indexPath.row - 1].cat_name
                    }
                    
                    
                }else{
                    if indexPath.row == 7{
                        cell.text = "更多"
                    }else{
                        cell.text = self.childModel!.child_categories[indexPath.row - 1].cat_name
                    }
                    
                }
                
            }else{
                
                cell.text = self.childModel!.child_categories[indexPath.row - 1].cat_name
                
                
                
            }
        }
        
       
       
        if indexPath.row == selectIndex {
            cell.name.textColor = UIColor.init(red: 50/255, green: 60/255, blue: 63/255, alpha: 1)
        }else{
            cell.name.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != selectIndex {
            
            if indexPath.item == 0 {

                self.loadData(cat_id: (self.childModel?.cat_id)!, row: 0)
            }else{
                
                if self.childModel!.child_categories.count > 7 {
                    
                    if isAn {
                        if indexPath.row > (self.childModel?.child_categories.count)!{
//                            cell.text = "收起"
                            isAn = false
                        }else{
                            self.loadData(cat_id: self.childModel!.child_categories[indexPath.row - 1].cat_id, row: indexPath.row)
//
                        }
                        
                        
                    }else{
                        if indexPath.row == 7{
//                            cell.text = "更多"
                             isAn = true
                        }else{
                            self.loadData(cat_id: self.childModel!.child_categories[indexPath.row - 1].cat_id, row: indexPath.row)
                        }
                        
                    }
                    
                }else{
                    

                     self.loadData(cat_id: self.childModel!.child_categories[indexPath.row - 1].cat_id, row: indexPath.row)
                    
                    
                }
            }
            
           
        }
       
    }

}

extension goodsCategoryVC:UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = goodsModelList else {
            return 0
        }
        
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goodsCategoryCell", for: indexPath) as! goodsCategoryCell
        cell.model = goodsModelList![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.pusVC!( goodsModelList![indexPath.row].goods_id )
        
    }


}
