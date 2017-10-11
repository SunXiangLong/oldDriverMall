//
//  activityWebVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/15.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//



import UIKit
import JavaScriptCore
import SwiftyJSON
import PKHUD
class activityWebVC:  baseViewController{
    var isPopToRoot = false
    @IBOutlet weak var webView: UIWebView!
    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRqquest()
        
        // Do any additional setup after loading the view.
    }
    func loadRqquest() {
        if let url1 = url {
            
            let request = try? URLRequest.init(url: url1, method:.get, headers: ["accessToken":userInfo.user.token ?? ""] )
            webView.loadRequest(request!);
        }
    }
    override func back() {
        
        if isPopToRoot {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if let   ident = segue.identifier{
            switch ident {
            case "afterSalesServiceVC":
                let VC = segue.destination as! afterSalesServiceVC
                VC.parent_order_sn = sender as? String
            case "goodsCommentsVC":
                    let VC = segue.destination as! goodsCommentsVC
                    VC.parent_order_sn = sender as? String
            case "shippingOrderVC":
                let VC = segue.destination as! shippingOrderVC
                VC.order_id = sender as? Int
            default:break
            }
        
        }
     }
 
    
}
extension activityWebVC : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.navigationController?.progress = 0.5

        
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        return true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.navigationController?.finishProgress()
        let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let jsmodel = MMJSModel()
        jsmodel.response = { type  in
            
            DispatchQueue.main.async {
                switch type {
                case .showGood(let text):
                    let json = JSON.init(parseJSON: text)
                    let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "goodsDetailsVC") as! goodsDetailsVC
                    VC.goods_id = json["params"].intValue
                    self.navigationController?.pushViewController(VC, animated: true)
                case .showOrderDetail(let text):
                    let json = JSON.init(parseJSON: text)
                    let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                    VC.url = json["params"].url
                    VC.title = json["title"].stringValue
                    self.navigationController?.pushViewController(VC, animated: true)
                case .showLogistic(let text):
                    let json = JSON.init(parseJSON: text)
                    let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                    VC.url =   json["params"].url
                    VC.title = json["title"].stringValue
                    self.navigationController?.pushViewController(VC, animated: true)
                    log.debug(text)
                case .goComent(let text):
                    log.debug(text)
                    self.performSegue(withIdentifier: "goodsCommentsVC", sender: JSON.init(parseJSON: text)["params"].stringValue)
                    
                case .afterSale(let text):
                    self.performSegue(withIdentifier: "afterSalesServiceVC", sender: JSON.init(parseJSON: text)["params"].stringValue)
                case .goPay(let text):
                    let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "payVC") as! payVC
                    VC.orderSn = JSON.init(parseJSON: text)["params"].stringValue
                    self.navigationController?.pushViewController(VC, animated: true)
                case .filllogistic(let text):
                    log.debug(text)
                    self.performSegue(withIdentifier: "shippingOrderVC", sender: JSON.init(parseJSON: text)["params"].intValue)
                case .checkRefund(let text):
                    let json = JSON.init(parseJSON: text)
                    let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                    VC.url =   json["params"].url
                    VC.title = json["title"].stringValue
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                case .showCart():
                    let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "shoppingCartVC") as! shoppingCartVC
                    
                    self.navigationController?.pushViewController(VC, animated: true)
                case .showCartConfirm():
                    HUD.flash(.labeledSuccess(title: nil, subtitle: "加入购物车成功"), delay: 1)
                case .showOrderList(let text):
                    
                    
                    let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                    VC.url =  URL.init(string: api_live + "/web/orders/\(text)")
                    VC.title = "我的订单"
                    self.navigationController?.pushViewController(VC, animated: true)
                case .showLogin():
                    let VC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! loginVC
                    VC.hidesBottomBarWhenPushed = true
                    VC.refreshUI = {[unowned self]  in
                        
                        self.loadRqquest()
                        
                    }
                    self.navigationController?.pushViewController(VC, animated: true)
                default:
                    break
                }
            }
            
            

            
        }
        jsmodel.controller = self
        jsmodel.jsContext = context
        context!.setObject(jsmodel, forKeyedSubscript: "mallapp" as (NSCopying & NSObjectProtocol)!)
        let curUrl = webView.request?.url?.absoluteString  //WebView当前访问页面的链接 可动态注册
        context!.evaluateScript(try? String(contentsOf: URL.init(string: curUrl!)!, encoding: String.Encoding.utf8))
        context!.exceptionHandler =  { (context, exception) in
//            log.debug("----------------->>>>>>")
        }
        
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.navigationController?.cancelProgress()
        
    }
}
