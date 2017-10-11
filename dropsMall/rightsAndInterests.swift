//
//  rightsAndInterests.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/15.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class rightsAndInterests: baseViewController {

    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var headImage: UIImageView!
    
    var page:Int?
    let data = [
        ["image":#imageLiteral(resourceName: "NonMembers"),"textArr":["权益内容：低于市场价的非会员价","权益对象：非会员用户","使用渠道：滴滴福利商城APP"]],
        ["image":#imageLiteral(resourceName: "VIP"),"textArr":["权益内容：低于非会员价的会员价","权益对象：所有会员","使用渠道：滴滴福利商城APP"]],
        ["image":#imageLiteral(resourceName: "happy-birthday"),"textArr":["权益内容：会员生日，即可领取生日礼包","权益对象：所有会员","使用渠道：滴滴福利商城APP"]],
        ["image":#imageLiteral(resourceName: "membership-point"),"textArr":["权益内容：评论订单获得相应积分","权益对象：所有会员","使用渠道：滴滴福利商城APP"]],
        ["image":#imageLiteral(resourceName: "membership-point1"),"textArr":["权益内容：签到即可获第相应积分","权益对象：所有会员","使用渠道：滴滴福利商城APP"]]
    
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
       headImage.image = data[page!]["image"] as? UIImage
        let  textArr = data[page!]["textArr"] as! [String]
        let  labelArr = [text1,text2,text3];
       
        for obje in textArr.enumerated()  {
            
            labelArr[obje.offset]?.text = obje.element
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
