//
//  addAddressVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/13.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import KYNavigationProgress
import JavaScriptCore
import WebKit
import PKHUD
import SwiftyJSON
class addAddressVC: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    var refreshTheAddress:(()->Void)?
    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = try? URLRequest.init(url: url!, method:.get, headers: ["accessToken":userInfo.user.token!] )
        webView.loadRequest(request!);
       
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
extension addAddressVC : UIWebViewDelegate{
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
            
            jsmodel.response = { message  in
                DispatchQueue.main.async {
                switch message {
                case .response(let text):
                    let json = JSON.init(parseJSON: text)
                    
                    HUD.flash(.label(json["status"]["msg"].stringValue))
                    if json["status"]["code"].intValue == 200 {
                        self.refreshTheAddress!()
                        
                        DispatchQueue.main.async(execute: {
                            
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                    
                    
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
                log.debug("----------------->>>>>>")
            }
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    
        self.navigationController?.cancelProgress()
      
    }
}

@objc protocol SwiftJavaScriptDelegate:JSExport {
    
    //编辑地址
    func app_response(_ response:String)
    //查看商品详情
    func showGood(_ response:String)
    //查看订单详情
    func showOrderDetail(_ response:String)
    //查看物流
    func showLogistic(_ response:String)
    //去评论
    func goComent(_ response:String)
    //申请退换货
    func afterSale(_ response:String)
    //去支付
    func goPay(_ response:String)
    //填写运单号
    func filllogistic(_ response:String)
    //填写运单号
    func checkRefund(_ response:String)
    
    
    /// 去登陆
    func showLogin()
    
    /// 去购物车
    func showCart()
    
    /// 添加到购物车
    func showCartConfirm()
    
    /// 查看订单
    ///
    /// - Parameter response: 参数 加载https://api.laosijivip.xiaomabao.com/web/orders/response
    func showOrderList(_ response:String)
}
enum webJsFunType {
    case response(text:String)
    case showGood(text:String)
    case showOrderDetail(text:String)
    case showLogistic(text:String)
    case goComent(text:String)
    case afterSale(text:String)
    case goPay(text:String)
    case filllogistic(text:String)
    case checkRefund(text:String)
    case showLogin()
    case showCart()
    case showCartConfirm()
    case showOrderList(text:String)
    
    
}
@objc  class MMJSModel: NSObject,SwiftJavaScriptDelegate {
    /// 去登陆
    func showLogin() {
        self.response!(.showLogin())
    }

    /// 查看订单
    ///
    /// - Parameter response: 参数 加载https://api.laosijivip.xiaomabao.com/web/orders/response
    func showOrderList(_ response: String) {
        self.response!(.showOrderList(text: response))
    }

    /// 添加到购物车
    func showCartConfirm() {
        self.response!(.showCartConfirm())
    }

    /// 去购物车
    func showCart() {
        self.response!(.showCart())
    }

    

    


    weak var controller: UIViewController?
    
    weak var jsContext:JSContext?
    
    var response:((_ type: webJsFunType) ->Void)?
   
    func showGood(_ response: String) {
       
        self.response!(.showGood(text: response))
    }
    func app_response(_ response: String) {
    
        self.response!(.response(text: response))
    }
    
    func goComent(_ response: String) {
        self.response!(.goComent(text: response))
    }
    
    func showLogistic(_ response: String) {
        self.response!(.showLogistic(text: response))
    }
    
    func showOrderDetail(_ response: String) {
        self.response!(.showOrderDetail(text: response))
    }
    
    func goPay(_ response: String) {
        self.response!(.goPay(text: response))
    }
    
    func afterSale(_ response: String) {
        self.response!(.afterSale(text: response))
    }
    func filllogistic(_ response: String) {
        self.response!(.filllogistic(text: response))
    }
    func checkRefund(_ response: String) {
        self.response!(.checkRefund(text: response))
    }

}
