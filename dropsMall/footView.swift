//
//  footView.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/25.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import Foundation
import IBAnimatable
import YYText

class footView: UIView {
    
    @IBOutlet weak var inBtn: AnimatableButton!
    @IBOutlet weak var refundBtn: AnimatableButton!
    @IBOutlet weak var payTypeBtn: AnimatableButton!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var payTypeheight: NSLayoutConstraint!
    @IBOutlet weak var problem: YYTextView!
   
 
    var imageArr:[UIImageView]?
    var eventCallback:((_ type:eventType)->Void)?
    class func instanceView() -> footView {
 
        return Bundle.main.loadNibNamed("footView", owner: nil, options: nil)?.first as! footView
    }
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func tap(_ sender: AnimatableButton) {
        self.eventCallback!(eventType(rawValue: sender.tag)!)
        switch eventType(rawValue: sender.tag)! {
        case .returnGoods:
            self.refundBtn.backgroundColor = UIColor.init(hexString: "ED8623")
            self.inBtn.backgroundColor = UIColor.init(hexString: "A6A6AD")
            payTypeheight.constant = 70
        case .inGoods:
            self.inBtn.backgroundColor = UIColor.init(hexString: "ED8623")
            self.refundBtn.backgroundColor = UIColor.init(hexString: "A6A6AD")
            payTypeheight.constant = 0
        default:break
         
        
        }
    
       
        
    }
    
}
enum eventType:Int {
    case returnGoods
    case inGoods
    case addPhoto
    case submit
    
}
