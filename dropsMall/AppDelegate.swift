//
//  AppDelegate.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/12.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import SwiftyBeaver
import SwiftyJSON
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import YYText
public let log = SwiftyBeaver.self
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let disposeBag = DisposeBag()
    var window: UIWindow?
    //    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SDKInit()
        
        refreshToken()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //    application:openURL:options:
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { (resultDic) in
            
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "AlipayPay"), object: nil, userInfo: resultDic))
        }
        
        return WXApi.handleOpen(url, delegate: self)
        
    }
    
    
}

extension AppDelegate:WXApiDelegate{
    
    func onReq(_ req: BaseReq!) {
        log.debug(req.openID)
        
    }
    func onResp(_ resp: BaseResp!) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "WxPay"), object: nil, userInfo: ["errcode":Int(resp.errCode) ]))
        
    }
}
extension AppDelegate{
    
    func refreshToken(){
        
        
        
        guard let data = UserDefaults.standard.object(forKey: "userinfo")  else {
            return
        }
        
        _ = userInfo.user.initUserInfo(JSON.init(data))
        
        dropsMallAddTokenProvider.request(.authRefreshToken)
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }.map{
                $0["status"]["code"].intValue == 200  
            }.asObservable()
            .subscribe(onNext: { isLogout in
                if !isLogout{
                    
                    UserDefaults.standard.removeObject(forKey: "userinfo")
                    userInfo.user.clearUserInfo()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
    }
    
    
    func SDKInit() {
        
        IQKeyboardManager.sharedManager().enable = true
         IQKeyboardManager.sharedManager().registerTextFieldViewClass(YYTextView.classForCoder() as! UIView.Type, didBeginEditingNotificationName: NSNotification.Name.YYTextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: NSNotification.Name.YYTextViewTextDidEndEditing.rawValue)
        
        
        let console = ConsoleDestination()
        log.addDestination(console)
        
        
        WXApi.registerApp("wx0ff4c00d9ccd89d4")
        
    }
}

