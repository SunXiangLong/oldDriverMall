
//
//  shippingOrderVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/27.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class shippingOrderVC: baseViewController {

    @IBOutlet weak var courierFees: UITextField!
    @IBOutlet weak var courierNumber: UITextField!
    var order_id:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sub(_ sender: Any) {
        self.postCourierInfo()
    }

}
import SwiftyJSON
import RxSwift
import PKHUD
extension shippingOrderVC{


    func postCourierInfo() {
        
        guard (courierNumber.text?.characters.count)! > 1 else {
            HUD.flash(.label("请输入运单号"), delay: 0.5)
            courierNumber.becomeFirstResponder()
            
            return
        }
        
        guard (courierFees.text?.characters.count)! > 1 else {
            HUD.flash(.label("请输快递费用"), delay: 0.5)
            courierFees.becomeFirstResponder()
            return
        }
        
       
        
        let data = ["order_id":order_id!,"logistic_no":courierNumber.text!,"fee":courierFees.text!] as [String : Any]
        
        dropsMallAddTokenProviderHUD.request(.aftersaleFilllogistic(data: data))
            .filter(statusCode: 200)
            .mapJSON()
            .map
            {
                JSON.init($0)
            }.filter{ json  in
                
                if json["status"]["code"].intValue != 200{
                    HUD.flash(.labeledError(title: nil, subtitle:  json["status"]["msg"].stringValue))
                    return false
                }
                
                return true
            }
            .map{
                
                $0
                
            }
            .asObservable()
            .subscribe(onNext: { data in
                HUD.flash(.labeledSuccess(title: nil, subtitle:  data["status"]["msg"].stringValue))
                self.navigationController?.popViewController(animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

}
