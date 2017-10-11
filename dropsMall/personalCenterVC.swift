//
//  personalCenterVC.swift
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
struct personalCenterModel {
    let typeImage:UIImage
    let typeText:String
    init(dic:[String:String]) {
        typeText = dic["text"]!
        typeImage =  UIImage.init(named: dic["image"]!)!
    }
}
class personalCenterCell: UITableViewCell {
    
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    var model:personalCenterModel?{
        
        didSet{
            typeImage.image = model?.typeImage
            typeText.text = model?.typeText
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
class personalCenterVC: baseViewController {
    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var headImage: AnimatableImageView!
    @IBOutlet weak var grade_icon: UIImageView!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var dataArr:[personalCenterModel]?{
        didSet{
            
            tableView.reloadData()
        }
        
    }
    
    @IBOutlet weak var loginView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginView.isHidden = userInfo.user.isLogin
        if userInfo.user.isLogin {
            refreshUserInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        
        tableView.tableFooterView = UIView.init()
        
        
    }
    
    
    @IBAction func loginTap(_ sender: Any) {
        
        self.performSegue(withIdentifier: "login", sender: nil)
    }
    @IBAction func tapBtn(_ sender: UIButton) {
        
        if isLogin(){
            return
        }
        log.debug(123455666)
        let identifier = ["0","1","2","3","6","7"];
        let  titleStr = ["全部订单","待付款","待发货","待收货","待评论","售后"]
        let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
        VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/orders/" + identifier[sender.tag])
        VC.title = titleStr[sender.tag]
        self.navigationController?.pushViewController(VC, animated: true)
        
        
        
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

extension personalCenterVC {
    
    func initUI() {
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        var arr =   [
            ["image":"cart","text":"购物车"],
            ["image":"Info","text":"我的积分"],
            ["image":"coupons","text":"我的优惠券"],
            ["image":"Star","text":"我的收藏"],
            ["image":"Pin","text":"收货地址"],
            ["image":"Phone","text":"联系客服"],
            ["image":"Lightbulb","text":"我要当司机"],
            ["image":"Settings","text":"设置"],
            ["image":"physicalExamination","text":"体检查询"]
        ]
        
        if  userInfo.user.isLogin&&userInfo.user.is_driver  != "0"{
            
            arr.remove(at: 5)
            
            
        }
        
        
        self.dataArr =  arr.map{
            personalCenterModel.init(dic: $0)
        }
    }
    
    
    func refreshUserInfo() {
        
        let token =  dropsMallAddTokenProvider.request(.refreshUser)
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                $0["status"]["code"].intValue == 200  
            }
            .map{ json in
                
                userInfo.user.initUserInfo(json["data"])
                
        }
        
        
        
        token.subscribe {_ in 
            
            self.setuserInfo()
            
            }.addDisposableTo(disposeBag)
    }
    
    
    func setuserInfo(){
        
        initUI()
        
        userName.text = userInfo.user.nickname
        headImage.setImage(with: userInfo.user.avatar, placeholder: #imageLiteral(resourceName: "jakelin"))
        grade.text = userInfo.user.grade
        grade_icon.setImage(with: userInfo.user.grade_icon_s)
        
        
    }
    
}
extension personalCenterVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if let arr = self.dataArr {
            return arr.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCenterCell", for: indexPath) as! personalCenterCell
        cell.model = self.dataArr![indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isLogin(){
            
            return
        }
        
        switch indexPath.row {
        case 0:
            let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "shoppingCartVC") as! shoppingCartVC
            self.navigationController?.pushViewController(VC, animated: true)
        case 1:
            
            self.performSegue(withIdentifier: "memberCenterVC", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "couponsVC", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "myCollectionVC", sender: nil)
        case 4:
            let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "addressManagementVC") as! addressManagementVC
            self.navigationController?.pushViewController(VC, animated: true)
            
        case 5:
            Unicall.singleton().unicallShowView(["title":"","desc":"","iconUrl":"","url":""])
            return
        case 6:
            if userInfo.user.isLogin&&userInfo.user.is_driver! != "0"{
                
                self.performSegue(withIdentifier: "SettingsVC", sender: nil)
                
            }else{
                self.performSegue(withIdentifier: "driverIsRegisteredVC", sender: nil)
            }
            
        case 7:
            if  userInfo.user.isLogin&&userInfo.user.is_driver  != "0"{
                self.performSegue(withIdentifier: "physicalExaminationVC", sender: nil)
            }else{
                self.performSegue(withIdentifier: "SettingsVC", sender: nil)
            }
            
        case 8:
            self.performSegue(withIdentifier: "physicalExaminationVC", sender: nil)
        default:break
        }
        
    }
    
    
    
    
}
