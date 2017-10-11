//
//  driverIsRegisteredVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa
import SwiftyJSON
import PKHUD
class driverIsRegisteredVC:  baseViewController{
    
    @IBOutlet weak var name: AnimatableTextField!
    @IBOutlet weak var codeButton: AnimatableButton!
    @IBOutlet weak var phoneTextField: AnimatableTextField!
    
    @IBOutlet weak var validCode: AnimatableTextField!
    @IBOutlet weak var driverType: AnimatableTextField!
    @IBOutlet weak var carType: AnimatableTextField!
    @IBOutlet weak var licensePlateNumber: AnimatableTextField!
    @IBOutlet weak var driverLicenseCode: AnimatableTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var countdownTimer: Timer?
    
    var phoneCode:String?
    
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
    @IBAction func sendButtonClick(_ sender: AnyObject) {
        
        
        
        self.sendCode()
    }
    @IBAction func determine(_ sender: AnimatableButton) {
        
        driverRegister(["realname":name.text!,
                        "cellphone":phoneTextField.text!,
                        "driver_license":driverLicenseCode.text!,
                        "car_no":licensePlateNumber.text!,
                        "driver_type":driverType.text!,
                        "car_type":carType.text!,
                        "validcode":validCode.text!
            ])
    }
    var remainingSeconds: Int = 0 {
        willSet {
            
            codeButton.setTitle("\(newValue)秒", for: .normal)
            
            
            if newValue <= 0 {
                
                codeButton.setTitle("获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    func updateTime(_ timer: Timer) ->Void {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    
    
    
}

extension driverIsRegisteredVC{
    
    
    func sendCode() -> Void {
        
        if phoneTextField.text?.characters.count == 11 {
            self.isCounting = true
            self.setPhoneCode(self.phoneTextField.text!,disposeBag)
        }else{
            
            HUD.flash(.labeledError(title: nil, subtitle: "请输入正确的手机号"))
        }
        
    }
    
    
    
    
    func driverRegister(_ dic:[String:String]){
    
        dropsMallAddTokenProviderHUD.request(.authDriverRegister(dic: dic))
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
                }else{
                    HUD.flash(.labeledError(title: "提示", subtitle: status["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
}

