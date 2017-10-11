//
//  userInfo.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import Foundation
import SwiftyJSON
class userInfo {
    var isLogin = false
    
    var isSign = false
    /// 登录返回用户信息
    var token:String?
    var is_driver:String?
    var next_grade:String?
    var nickname:String?
    var grade:String?
    var avatar:URL?
    var grade_icon:URL?
    
    var userImage:UIImage?
    /// 用户信息
    var username:String?
    var user_score:String?
    var car_no:String?
    var nick_name:String?
    var user_avatar:URL?
    var grade_icon_s:URL?
    static let user = userInfo()
    /// 创建一个私有的初始化方法覆盖公共的初始化方法。
    fileprivate  init() {}
    
    func initUserInfo(_ json:JSON) -> userInfo {
        var isUsername = false
        if let _ = json["username"].string {
            isUsername = true
        }else{
            token = json["token"].stringValue
        }
    
        
        is_driver = json["is_driver"].stringValue
        username = json["username"].stringValue
        nickname = isUsername ?  json["nick_name"].stringValue: json["nickname"].stringValue
        grade = json["grade"].stringValue
        next_grade = json["next_grade"].stringValue
        grade_icon = json["grade_icon"].url
        avatar =  isUsername ? json["user_avatar"].url:json["avatar"].url
        user_avatar = json["user_avatar"].url
        nick_name = json["nick_name"].stringValue
        car_no = json["car_no"].stringValue
        user_score = json["user_score"].stringValue
        isLogin = true
        grade_icon_s = json["grade_icon_s"].url
        return .user
    
    }
    
    func clearUserInfo() {
        isLogin = false
        isSign = false
        token = nil
        is_driver = nil
        username = nil
        nickname = nil
        grade = nil
        next_grade = nil
        grade_icon = nil
        avatar =  nil
        user_avatar = nil
        nick_name = nil
        car_no = nil
        user_score = nil
    
    
    }
}
