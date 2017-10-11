




//
//  payVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/19.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import IBAnimatable

class payVC: baseViewController {

    @IBOutlet weak var wxChatPayView: AnimatableView!
    @IBOutlet weak var wxChatPayBtn: UIButton!
    @IBOutlet weak var payForResultsView: UIView!
    @IBOutlet weak var alipayBtn: UIButton!
    @IBOutlet weak var order_sn: UILabel!
    @IBOutlet weak var price: UILabel!
    var data:JSON?
    var isSuccess = false
    var orderSn:String?
    var isAlipay = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WXApi.isWXAppInstalled() {
            wxChatPayView.isHidden = false
        }
        
        if isSuccess {
            self.payForResultsView.isHidden = false
        }
        
        let text = "订单号：" + orderSn!

        order_sn.text =   text
        
        getPayInfo()
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "AlipayPay"), object: nil).subscribe(onNext: {[unowned self]  (Notification) in
           self.payResults(resultDic: Notification.userInfo)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "WxPay"), object: nil).subscribe(onNext: {  (Notification) in
           
            self.payResults(resultDic: Notification.userInfo)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
    }

    @IBAction func payType(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            if !sender.isSelected {
                sender.isSelected = true
                wxChatPayBtn.isSelected = false
                isAlipay = true
            }
        case 1:
            if !sender.isSelected {
                sender.isSelected = true
                alipayBtn.isSelected = false
                isAlipay = false
            }
        default:break
            
        }
    }
    @IBAction func showOrder(_ sender: Any) {
        let btn = sender as! UIButton
        
        let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
        
        switch btn.tag {
        case 0:
            VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/orders/2")
            VC.title = "代发货"
        default:
            VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/orders/1")
            VC.title = "待付款"
        }
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @IBAction func pay(_ sender: Any) {
        if isAlipay {
            AlipaySDK.defaultService().payOrder(self.data?["pay_code"].stringValue, fromScheme: "dropsMallAPP", callback: {[unowned self]  (resultDic) in
               
                self.payResults(resultDic: resultDic)
                
            })
        }else{
        
            self.getWXChatPayinfo().subscribe(onNext: { (model) in
                
              WXApi.send(model)
                
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
           
            
        }
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func back() {
        self.navigationController?.popToRootViewController(animated: true)
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
extension payVC{

    func prompt(text:String,isSuccess:Bool)  {
        
        let alert = UIAlertController.init(title: "提示", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: isSuccess ? "确定":"取消", style: .cancel, handler: {[unowned self]  (UIAlertAction) in
            
            if isSuccess {
                self.payForResultsView.isHidden = false
                self.title = "支付结果"
            
            }
        }))
       
        self.present(alert, animated: true, completion: nil)
        
    }
    func payResults(resultDic:[AnyHashable:Any]?)  {
        
        
        if isAlipay {
            let  code = resultDic?["resultStatus"] as! String
            if code == "9000"{
                self.prompt(text: "支付成功", isSuccess: true)
            }else{
                let errorStr =  resultDic?["memo"]  as! String
                self.prompt(text: errorStr, isSuccess: false)
            }
        
        }else{
      
         let  code = resultDic?["errcode"] as! Int
         let dic = [0:"支付成功",-1:"失败",-2:"用户点击取消",-3:"发送失败",-4:"授权失败",-5:"微信不支持"]
            if dic[code] != nil {
                if code == 0{
                    self.prompt(text: "支付成功", isSuccess: true)
                }else{
                    self.prompt(text: dic[code]!, isSuccess: false)
                }
            }
        
        
        }
    }
    func getWXChatPayinfo() -> Observable<wxChatPatModel> {
      return  dropsMallAddTokenProviderHUD.request(.wxChatPay(parent_order_sn: orderSn!))
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
            .asObservable()
            .map{
                
              wxChatPatModel.init(json: $0["data"]["pay_code"])
                
        }
    }
    func getPayInfo()  {
        
        dropsMallAddTokenProviderHUD.request(.pay(parent_order_sn:orderSn!))
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
            .subscribe(onNext: { [unowned self]  data in
                log.debug(data)
                self.data = data
                self.price.text =  "支付总金额：" + data["total_amount"].stringValue
               
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }




}
class wxChatPatModel: PayReq {
    
    init(json:JSON) {
        super.init()
        self.openID = json["appid"].stringValue
        self.partnerId = json["partnerid"].stringValue
        self.prepayId = json["prepayid"].stringValue
        self.package = json["package"].stringValue
        self.nonceStr = json["noncestr"].stringValue
        self.sign = json["sign"].stringValue
        self.timeStamp = UInt32(json["timestamp"].intValue)
    }
}
