//
//  PayTool.swift
//  ShareApp
//
//  Created by liulianqi on 16/8/1.
//  Copyright © 2016年 sunxianglong. All rights reserved.
//

import Foundation

let  APP_ID = "wx3d6ad056fee2233f"
let  APP_SECRET = "bc615954faf9248535b648b50fcffbc9"
let  MCH_ID = "1372260502"
let  PARTNER_ID = "eb7e53f488af96ba23ed3c2a6ccf6d76"
let  NOTIFY_URL_goods = "http://weidian.xiaomabao.com/payment/wx_app_notify"

final class PayTool {
    
    /***微信支付*/
    class func  wxPay(_ param:[String:String]) ->Void {
       
            
        }
    
    
    
    /*** 支付宝支付*/
  class  func  zfbPay(_ ali_sign:String,block:@escaping CompletionBlock) ->Void {
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        let appScheme = "dropsMallAPP";
        AlipaySDK.defaultService().payOrder(ali_sign, fromScheme: appScheme, callback: block)
    }
    }

    
    

