//
//  goodsCommentsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/25.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import TZImagePickerController
import SwiftyJSON
import PKHUD
import YYText
class goodsCommentsCell: UITableViewCell {
    
    
    @IBOutlet weak var textView: YYTextView!
    @IBOutlet weak var goods_image: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var good_image: UIView!
    @IBOutlet weak var starRateView: UIView!
    var updateEvaluationData:(( _ model:evaluationModel,_ row:Int)-> Void)?
    
     var addPhoto:((_ row:Int)-> Void)?
    var row = 0
    var starView:JNStarRateView?
    var commentModel:evaluationModel?{
        didSet{
         textView.text = commentModel?.comments
         starView?.score =  (commentModel?.score)!
          let imageList =  [image1,image2,image3,image4]
            
            for item in commentModel!.goodsImageList.enumerated() {
                imageList[item.offset]?.image = item.element
            }
        
        }
    }
    var model:commentsModel?{
        didSet{
            goods_image.setImage(with: model?.goods_img)
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        starView = JNStarRateView.init(frame: CGRect.init(x: 0, y: 0, width: starRateView.mj_w, height: starRateView.height))
        starView?.allowUserPan = true
        starView?.delegate = self
    
        starRateView.addSubview(starView!)
        textView.delegate = self
        
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        
        self.addPhoto!(row)
    }
    
    
}
extension goodsCommentsCell: JNStarReteViewDelegate,YYTextViewDelegate{
    
    func starRate(view starRateView: JNStarRateView, score: Float) {
        commentModel?.score = score
        self.updateEvaluationData!(commentModel!,row)
    }
 
    func textViewDidEndEditing(_ textView: YYTextView) {
         commentModel?.comments = textView.text
        self.updateEvaluationData!(commentModel!,row)
    }
}
class goodsCommentsVC: baseViewController {
    var parent_order_sn:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    var evaluationModelList:[evaluationModel]?
    var modeList:[commentsModel]?{
        didSet{
            self.evaluationModelList = modeList?.map{
                evaluationModel.init(model: $0)
            }
            self.tableView.reloadData()
        }
    }
    @IBAction func releaseGoodsComment(_ sender: Any) {
       
        uploadEvaluationInformation()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.tableFooterView = UIView.init()
        self.title = "评价商品"
        
        setCommentsData()
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
extension goodsCommentsVC{
    
    func setCommentsData()  {
        
        dropsMallAddTokenProviderHUD.request(.aftersaleCommetshow(parent_order_sn: parent_order_sn!))
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
                
                $0["data"].arrayValue.map{
                    
                    commentsModel.init(json: $0)
                    
                }
                
            }
            .asObservable()
            .subscribe(onNext: { list in

                self.modeList = list
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
        
    
    }
    
    /// 上传评价信息
    func uploadEvaluationInformation() {
        
        
        var data:[[String:String]] = []
        var imageList:[[UIImage]] = []
        
        
        for item in self.evaluationModelList! {
            
            data.append(["goods_id":item.goods_id!,"order_id":item.order_id!,"score":"\(item.score)","content":item.comments ?? ""])
            imageList.append(item.goodsImageList)
            
            
        }
        
        dropsMallAddTokenProviderHUD.request(.aftersaleCommet(data: ["comment":JSON.init(data)], imageList: imageList))
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
    
    func setPhoto(row:Int)  {
        let imagePickerVc = TZImagePickerController.init(maxImagesCount: 4 - (self.evaluationModelList?[row].goodsImageList.count)!, columnNumber: 4, delegate: nil, pushPhotoPickerVc: true)
       
        imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self]  (photos,assets,isselect) in
            
            
            for item in photos! {
                self.evaluationModelList?[row].goodsImageList.append(item)
                
            }
            
            self.tableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .automatic)
            
        }
        
        self.present(imagePickerVc!, animated: true, completion: nil)
        
    }
    
}
extension goodsCommentsVC:UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let list = self.modeList else {
            return 0
        }
        
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goodsCommentsCell", for: indexPath) as! goodsCommentsCell
        cell.model = self.modeList?[indexPath.row]
        cell.commentModel = self.evaluationModelList?[indexPath.row]
        cell.row = indexPath.row
        cell.addPhoto = {[unowned self]  row in
        
            self.setPhoto(row: row)
        }
        cell.updateEvaluationData = {[unowned self]  (model,row) in
        
            self.evaluationModelList?[row] = model
            self.tableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .automatic)
        }
        return cell
    }
    
}

struct commentsModel {
    let goods_id:String?
    let goods_name:String?
    var goods_img:URL?
    let order_id:String?
    init(json:JSON) {
        goods_id = json["goods_id"].stringValue
        order_id = json["order_id"].stringValue
        goods_name = json["goods_name"].stringValue
        goods_img = json["goods_img"].url
        
        
    }
    
}

struct evaluationModel {
    var score:Float = 5.00{
        didSet{
            if score == 0.00 {
                isEvaluation = false
            }
        
        }
    }
    var order_id:String?
    var goods_id:String?
    var comments:String?
    var goodsImageList:[UIImage] = []
    var isEvaluation = false
    init(model:commentsModel) {
        goods_id = model.goods_id
        isEvaluation = true
        order_id = model.order_id
    }
}
