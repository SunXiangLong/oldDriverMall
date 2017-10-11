//
//  memberCenter.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/15.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxCocoa
import RxSwift
import SwiftyJSON
import PKHUD
class memberCenterVC: baseViewController {
    
    
    @IBOutlet weak var signInBtn: AnimatableButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var headImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sign()
        
        headImage.setImage(with: userInfo.user.grade_icon)
        score.text = userInfo.user.user_score
        signInBtn.isEnabled =  !userInfo.user.isSign
        
        
    }
    
    @IBAction func tapBtn(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "rightsAndInterests", sender: sender)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let _ = segue.identifier else {
            return
        }
        switch segue.identifier! {
        case "webVC":
            let path = Bundle.main.path(forResource: "integral", ofType:"html")
            let urlStr = URL.init(fileURLWithPath: path!)
            let VC = segue.destination as! webVC
            VC.url = urlStr
            
        case "rightsAndInterests":
            let btn = sender as! UIButton
            let VC = segue.destination as! rightsAndInterests
            VC.page = btn.tag
            VC.title = btn.titleLabel?.text
            
        default:break
        }
        
    }
    
}

extension memberCenterVC{
    
    
    func sign() {
        
        signInBtn.rx.tap.asObservable().flatMapLatest{
            
            dropsMallAddTokenProviderHUD.request(.userSign)
                .filter(statusCode: 200)
                .mapJSON()
                .map{
                    JSON.init($0)
                }
                .map{
                    $0["status"]["code"].intValue == 200  
            }
            }.subscribe(onNext: { isLogout in
                
                self.signInBtn.isEnabled = false
                
                if isLogout{
                    
                    
                    userInfo.user.isSign = true
                    HUD.flash(.labeledSuccess(title: nil, subtitle: "签到成功"), onView: self.view, delay: 1.0, completion: nil)
                    
                }else{
                    HUD.flash(.labeledError(title: "提示", subtitle: "您今天已经签过到了哦~"), onView: self.view, delay: 1.0, completion: nil)
                    
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
    
    
}

