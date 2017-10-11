//
//  shoppingCartVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/17.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import RxDataSources
import PKHUD
import IBAnimatable
import MJRefresh

class shoppingCartCell: UITableViewCell {
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var goodsNum: UILabel!
    @IBOutlet weak var goodsPrice: UILabel!
    @IBOutlet weak var goodsName: UILabel!
    @IBOutlet weak var goodImage: UIImageView!
    var tap:((_ row:Int, _ model:shoppingCartModel,_ isSelect:Bool)-> Void)?
    var row:Int?
    var model:shoppingCartModel?{
        didSet{
        
            goodImage.setImage(with: model?.goods_img)
            goodsNum.text = model?.goods_number?.description
            goodsPrice.text = "￥" + model!.goods_price!
            goodsName.text = model?.goods_name
            selectBtn.isSelected = model!.flow_order!
            
        }
    
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func isSelect(_ sender: UIButton) {
      var type = "1"
        if self.model!.flow_order!{
          type = "0"
        }
        let int = Int.init(self.model!.goods_id!)
        
        UIViewController.cartGoodsIsSelect(goods_ids: JSON.init([int]) , tyop:type )
            .subscribe(onNext: { json in
                
                
                if json["code"].intValue == 200{
//                    HUD.flash(.labeledSuccess(title: nil, subtitle: json["msg"].stringValue), delay: 1.0, completion: nil)
                    
                    self.model!.flow_order = !self.model!.flow_order!
                    self.tap!(self.row!,self.model!, true)
                   
                    return
                    
                    
                }
                HUD.flash(.labeledError(title: nil, subtitle: json["msg"].stringValue),  delay: 1.0, completion: nil)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
       
        
    }
    @IBAction func add(_ sender: Any) {
       
        goodNumber(model: self.model!,isAdd: true)
       
    }
    @IBAction func reductionOf(_ sender: Any) {
        
        goodNumber(model: self.model!,isAdd: false)
        
         self.tap!(row!,self.model!, false)
        
    }
     let disposeBag = DisposeBag()
    func goodNumber(model:shoppingCartModel,isAdd:Bool) {
        
        let num =  model.goods_number!
        UIViewController.addGoodsToCart(gooods_id: Int.init(model.goods_id!)! , goods_number: isAdd ? (num  + 1):(num - 1))
            .subscribe(onNext: { json in
                
                
                if json["code"].intValue == 200{
                    HUD.flash(.labeledSuccess(title: nil, subtitle: json["msg"].stringValue), delay: 1.0, completion: nil)
                    
                    if isAdd{
                        self.model?.goods_number =  num + 1
                    }else{
                        self.model?.goods_number =  num - 1
                    }
                     self.tap!(self.row!,self.model!, false)
                    
                    return
                    
                }
                HUD.flash(.labeledError(title: nil, subtitle: json["msg"].stringValue),  delay: 1.0, completion: nil)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
class shoppingCartVC:  baseViewController{
    
    @IBOutlet weak var noCarGoodView: UIView!
    @IBOutlet weak var combined: UILabel!
    @IBOutlet weak var selectAll: UIButton!
    @IBOutlet weak var toSettleAccounts: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var model :[shoppingCartModel]?{
        didSet{
            shoppingCartPrice()
           
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCartList()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backRoot(_ sender: Any) {
        if self.tabBarController?.selectedIndex == 0    {
        
            self.navigationController?.popToRootViewController(animated: true)
        }else{
             self.tabBarController?.selectedIndex = 0
             self.navigationController?.popViewController(animated: true)
            
//
            
        }
        
       
        
    }
    @IBAction func toSelectAll(_ sender: Any) {
        

        let intArr = model!.map{
           Int.init($0.goods_id!)
        }

        var type = "1"
        
        if selectAll.isSelected {
            type = "0"
        }
        
        
        UIViewController.cartGoodsIsSelect(goods_ids: JSON.init(intArr) , tyop:type )
            .subscribe(onNext: { json in
                
                
                if json["code"].intValue == 200{
                    self.model =   self.model!.map{ list in
                        var data = list
                        data.flow_order = type == "1"  
                      
                        return data
                    }
                    self.tableView.reloadData()
                    return
                    
                    
                }
                HUD.flash(.labeledError(title: nil, subtitle: json["msg"].stringValue),  delay: 1.0, completion: nil)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
        
        shoppingCartPrice()
        tableView.reloadData()
        
    }
    
    
    @IBAction func toSettleAccounts(_ sender: Any) {
        
        self.checkout("0", voucher: "", coupon_id: "0")
            .subscribe(onNext: { model in
                
                self.performSegue(withIdentifier: "settlementVC", sender: model)
          
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if let  iden = segue.identifier  {
            switch iden {
            case "settlementVC":
                let VC = segue.destination  as! settlementVC
                VC.settlementModel = sender as? settlementCheckoutModel
            default:break
            }
        }
     }
 
    
}
extension shoppingCartVC{
    func shoppingCartPrice(){
      
        var issss = true
        var isaaa = false
        var  totalPrice = 0.00
        var totalNum = 0
        for item in self.model! {
            if item.flow_order! {
                totalPrice  = totalPrice + Double(item.goods_price!)! * Double(item.goods_number!)
                totalNum = item.goods_number! +  totalNum
            }
            if !item.flow_order! {
                issss = false
            }
            
            if item.flow_order! {
                isaaa = true
            }
        }
        if isaaa {
             toSettleAccounts.backgroundColor = UIColor.init(hexString: "ee8704")
            toSettleAccounts.isEnabled = true
        }else{
            toSettleAccounts.backgroundColor = UIColor.gray
            toSettleAccounts.isEnabled = false
        }
       
       
        combined.text = "合计：￥" + "\(totalPrice)"
        selectAll.isSelected = issss
        toSettleAccounts.setTitle("去结算(\(totalNum))", for: .normal)
        
    }
    func getCartList() {
        
        dropsMallAddTokenProviderHUD.request(.getCartList)
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            
            .filter{ json in
                if json["status"]["code"].intValue == 200{
                 return true
                    
                }
                
                HUD.flash(.labeledError(title: "提示", subtitle:  json["status"]["msg"].stringValue), delay: 1.0, completion: nil)
                return  false
            }
            .map{
                
                $0["data"].arrayValue.map{
                    shoppingCartModel.init(json: $0)
                }
                
            }
            .asObservable()
            .subscribe(onNext: { data in
        
                self.model = data
                if data.count > 0{
                
                 self.tableView.reloadData()
                }else{
                    self.noCarGoodView.isHidden = false
                }
               
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    func deleteCartGoods(goods_id:Int,row:Int) {
        dropsMallAddTokenProviderHUD.request(.deleteCareGoods(goods_id: JSON.init([goods_id])))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                $0["status"]["code"].intValue == 200  
            }
            .map{
                
                $0["status"]                
            }
            .asObservable()
            .subscribe(onNext: { status in
                
                if status["code"].intValue == 200{
                    HUD.flash(.labeledSuccess(title: nil, subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                    self.model?.remove(at: row)
                    if self.model?.count == 0 {
                    
                        self.noCarGoodView.isHidden = false
                    }
                    self.tableView.reloadData()
                }else{
                    HUD.flash(.labeledError(title: "提示", subtitle: status["msg"].stringValue), delay: 1.0, completion: nil)
                }
               
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    
    
    
}
extension shoppingCartVC:UITableViewDataSource,UITableViewDelegate{
    
    

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        
        let deleteRowAction = UITableViewRowAction.init(style: .destructive, title: "删除") { (action, indexPath) in
            self.deleteCartGoods(goods_id: Int.init(self.model![indexPath.row].goods_id!)! , row: indexPath.row)
        }
        let moreRowAction = UITableViewRowAction.init(style: .normal, title: "收藏") { (action, indexPath) in
             self.collection(goods_id: Int.init(self.model![indexPath.row].goods_id!)!, big: self.disposeBag)
        }
        
        return [deleteRowAction,moreRowAction]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = model   {
        return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCartCell", for: indexPath) as! shoppingCartCell
        cell.model = self.model?[indexPath.row]
        cell.row = indexPath.row
        cell.tap = { row,data,isSelect  in
            
            
            self.model?[row] = data
            self.shoppingCartPrice()
            self.tableView.reloadRows(at: [IndexPath.init(item: row, section: 0)], with:.automatic)
        }
        return cell
    }
    
}

struct shoppingCartModel {
    let goods_id:String?
    let goods_sn:String?
    let goods_name:String?
    var goods_img:URL?
    var goods_number:Int?
    let goods_attr:String?
    var flow_order:Bool?
    let goods_price:String?
    
     let goods_weight:String?
     let market_price:String?
    
    init(json:JSON) {
        goods_id = json["goods_id"].stringValue
        goods_sn = json["goods_sn"].stringValue
        goods_name = json["goods_name"].stringValue
        goods_img = json["goods_img"].url
        goods_number = json["goods_number"].intValue
        goods_attr = json["goods_attr"].stringValue
        flow_order = json["flow_order"].intValue == 1  
        goods_price = json["goods_price"].stringValue
        market_price = json["market_price"].stringValue
        goods_weight = json["goods_weight"].stringValue
        
       

    }
    
}
