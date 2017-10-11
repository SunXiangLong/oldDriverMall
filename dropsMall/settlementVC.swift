//
//  settlementVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/18.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import IBAnimatable
class settlementGoodsCell: UITableViewCell {
    
    @IBOutlet weak var goods_price: UILabel!
    @IBOutlet weak var goods_img: UIImageView!
    @IBOutlet weak var goods_number: UILabel!
    @IBOutlet weak var goods_name: UILabel!
    
    var mode:shoppingCartModel?{
        didSet{
            goods_price.text = "￥" +  mode!.goods_price!
            goods_img.setImage(with: mode?.goods_img)
            goods_number.text =  "X\(mode!.goods_number!)"
            goods_name.text = mode?.goods_name
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    
}


class settlementCell: UITableViewCell {
    let disposeBag = DisposeBag()
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var nextImage: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var name: UILabel!
    var noteBlock:((_ text:String) -> Void)?
    var dic: [String:String]?{
        didSet{
            noteTextField.delegate = nil
            name.text = dic!["text"];
            price.text = dic!["price"]
            switch dic!["type"]! {
            case "1":
                nextImage.isHidden = true
                noteTextField.isHidden = true
                price.isHidden = false
                type.isHidden = true
            case "2":
                nextImage.isHidden = false
                price.isHidden = true
                noteTextField.isHidden = true;
                type.isHidden = false
                type.text = dic!["price"]
            case "3":
                nextImage.isHidden = true
                noteTextField.isHidden = false;
                noteTextField.delegate = self
                price.isHidden = true
                type.isHidden = true
            default:break
                
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
extension settlementCell:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.noteBlock!(textField.text!)
        return true
    }



}
class settlementVC:baseViewController {
     var textField:UITextField?
     var voucher:voucherModel?
    var  address_id :Int?
    @IBOutlet weak var addAddress: UILabel!
    @IBOutlet weak var totalAmountOfPayment: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var consignee: UILabel!
    @IBOutlet weak var adressCenter: UILabel!
    @IBOutlet weak var addressMobile: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var  listDic:[[String:String]]?
    var coupon_id =  "0"
    var settlementModel:settlementCheckoutModel?{
        didSet{
            
            if let table =  self.tableView{
              
                
               
                listDic =      [
                    ["text":"商品合计：","type":"1","price":settlementModel!.amount!.total_goods_price!],
                    ["text":"运费：","type":"1","price":settlementModel!.amount!.total_shipping_price!],
                    ["text":"使用优惠券","type":"2","price": settlementModel?.coupon?.coupon_name ?? ""],
                    ["text":"使用电子购物券","type":"2","price":voucher?.voucher_name ?? ""],
                    
                    ["text":"备注：","type":"3","price":""]
                ]
                 setBottomView()
                table.reloadData()
            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setBottomView()
        tableView.delegate = self
        tableView.tableFooterView = UIView.init()
        coupon_id  = self.settlementModel!.coupon!.coupon_id
        listDic =      [
            ["text":"商品合计：","type":"1","price":settlementModel!.amount!.total_goods_price!],
            ["text":"运费：","type":"1","price":settlementModel!.amount!.total_shipping_price!],
            ["text":"使用优惠券","type":"2","price": settlementModel?.coupon?.coupon_name ?? ""],
            ["text":"使用电子购物券","type":"2","price":voucher?.voucher_name ?? ""],
            
            ["text":"备注：","type":"3","price":""]
        ]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitOrders(_ sender: Any) {
       
        
        orderCreat()
        
    }
    
    @IBAction func selectTheAddress(_ sender: Any) {
    
        self.performSegue(withIdentifier: "addressManagementVC", sender: nil)
        
     
    }
   
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if let ident = segue.identifier {
           
            switch ident {
            case "addressManagementVC":
                let VC = segue.destination as! addressManagementVC
                VC.selectTheAddress = { address_id in
                    self.address_id = address_id
                    self.checkout( String(address_id) , voucher: "", coupon_id: self.coupon_id)
                        .subscribe(onNext: { model in
                            
                           self.settlementModel = model
                            
                            
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(self.disposeBag)
                }
             case "payVC":
                let VC = segue.destination as! payVC
                let json = sender as! JSON
                VC.orderSn = json["order_sn"].stringValue
                VC.isSuccess = json["order_payed"].boolValue
                

            default:
                break
            }
            
            
        }
     }
    
    
}
extension settlementVC{
    
    func setBottomView()  {
         var order_amount = settlementModel?.amount?.total_order_amount?.replacingOccurrences(of: "¥", with: "")
    
        if let str = voucher?.voucher_amount {
            
//            let order_amount = settlementModel?.amount?.total_order_amount?.replacingOccurrences(of: "¥", with: "")
            
            let order_amount_doub = Double.init(order_amount!)
            let str_doub = Double.init(str)
            let doub = order_amount_doub! - str_doub!
            if doub > 0 {
               order_amount = String.init(doub)
            }else{
                order_amount = "0.00"
            }
            
        }
        totalAmountOfPayment.text = "应付金额：￥" + order_amount!
        consignee.text = settlementModel?.address?.consignee
        adressCenter.text = settlementModel?.address?.address
        addressMobile.text = settlementModel?.address?.mobile
        if  settlementModel?.address?.address_id != "" {
            addAddress.isHidden = true
           
        }else{
            addAddress.isHidden = false
        }
        
    }
    func orderCreat() {
        dropsMallAddTokenProviderHUD.request(.orderCreate(address_id: self.settlementModel!.address!.address_id!, remark: self.listDic!.last!["price"]!, voucher: self.textField?.text ?? "",coupon_id:self.coupon_id))
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
                
                $0["data"]
                
            }
            .asObservable()
            .subscribe(onNext: { data in
                
                self.performSegue(withIdentifier: "payVC", sender: data)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

    }
    func checkVoucher(){
        
        dropsMallAddTokenProviderHUD.request(.orderCheckVoucher(voucher: self.textField!.text!))
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
               
                voucherModel.init(json: $0["data"])
                
        }
            .asObservable()
            .subscribe(onNext: { model in
            self.voucher = model
            
            self.checkout( String(describing: self.address_id ) , voucher: model.voucher_name!, coupon_id: self.coupon_id)
                .subscribe(onNext: { model in
                    
                    self.settlementModel = model
                    
                    
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(self.disposeBag)
           
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(disposeBag)
        
        
    }
}
extension settlementVC:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if settlementModel!.checkout!.count  >  indexPath.section  {
            return 130
        }
        return 44
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if settlementModel!.checkout!.count  > section  {
            let  view = AnimatableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreenWidth, height: 44))
            view.borderColor = UIColor.init(hexString: "e6e6e8")
            view.borderWidth   = 0.5
            view.borderSides = [.bottom ,.top]
            view.backgroundColor = UIColor.white
            
            let lable = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: UIScreenWidth - 15, height: 44))
            lable.textColor = UIColor.init(hexString: "454545")
            lable.font = UIFont.init(name: "Microsoft YaHei", size: 14)
            lable.text = settlementModel?.checkout?[section].supplier_name
            view.addSubview(lable)
            return view
        }
        return nil
        
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if settlementModel!.checkout!.count  > section {
            let  view = AnimatableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreenWidth, height: 44))
            view.borderColor = UIColor.init(hexString: "e6e6e8")
            view.borderWidth   = 0.5
            view.borderSides = [.bottom ,.top]
            view.backgroundColor = UIColor.white
            
            let lable = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: (UIScreenWidth - 30) * 0.5, height: 44))
            lable.textColor = UIColor.init(hexString: "454545")
            lable.font = UIFont.systemFont(ofSize: 10)
            lable.text =  "运费：" + settlementModel!.checkout![section ].shipping_amount!
            view.addSubview(lable)
            let lable1 = UILabel.init(frame: CGRect.init(x: (UIScreenWidth - 30) * 0.5 + 15, y: 0, width: (UIScreenWidth - 30) * 0.5, height: 44))
            lable1.textAlignment = .right
            lable1.textColor = UIColor.init(hexString: "ef8702")
            lable1.font = UIFont.systemFont(ofSize: 10)
            lable1.text =  "小计：" + settlementModel!.checkout![section  ].total_goods_amount!
            view.addSubview(lable1)
            return view
        }
        
        return nil
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if settlementModel!.checkout!.count  > indexPath.section {
            
        }else{
        
            if indexPath.row == 3 {
                
               
                let alerview = UIAlertController.init(title: "提示", message: "请输入要使用的兑换券", preferredStyle: .alert)
                alerview.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { _ in
                    
                }))
                alerview.addTextField(configurationHandler: { (textField) in
                    self.textField = textField
                })
                alerview.addAction(UIAlertAction.init(title: "使用", style: .default, handler: { _ in
                    self.checkVoucher()
                }))
                
                self.present(alerview, animated: true, completion: nil)
                
        
            }else if indexPath.row == 2 {
          
                let VC = UIStoryboard.init(name: "PersonalCenter", bundle: nil).instantiateViewController(withIdentifier: "couponsVC") as!  couponsVC
                VC.selectCoupons = {[unowned self]  model in
                    self.settlementModel?.coupon = model
                    self.coupon_id = model.coupon_id
                
                }
                self.navigationController?.pushViewController(VC, animated: true)
            
            
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if settlementModel!.checkout!.count > section  {
            return  44
        }
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if  settlementModel!.checkout!.count > section {
            return 44
        }
        return 0.001
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let rootModel = settlementModel else {
            return 0
        }
        
        return rootModel.checkout!.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if settlementModel!.checkout!.count > section{
            return settlementModel!.checkout![section].cart_goods!.count
        }
        if let list = listDic{
        
        return list.count
        
        }
        return 0
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if settlementModel!.checkout!.count > indexPath.section {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "settlementGoodsCell", for: indexPath) as! settlementGoodsCell
            cell.mode = settlementModel!.checkout![indexPath.section].cart_goods?[indexPath.row]
            return cell
            
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "settlementCell", for: indexPath) as! settlementCell
        cell.dic = listDic?[indexPath.row]
        cell.noteBlock = { text in
            if indexPath.row == 3 {
                var dic   =   self.listDic?.last
                dic?["price"] = text
                self.listDic?[3] = dic!
                self.tableView.reloadData()
                
            }
            }
         
        return cell
        
        
        
        
        
    }
}
struct settlementCheckoutModel {
    let  amount: amountModel?
    var  coupon: couponsModel?
    let  checkout: [checkoutModel]?
    
