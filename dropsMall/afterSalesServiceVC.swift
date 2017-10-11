//
//  afterSalesServiceVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/25.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import TZImagePickerController
import SwiftyJSON
import PKHUD
class afterSalesServiceCell: UITableViewCell {
    
    
    @IBOutlet weak var goods_image: UIImageView!
    @IBOutlet weak var goods_price: UILabel!
    @IBOutlet weak var goods_name: UILabel!
    @IBOutlet weak var goods_number: UILabel!
    @IBOutlet weak var goodsNumber: UILabel!
    var row = 0
    var returnGoods:((_ dic:[String:String],_ row:Int) -> Void)?
    
    var maxGoodsNumber = 1
    var currentGoodsNumber = 0
    var model:shoppingCartModel?{
       
        didSet{
            
            goods_image.setImage(with: model?.goods_img)
            goods_price.text = "￥" + model!.goods_price!
            goods_name.text = model?.goods_name
            maxGoodsNumber = model!.goods_number!
            goods_number.text = "\(currentGoodsNumber)"
            goodsNumber.text = "(退货数量最多为\(model!.goods_number!)件)"
        }

    }
    
    @IBAction func add(_ sender: UIButton) {
        currentGoodsNumber += 1
        if currentGoodsNumber > maxGoodsNumber{
        currentGoodsNumber -= 1
            HUD.flash(.labeledError(title: nil, subtitle: "最多退\(currentGoodsNumber)件"), delay: 0.5)
            return
        }
        goods_number.text = "\(currentGoodsNumber)"
        self.returnGoods!(["goods_id":model!.goods_id!,"number":"\(currentGoodsNumber)"],row)
    }
    

    @IBAction func reduce(_ sender: UIButton) {
         currentGoodsNumber -= 1
        if currentGoodsNumber < 0{
           currentGoodsNumber += 1
            return
        }
        goods_number.text = "\(currentGoodsNumber)"
        self.returnGoods!(["goods_id":model!.goods_id!,"number":"\(currentGoodsNumber)"],row)
    }
}
class afterSalesServiceVC: baseViewController {

    @IBOutlet weak var orderInfo: UILabel!
    @IBOutlet weak var order_sn: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var returnGoods:[[String:String]]?{
        didSet{
            var num1 = 0
            var num2 = 0.00
            for item in returnGoods!.enumerated() {
                num1 += Int(item.element["number"]!)!
                let num = self.model!.goodsList[item.offset].goods_price!
                
                num2 += Double(Double(num)! * Double(num1))
            }
            
                    orderInfo.text = "￥" + "\(num2)" + " 数量 " + "\(num1)"

        }
    }
    var type = 10
    var photoList:[UIImage] = []
    var model:afterSalesServiceModel?{
    
        didSet{
            order_sn.text = "订单号：" + model!.order_sn!
            self.tableView.reloadData()
            returnGoods = model?.goodsList.map{
            
                ["goods_id":$0.goods_id!,"number":"\(0)"]
            }
        }
    }
    var tablefootView:footView?
    var parent_order_sn:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableFootView()
        getOrderInfo()

        self.title = "退换货"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
extension afterSalesServiceVC{

    func tableFootView()  {
       
        let foot = footView.instanceView()
        foot.mj_w = UIScreenWidth
        foot.mj_h = 420
        tablefootView = foot
        foot.eventCallback = { type in
        
            switch type {
            case .addPhoto:
                self.setPhoto()
            case .submit:
                self.information()
            case .returnGoods:
                self.tablefootView?.mj_h = 490
                self.type = 1
            case .inGoods:
                self.tablefootView?.mj_h = 420
                self.type = 0
            
            }
        
        }
        tableView.tableFooterView = foot
    }
    func setPhoto()  {
        let imagePickerVc = TZImagePickerController.init(maxImagesCount: 3 - self.photoList.count, columnNumber: 4, delegate: nil, pushPhotoPickerVc: true)
        let image = [tablefootView?.image1,tablefootView?.image2,tablefootView?.image3]
        imagePickerVc?.didFinishPickingPhotosHandle = { (photos,assets,isselect) in
        
           
            for item in photos! {
                self.photoList.append(item)
                
            }
        
            for item in self.photoList.enumerated() {
                image[item.offset]?.image = item.element
            }
            
        }
        
        self.present(imagePickerVc!, animated: true, completion: nil)
        
    }
    
    func getOrderInfo()  {
        
        dropsMallAddTokenProviderHUD.request(.aftersalePrepare(order_sn:parent_order_sn!))
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
                
                afterSalesServiceModel.init(json: $0["data"])
                
            }
            .asObservable()
            .subscribe(onNext: { model in
               
                self.model = model
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    
    func information()  {
        var num = 0
        for item in self.returnGoods! {
            num += Int(item["number"]!)!
        }
        guard num > 0 else {
            HUD.flash(.label("请选择要退换货的商品"), delay: 0.5)
            return
        }

        
        guard type != 10 else {
            HUD.flash(.label("请选择退换货类型"), delay: 0.5)
            return
        }
        
        guard  (tablefootView?.problem.text.characters.count)! > 1 else {
            tablefootView?.problem.becomeFirstResponder()
            HUD.flash(.label("请输入退换货原因"), delay: 0.5)
            return
        }
        
        guard self.photoList.count > 0 else {
           
            HUD.flash(.label("请上传商品图片"), delay: 0.5)
            setPhoto()
            return
        }
        
        let data = ["type":type,"reason":tablefootView!.problem.text,"order_id":model!.order_id!,"data":JSON.init(self.returnGoods!)] as [String : Any]
        dropsMallAddTokenProviderHUD.request(.aftersaleOperate(data: data, dataImage: self.photoList))
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
                let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/orders/7")
                VC.title = "售后"
                VC.isPopToRoot = true
                self.navigationController?.pushViewController(VC, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
}
extension afterSalesServiceVC:UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.model?.goodsList{
        
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "afterSalesServiceCell", for: indexPath) as! afterSalesServiceCell
        cell.row = indexPath.row
        cell.model = self.model?.goodsList[indexPath.row]
        cell.returnGoods = { dic,row in
        
            self.returnGoods![row]  = dic
        }
        return cell
    }
    
}

struct afterSalesServiceModel {
    let order_id:Int?
    let order_status:String?
    let shipping_status:String?
    let refund_status:String?
    let pay_status:String?
    let order_sn:String?
    let goodsList:[shoppingCartModel]
    
    
    
    init(json:JSON) {
        order_id = json["order_id"].intValue
        order_status = json["order_status"].stringValue
        shipping_status = json["shipping_status"].stringValue
        refund_status = json["refund_status"].stringValue
        pay_status = json["pay_status"].stringValue
        order_sn = json["order_sn"].stringValue
        goodsList = json["goods"].arrayValue.map{
        
            shoppingCartModel.init(json: $0)
        }
       
    }
}
