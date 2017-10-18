//
//  loginViewModel.swift
//  dropsMall
//
//  Created by zhuge on 2017/10/18.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PKHUD
import SwiftyJSON
final class loginViewModel: ViewModelType {
    //预留（比如数据库操作的类或其他的，通过init传入）
    init() {
        
    }
    func transform(input: loginViewModel.Input) -> loginViewModel.Output {
        //转化用户名和密码为元组
        let titleAndDetails = Driver.combineLatest(input.userName, input.passWord) {
            $0
        }
        //登陆按钮是否可编辑
        let  loginBtnSelect = titleAndDetails.map{  item -> Bool in
            guard item.0.characters.count > 0 else {
                return false
            }
            guard item.1.characters.count > 0 else {
                return false
            }
            return true
        }
        //请求登陆接口获取用户信息并保存
        let loginResults = input.loginBtn
            .withLatestFrom(titleAndDetails)
            .flatMapLatest { (item) -> Driver<Bool> in
                return dropsMallProvider.request(.authLogin(username: item.0, password:item.1.MD5))
                    .asObservable()
                    .filter{$0.statusCode == 200}
                    .mapJSON()
                    .map{JSON.init($0)}
                    .filter{
                        
                        if $0["status"]["code"].intValue == 200{
                            UserDefaults.standard.set($0["data"].dictionaryObject, forKey: "userinfo")
                            UserDefaults.standard.synchronize()
                            let _ =  userInfo.user.initUserInfo($0["data"])
                            return true
                        }
                        HUD.flash(.labeledError(title: nil, subtitle: $0["status"]["msg"].stringValue), delay: 1)
                        return false
                    }
                    .map{_ in true}
                    .asDriver(onErrorJustReturn: false)
        }
        //pus到注册帐号VC
        let register = input.registerBtn.map{"registeredUsersVC"}
        //pus到忘记密码VC
        let forget = input.forgetPasswordBtn.map{"forgotPasswordVC"}
        //取消按钮点击事件
        let dismiss = input.cancelBtn.map{true}
        return Output.init(dismiss:dismiss , loginResultslo: loginResults, pusForgetPasswordVC: forget, pusRegisteredUsersVC: register, loginBtnSelect: loginBtnSelect)
    }
    
}
extension loginViewModel {
    struct Input {
        let loginBtn: Driver<Void>
        let cancelBtn: Driver<Void>
        let registerBtn: Driver<Void>
        let forgetPasswordBtn: Driver<Void>
        let userName: Driver<String>
        let passWord: Driver<String>
    }
    
    struct Output {
        let dismiss: Driver<Bool>
        let loginResultslo: Driver<Bool>
        let pusForgetPasswordVC: Driver<String>
        let pusRegisteredUsersVC: Driver<String>
        let loginBtnSelect: Driver<Bool>
        
    }
}