    let  address: addressModel?
    
    init(json:JSON) {
        checkout = json["checkout"].arrayValue.map{
            checkoutModel.init(json: $0)
        }
        amount = amountModel.init(json: json["amount"])
        coupon = couponsModel.init(json: json["coupon"])
        address =  addressModel.init(json: json["address"])
    }
}

struct amountModel {
    
    let voucher_amount: String?
    
    let total_shipping_price: String?
    
    let total_goods_price: String?
    
    let total_order_amount: String?
    
    init(json:JSON) {
        voucher_amount  = json["voucher_amount"].stringValue
        total_shipping_price  = json["total_shipping_price"].stringValue
        total_goods_price  = json["total_goods_price"].stringValue
        total_order_amount  = json["total_order_amount"].stringValue
        
    }
}
struct voucherModel{
    let voucher_amount:String?
    let voucher_name:String?
    init(json:JSON) {
        voucher_amount  = json["voucher_amount"].stringValue
        voucher_name  = json["voucher_name"].stringValue
    }

}
struct checkoutModel  {
    
    let supplier_id: String?
    
    let shipping_amount: String?
    
    let supplier_name: String?
    
    let cart_goods: [shoppingCartModel]?
    
    let total_goods_amount: String?
    
    init(json:JSON) {
        supplier_id  = json["supplier_id"].stringValue
        shipping_amount  = json["shipping_amount"].stringValue
        supplier_name  = json["supplier_name"].stringValue
        cart_goods  = json["cart_goods"].arrayValue.map{
            shoppingCartModel.init(json: $0)
        }
        total_goods_amount  = json["total_goods_amount"].stringValue
    }
    
}




