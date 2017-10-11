//
//  couponsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/9/8.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class couponsCell: UITableViewCell {
    
    
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var coupon_name: UILabel!
    @IBOutlet weak var min_goods_amount: UILabel!
    @IBOutlet weak var coupon_money: UILabel!
    var model:couponsModel?{
    didSet{
        date.text = "有效期：" + model!.use_end_date + "-" + model!.use_end_date
       
        min_goods_amount.text = "满元\( model!.min_goods_amount)使用"
        coupon_name.text = model?.coupon_name
        coupon_money.text = model?.coupon_money
    
    }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    
    
}
import RxCocoa
import RxSwift
import SwiftyJSON
import MJRefresh
import PKHUD
class couponsVC: baseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noCouponsView: UIView!
    var modelList:[couponsModel] = []
    var page  = 1
    var selectCoupons:((_ model:couponsModel)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.tableView.delegate = self
        
        if  let _ = self.selectCoupons {
            self.getorderCouponInfo()
        }else{
         self.bindModel()
        }
       
        self.title = "优惠券"
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
extension couponsVC:UITableViewDelegate,UITableViewDataSource{


    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return modelList.count
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let block = self.selectCoupons else {
            return
        }
        block(modelList[indexPath.row])
        self.navigationController?.popViewController(animated: true);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "couponsCell", for: indexPath) as! couponsCell
        cell.model = self.modelList[indexPath.row]
        return cell
    }
    

}
extension couponsVC{
    
    
    func getorderCouponInfo()  {
        
        
        dropsMallAddTokenProviderHUD.request(.orderCoupon())
            .filter(statusCode: 200)
            .mapJSON()
            .map
            {
                JSON.init($0)
            }.filter{ json  in
                
                if json["status"]["code"].intValue != 200{
                    HUD.flash(.labeledError(title: nil, subtitle:  json["status"]["msg"].stringValue))
                    return false
                }
                
                return true
            }
            .map{
                
                $0["data"].arrayValue.map{
                    couponsModel.init(json: $0)
                }
                
            }.asObservable()
            .subscribe(onNext: { list in
                self.modelList = list
                if self.modelList.count == 0    {
                    self.noCouponsView.isHidden = false
                    return
                }

                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

    }
    func bindModel() {
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            self.tableView.mj_footer.isHidden = true
            return Disposables.create()
        }
        
        
        
        
        let  data =   just.startWith(page)
            .flatMapFirst{
                dropsMallAddTokenProviderHUD.request(.coupon(page: $0))
                    .filter(statusCode: 200)
                    .mapJSON()
                    .map{
                        JSON.init($0)
                    }
                    .filter{ json in
                        if json["status"]["code"].intValue != 200{
                            HUD.flash(.labeledError(title: nil, subtitle:  json["status"]["msg"].stringValue))
                            return false
                        }
                        
                        return true
                    }
                    .map{
                        
                        $0["data"].arrayValue.map{
                            couponsModel.init(json: $0)
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
            
            .subscribe(onNext: { (list) in
                self.modelList = list
                self.tableView.mj_footer.isHidden = false
                if self.modelList.count == 0{
                    self.noCouponsView.isHidden = false
                    return
                }
                self.tableView.reloadData()
                
            }, onError: nil, onCompleted: nil, onDisposed: {
                self.noNetwork(nil)
            })
            .addDisposableTo(disposeBag)
      
        
    }
}
struct couponsModel {
        
        let coupon_id:String
        let coupon_name:String
        let min_goods_amount:String
        let coupon_money:String
        let use_start_date:String
        let use_end_date:String
        let overdue:Int
        init(json:JSON) {
            coupon_id = json["coupon_id"].stringValue
            coupon_name = json["coupon_name"].stringValue
            min_goods_amount = json["min_goods_amount"].stringValue
            coupon_money = json["coupon_money"].stringValue
            use_start_date = json["use_start_date"].stringValue
            use_end_date = json["use_end_date"].stringValue
            overdue = json["overdue"].intValue
        }
}

