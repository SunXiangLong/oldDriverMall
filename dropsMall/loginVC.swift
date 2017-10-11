//
//  loginVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/12.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa
import SwiftyJSON
import SwiftyRSA
import Kingfisher
import PKHUD
class loginVC: AnimatableViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var passWord: AnimatableTextField!
    @IBOutlet weak var userName: AnimatableTextField!
    var refreshUI:(()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func login(_ sender: UIButton) {
        let pass = passWord.text ?? ""
        sender.endEditing(false)
        dropsMallProvider.request(.authLogin(username: userName.text!, password:pass.MD5))
            .asObservable()
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                
                sender.endEditing(true)
                if $0["status"]["code"].intValue == 200{
                    
                    return true
                }
                HUD.flash(.labeledError(title: nil, subtitle: $0["status"]["msg"].stringValue), delay: 1)
                return false
            }
            
            .filter{
                UserDefaults.standard.set($0["data"].dictionaryObject, forKey: "userinfo")
                UserDefaults.standard.synchronize()
                return true
            }
            .map{
                userInfo.user.initUserInfo($0["data"])
            }
            .asObservable()
            .debug()
            .subscribe(onNext: { (user) in
                
                if let bloc = self.refreshUI {
                    bloc();
                }
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let ident = segue.identifier{
            
            switch ident {
            case "registeredUsersVC":
                let VC  = segue.destination as! registeredUsersVC
                VC.registeredSuccessfully = { phone,pass in
                    self.passWord.text = pass
                    self.userName.text = phone
                }
            case "forgotPasswordVC":
                let VC  = segue.destination as! forgotPasswordVC
                VC.changePasswordSuccessfully = { phone,pass in
                    self.passWord.text = pass
                    self.userName.text = phone
                }
                
            default:
                break
            }
            
        }
        
    }
    
}


