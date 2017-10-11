//
//  baseTabBarViewController.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/17.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import SwiftyRSA
private  let UNICALL_APPKEY = "1B87EB48-A866-4A9A-9BA5-44CBCCC0D871"
private  let UNICALL_TENANID = "xiaomabao.yunkefu.com"

class baseTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        Unicall.singleton().attach(self, appKey: UNICALL_APPKEY, tenantId: UNICALL_TENANID)
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


extension baseTabBarViewController:UnicallDelegate{
    
    //    -(void) UnicallShowView:(NSDictionary*)data;
    //    -(void) UnicallHideView:(NSDictionary*)data;
    
    func acquireValidation() {
        let  formatter = DateFormatter.init()
        
        formatter.date(from: "yyy-MM-dd'T'HH:mm:ssZZZZZ")
        let tenantId =  UNICALL_TENANID
        let appKey = UNICALL_APPKEY
        let time = formatter.string(from: Date.init())
        let expireTime = "60000"
        let  stringToSign = appKey + expireTime + tenantId + time
        
        var  clear:ClearMessage?
        let privateKey = try? PrivateKey(pemNamed: "private")
        
        let encrypted = try? EncryptedMessage(base64Encoded: stringToSign)
        do {
            try clear =  encrypted?.decrypted(with: privateKey!, padding: .PKCS1SHA256)
        } catch  {
            log.error(error)
        }
        
        //
        //        let data  = clear?.data
        //        let base = clear?.base64String
        //        log.debug(base)
        //        log.debug(data)
        let string = try? clear?.string(encoding: .utf8)
        
        log.debug(string)
        
        let json = ["appKey":appKey,"expireTime":expireTime,"signature":string,"tenantId":tenantId,"time":time]
        
        Unicall.singleton().unicallUpdateValidation(json)
        
        if let name =  userInfo.user.username {
            Unicall.singleton().unicallUpdateUserInfo(["nickname":name])
        }else{
            Unicall.singleton().unicallUpdateUserInfo(["nickname":"游客"])
        }
    }
    func messageCountUpdated(_ data: NSNumber!) {
        
        
    }
    func messageArrived(_ data: [AnyHashable : Any]!) {
        
        
        //        self.tabBar.isHidden = false
        
    }
    func currentViewController() -> UIViewController! {
        
        
        if UIViewController.topViewController()?.classForCoder == personalCenterVC.classForCoder(){
            
            return self
        }
        
        return  UIViewController.topViewController()
    }
    
    
}
import RxSwift
import RxCocoa
import SwiftyJSON
import PKHUD
import IQKeyboardManagerSwift
extension UIViewController {
    
    
    func setPhoneCode(_ phone:String,_ big:DisposeBag)  {
        
        self.view.endEditing(false)
        
        dropsMallAddTokenProviderHUD.request(.authSendcode(mobil: phone))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .map{
                $0
            }
            .asObservable()
            .subscribe(onNext: { data in
                
                
                if data["status"]["code"].intValue   == 200{
                    
                    
                    HUD.flash(.labeledSuccess(title: nil, subtitle: "已发送, 请注意查收"), onView: self.view, delay: 1.0, completion: nil)
                    
                    
                }else{
                    HUD.flash(.labeledError(title: nil, subtitle: data["status"]["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(big)
        
        
        
        
    }
    
    func checkout(_ address_id:String,voucher:String,coupon_id:String) -> Observable <settlementCheckoutModel>{
        
        return  dropsMallAddTokenProviderHUD.request(.orderCheckout(address_id: address_id, voucher: voucher,coupon_id:coupon_id))
            .filter(statusCode: 200)
            .mapJSON()
            .map
            {
                JSON.init($0)
            }.filter{
                $0["status"]["code"].intValue == 200  
            }
            .asObservable()
            .map{
                settlementCheckoutModel.init(json: $0["data"])
                
        }
        
    }
    
    class   func cartGoodsIsSelect(goods_ids: JSON, tyop: String) -> Observable<JSON>{
        
        return  dropsMallAddTokenProvider.request(.cartBath(goods_ids: goods_ids, type: tyop))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .asObservable()
            .map{
                
                $0["status"]
        }
        
    }
    func collection(goods_id:Int,big:DisposeBag)  {
        dropsMallAddTokenProviderHUD.request(.collection(good_id: goods_id))
            .filter(statusCode: 200)
            .mapJSON()
            .map
            {
                JSON.init($0)
            }
            
            .map{
                $0["status"]
                
            }
            .asObservable()
            .subscribe(onNext: { status in
                
                
                if status["code"].intValue == 200{
                    HUD.flash(.labeledSuccess(title: nil, subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                }else{
                    HUD.flash(.labeledError(title: "提示", subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                }
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(big)
    }
    
    class  func addGoodsToCart(gooods_id:Int,goods_number:Int) -> Observable<JSON>  {
        
        return  dropsMallAddTokenProviderHUD.request(.addCart(goods_id: gooods_id, goods_number: goods_number))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .asObservable()
            .map{
                
                $0["status"]
        }
    }
    
    class func getCurrentWindow() -> UIWindow? {
        
        // 找到当前显示的UIWindow
        var window: UIWindow? = UIApplication.shared.keyWindow
        
        if window?.windowLevel != UIWindowLevelNormal {
            for tempWindow in UIApplication.shared.windows {
                
                if tempWindow.windowLevel == UIWindowLevelNormal {
                    
                    window = tempWindow
                    break
                }
            }
        }
        
        return window
    }
    
    @objc class func topViewController() -> UIViewController? {
        
        return self.topViewControllerWithRootViewController(viewController: self.getCurrentWindow()?.rootViewController)
    }
    
    @objc class func topViewControllerWithRootViewController(viewController :UIViewController?) -> UIViewController? {
        
        if viewController == nil {
            
            return nil
        }
        
        if viewController?.presentedViewController != nil {
            
            return self.topViewControllerWithRootViewController(viewController: viewController?.presentedViewController!)
        }
        else if viewController?.isKind(of: UITabBarController.self) == true {
            
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UITabBarController).selectedViewController)
        }
        else if viewController?.isKind(of: UINavigationController.self) == true {
            
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UINavigationController).visibleViewController)
        }
        else {
            
            return viewController
        }
    }
}

//+(UIViewController *) findBestViewController:(UIViewController *)vc {
//    if (vc.presentedViewController) {
//        // Return presented view controller
//        return [UIViewController findBestViewController:vc.presentedViewController];
//    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
//        // Return right hand side
//        UISplitViewController *svc = (UISplitViewController *) vc;
//        if (svc.viewControllers.count > 0)
//        return [UIViewController findBestViewController:svc.viewControllers.lastObject];
//        else
//        return vc;
//    } else if ([vc isKindOfClass:[UINavigationController class]]) {
//        // Return top view
//        UINavigationController *svc = (UINavigationController *) vc;
//        if (svc.viewControllers.count > 0)
//        return [UIViewController findBestViewController:svc.topViewController];
//        else
//        return vc;
//    } else if ([vc isKindOfClass:[UITabBarController class]]) {
//        // Return visible view
//        UITabBarController *svc = (UITabBarController *) vc;
//        if (svc.viewControllers.count > 0)
//        return [UIViewController findBestViewController:svc.selectedViewController];
//        else
//        return vc;
//    } else {
//        // Unknown view controller type, return last child view controller
//        return vc;
//    }
//}
