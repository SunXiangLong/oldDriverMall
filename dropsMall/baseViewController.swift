//
//  baseViewController.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa
import SnapKit

class baseViewController: AnimatableViewController {
    let disposeBag = DisposeBag()
    var frameX:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.frame = CGRect.init(x:  0, y: 0, width: 44, height: 44)
        //        leftBtn.backgroundColor = UIColor.red
        leftBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -40, bottom: 0, right: 0)
        leftBtn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        leftBtn.setImage(#imageLiteral(resourceName: "common_back"), for: .normal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBtn)
        // Do any additional setup after loading the view.
    }
    func back()  {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate  lazy  var noDataView:UIView = {
        
        let view  = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.mj_w, height: self.view.mj_h))
        view.backgroundColor = UIColor.white
        
        
        let image = UIImageView.init(image: #imageLiteral(resourceName: "thereIsNoData"))
        view.addSubview(image)
        let title = UILabel.init()
        title.text = "暂无相关数据\n请查看其它分类"
        title.textAlignment = .center
        title.numberOfLines = 0
        title.font = UIFont.init(name: "MicrosoftYaHei", size: 16)
        title.textColor = UIColor.init(hexString: "5D5D5D")
        view.addSubview(title)
        
        image.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
            $0.width.equalTo(150)
            $0.height.equalTo(150 * 128 / 204)
            
        }
        
        title.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(image.snp.bottom).offset(25)
            
        }
        return view
    }()
    
    func noData() {
        self.view.addSubview(noDataView)
        
    }
    func removeNoDataView() {
        if let _ = noDataView.superview{
            noDataView.removeFromSuperview()
            
        }
    }
   
  fileprivate lazy var noNetworkView:UIView = {
        let view  = UIView.init(frame: CGRect.init(x: 0, y: self.frameX ?? 0, width: self.view.mj_w, height: self.view.mj_h))
        view.backgroundColor = UIColor.white
        
        
        let image = UIImageView.init(image: #imageLiteral(resourceName: "noInternetConnection"))
        view.addSubview(image)
        let title = UILabel.init()
        title.text = "网络请求失败"
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = UIColor.init(hexString: "8B8D8F")
        view.addSubview(title)
        
        let title1 = UILabel.init()
        title1.text = "请检查您的网络\n重新加载吧"
        title1.numberOfLines = 0
        title1.textAlignment = .center
        title1.font = UIFont.systemFont(ofSize: 14)
        title1.textColor = UIColor.init(hexString: "C4C4C4")
        view.addSubview(title1)
        
        let btn = AnimatableButton()
        
        btn.setTitle("重新加载", for: .normal)
        
        btn.setTitleColor(UIColor.init(hexString: "6F6F6F"), for: .normal)
        btn.titleLabel?.font = UIFont.init(name: "MicrosoftYaHei", size: 14)
        btn.cornerRadius = 2
        btn.borderColor = UIColor.init(hexString: "C8C8C9")
        btn.borderWidth = 0.5
        btn.addTarget(self, action: #selector(reloadThe), for: .touchUpInside)
        view.addSubview(btn)
        
        image.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
            $0.width.equalTo(80)
            $0.height.equalTo(80 * 128 / 165)
            
        }
        
        title.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(image.snp.bottom).offset(15)
            
        }
        
        title1.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(title.snp.bottom).offset(5)
            
        }
        
        btn.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(title1.snp.bottom).offset(25)
            $0.width.equalTo(title.snp.width)
            $0.height.equalTo(30)
            
        }
        
        return view
    }()
    
    func noNetwork(_ top:CGFloat?) {
        self.frameX = top
        self.view.addSubview(noNetworkView)
    }
    func removeNoNetworkView()  {
        if let _ = noNetworkView.superview{
            noNetworkView.removeFromSuperview()
        
        }
    }
    func reloadThe() {
        
    }
    func isLogin() -> Bool {
        if !userInfo.user.isLogin {
            let VC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! loginVC
            VC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(VC, animated: true)
            return true
        }
        
        return false
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        log.debug("\(String.init(describing: type(of: self))) ---> 被销毁 ")
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
