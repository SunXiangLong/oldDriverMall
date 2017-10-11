//
//  registeredUsersVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/13.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa
import SwiftyJSON
import PKHUD
class registeredUsersVC: baseViewController {
    
    @IBOutlet weak var codeButton: AnimatableButton!
    @IBOutlet weak var phoneTextField: AnimatableTextField!
    @IBOutlet weak var passwordTextField: AnimatableTextField!
    @IBOutlet weak var codeTextField: AnimatableTextField!
    @IBOutlet weak var inviteCodeTextField: AnimatableTextField!
    @IBOutlet weak var confirmPasswordTextField: AnimatableTextField!
    
    var countdownTimer: Timer?
    
    var registeredSuccessfully:((_ phone:String,_ passWord:String) -> Void)?
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime(_:)), userInfo: nil, repeats: true)
                
                remainingSeconds = 30
                
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                
            }
            
            codeButton.isEnabled = !newValue
        }
    }
   
    var remainingSeconds: Int = 0 {
        willSet {
            
             codeButton.setTitle("\(newValue)秒", for: .normal)
            
            
//            codeButton.titleLabel?.textAlignment = .center
//            codeButton.titleLabel?.text = "\(newValue)秒"
            
            if newValue <= 0 {
                
                codeButton.setTitle("获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "注册用户"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonClick(_ sender: AnyObject) {
        
        
        self.sendCode()
    }
    
    @IBAction func registered(_ sender: AnimatableButton) {
        
        registeredUser(["username":phoneTextField.text ?? "",
                        "password":passwordTextField.text ?? "",
                        "password2":confirmPasswordTextField.text ?? "",
                        "validcode":codeTextField.text ?? "",
                        "member_code":inviteCodeTextField.text ?? ""
                    
            ])
    }

    
    
}
extension registeredUsersVC{
    
    func updateTime(_ timer: Timer) ->Void {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    func sendCode() -> Void {
        
        if phoneTextField.text?.characters.count == 11 {
            self.isCounting = true
            self.setPhoneCode(self.phoneTextField.text!,disposeBag)
        }else{
            
            HUD.flash(.labeledError(title: nil, subtitle: "请输入正确的手机号"))
        }
        
    }
    
    
    
    func registeredUser(_ dic:[String:String]){
        
        dropsMallAddTokenProviderHUD.request(.authRegister(dic: dic))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .map
            {
                $0["status"]
            }
            .asObservable()
            .subscribe(onNext: { status in
                if status["code"].intValue == 200{
                    HUD.flash(.labeledSuccess(title: nil, subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                    self.registeredSuccessfully!(self.phoneTextField.text!,self.passwordTextField.text!)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    HUD.flash(.labeledError(title: "提示", subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
}

