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
    @IBOutlet weak var passWord: AnimatableTextField!
    @IBOutlet weak var userName: AnimatableTextField!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var registerBtn: AnimatableButton!
    @IBOutlet weak var loginBtn: AnimatableButton!
    @IBOutlet weak var cancelBtn: UIButton!
    let disposeBag = DisposeBag()
    var viewModel = loginViewModel.init()
    var refreshUI:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension loginVC{
    func bindModel() {
        let intput = loginViewModel.Input.init(loginBtn: loginBtn.rx.tap.asDriver(),
                                               cancelBtn: cancelBtn.rx.tap.asDriver(),
                                               registerBtn: registerBtn.rx.tap.asDriver(),
                                               forgetPasswordBtn: forgetPasswordBtn.rx.tap.asDriver(),
                                               userName: userName.rx.text.orEmpty.asDriver(),
                                               passWord: passWord.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: intput)
        //绑定事件
        output.loginResultslo.drive(dismiss).disposed(by: disposeBag)
//        output.loginBtnSelect.drive(loginBtn.rx.isEnabled).disposed(by: disposeBag)
        output.dismiss.drive(dismiss).disposed(by: disposeBag)
        output.pusForgetPasswordVC.drive(pusVC).disposed(by: disposeBag)
        output.pusRegisteredUsersVC.drive(pusVC).disposed(by: disposeBag)
    }
    
    var dismiss: UIBindingObserver<loginVC, Bool> {
        return UIBindingObserver(UIElement: self, binding: { (vc, isDismiss) in
            if isDismiss{
                if let bloc = self.refreshUI {
                    bloc();
                }
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    var pusVC: UIBindingObserver<loginVC, String> {
        return UIBindingObserver(UIElement: self, binding: { (vc, identifier) in
            self.performSegue(withIdentifier: identifier, sender: nil)
        })
    }
   
   
    
}
