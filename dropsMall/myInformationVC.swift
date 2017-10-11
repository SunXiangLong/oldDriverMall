//
//  myInformationVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import IBAnimatable
import RxCocoa
import RxSwift
import SwiftyJSON
import PKHUD
class myInformationCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var model:[String:String]?{
        didSet{
            userName.text =  model?.keys.first
            userText.text = model?.values.first
        }
    }
}
class myInformationVC: baseViewController {
    
    @IBOutlet weak var userImage: AnimatableImageView!
    @IBOutlet weak var tableView: UITableView!
    var dataList:[[String:String]]{
        
        return [["用户名":userInfo.user.nick_name!],
                ["手机号码":userInfo.user.username!],
                ["会员等级":userInfo.user.grade!]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        self.title = "个人信息"
        self.userImage.setImage(with: userInfo.user.avatar)
        Observable.just(dataList)
            .bindTo(tableView.rx.items(cellIdentifier: "myInformationCell", cellType: myInformationCell.self)){ tv, item, cell in
                cell.model = item
                cell.tintColor = UIColor.orange
            }.addDisposableTo(disposeBag)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func modifyThePicture(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let aler =  UIAlertController.init(title: "提示", message: "请选择图片来源", preferredStyle: .actionSheet)
        aler.addAction(UIAlertAction.init(title: "相册", style: .default, handler: { _ in
            
           
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            
            self.present(imagePicker, animated: true, completion: nil)
        }))
        aler.addAction(UIAlertAction.init(title: "相机", style: .default, handler: { _ in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            
            self.present(imagePicker, animated: true, completion: nil)
        }))
        aler.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { _ in
            
        }))
        
        self.present(aler, animated: true, completion: nil);
    }
    @IBAction func logOut(_ sender: Any) {
        
        logOut()
        
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

extension myInformationVC{


    func logOut()  {
        dropsMallAddTokenProviderHUD.request(.authLogout)
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }.map{
                $0["status"]["code"].intValue == 200  
            }
            .asObservable()
            .subscribe(onNext: { isLogout in
                if isLogout{
                     HUD.flash(.label("已退出登录"), onView: self.view, delay: 1.0, completion: nil)
                      self.navigationController?.popViewController(animated: true)
                    UserDefaults.standard.removeObject(forKey: "userinfo")
                    userInfo.user.clearUserInfo()
                }else{
                   HUD.flash(.labeledError(title: "未知错误", subtitle: "退出失败"), onView: self.view, delay: 1.0, completion: nil)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    func authModify(image:UIImage) {
        
        dropsMallAddTokenProviderHUD.request(.authModify(image: image, name: userInfo.user.nick_name!))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .map{
                $0["status"]["code"].intValue == 200  
            }
            .asObservable() 
            .subscribe(onNext: { isLogout in
                if isLogout{
                   
                   
                    HUD.flash(.label("修改成功"), onView: self.view, delay: 1.0, completion: nil)
                   
                }else{
                    HUD.flash(.labeledError(title: "错误", subtitle: "修改成功"), onView: self.view, delay: 1.0, completion: nil)
                   
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }

}
extension myInformationVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let portraitImg = info["UIImagePickerControllerEditedImage"] as! UIImage
        self.userImage.image = portraitImg
//        userInfo.user.isLogin
        log.debug(portraitImg)
        authModify(image: portraitImg)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
    
        picker.dismiss(animated: true, completion: nil)
    
    
    }

}
