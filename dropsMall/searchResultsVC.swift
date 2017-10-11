//
//  searchResultsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/20.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import MJRefresh
class searchResultsVC: baseViewController{
    var goodModelList:[goodsModel]?{
        
        didSet{
            
            self.tableView.reloadData()
        }
    }
    var page = 1
    @IBOutlet weak var tableView: UITableView!
    var searchText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchGoods(name: self.searchText!)
        tableView.delegate = self
        tableView.tableFooterView = UIView.init()
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


extension searchResultsVC:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "goodsDetailsVC") as! goodsDetailsVC
        VC.goods_id = self.goodModelList?[indexPath.row].goods_id
        
        self.navigationController?.pushViewController(VC, animated: true)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let list = self.goodModelList {
            return list.count
        }
        return 0
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "goodsCategoryCell", for: indexPath) as! goodsCategoryCell
        cell.model = goodModelList![indexPath.row]
        return cell
        
        
        
        
        
    }
    
    
}

extension searchResultsVC{
    
    func searchGoods(name:String) {
        
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            
            return Disposables.create()
        }
        
        let  data = just.startWith(page).flatMapFirst{
            
            dropsMallAddTokenProvider.request(.searchGoods(goodName: name, page: $0))
                .filter(statusCode: 200)
                .mapJSON()
                .map{
                    JSON.init($0)
                }
    
                .map{
                    
                    $0.arrayValue.map{
                        goodsModel.init(json: $0)
                    }
                    
                }.filter{ modelList in
                    self.tableView.mj_footer.endRefreshing()
                    if modelList.count >  0{
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
                self.goodModelList = goodsModelList
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
    
    
}

