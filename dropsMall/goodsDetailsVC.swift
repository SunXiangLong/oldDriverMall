//
//  goodsDetailsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/17.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import PKHUD
import IBAnimatable
import SKPhotoBrowser
//class homeCategoryCell: UICollectionViewCell {
//    @IBOutlet weak var cat_icon: UIImageView!
//
//    var model:URL?{
//
//        didSet{
//
//            cat_icon.setImage(with: model)
//        }
//    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//
//}
class goodsEvaluationCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var user_avatar: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var nickname: UILabel!
    let disposeBag = DisposeBag()
    
    var itemSelected:((_ VC:UIViewController)-> Void)?
    var model:commentModel?{
        didSet{
            user_avatar.setImage(with: model!.user_avatar)
            content.text = model?.content
            nickname.text = model?.nickname
            
            collectionView.dataSource = nil
            
            Observable.just(model!.imgs!)
                .filter{
                    $0.count > 0 ? true:false
                }.bindTo(collectionView.rx.items(cellIdentifier: "homeCategoryCell", cellType: homeCategoryCell.self)){ tv, item, cell in
                    
                    cell.model = item
                    
                }.addDisposableTo(disposeBag)
            
            collectionView.rx.itemSelected.asObservable().subscribe(onNext: { indexPath in
                
                var images = [SKPhoto]()
                for item in self.model!.imgs! {
                    let skphoto = SKPhoto.photoWithImageURL(item.description)
                    skphoto.shouldCachePhotoURLImage = false
                    images.append(skphoto)
                }
          
                
                let cell = self.collectionView.cellForItem(at: indexPath) as! homeCategoryCell
                let originImage = cell.cat_icon.image
                let browser = SKPhotoBrowser(originImage: originImage ?? UIImage(), photos: images, animatedFromView: cell)
                browser.initializePageIndex(indexPath.row)
                self.itemSelected!(browser)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            
            
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: (UIScreenWidth - 75)/4, height: UIScreenWidth * 155/750)
        collectionView.collectionViewLayout = layout
        
        
    }
    
    
    
}

class goodsImageCell: UITableViewCell {
    
    @IBOutlet weak var image1: UIImageView!
    var model:goodsDesc?{
        didSet{
            image1.setImage(with: model?.url)
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
class goodsDetailsVC: baseViewController {
    //    var goodModel:goodsModel?
    var goods_id:Int?
    var model:goodsDetailsModel?{
        didSet{
            goodImage.setImage(with: model!.galleryList?.first?.img_url)
            goodsImageView.imageModelArray = model!.galleryList?.map{
                GLImageModel.init($0.img_url!.absoluteString, type: .url)
            }
            shop_price.text = model?.baseInfModel?.shop_price
            member_price.text =  "会员价：" + model!.baseInfModel!.member_price!
            market_price.text =  "市场价：" + model!.baseInfModel!.market_price!
            goods_name.text = model?.baseInfModel?.goods_name
            goodsName.text = model?.baseInfModel?.goods_name
            stock.text = "库存：" + model!.baseInfModel!.stock! + "件"
            score.text = "评价（" + "\(model!.commentList!.count)" + ")"
            if (model?.commentList?.count)! == 0 {
                self.bottomViewHeight.constant = 0
                self.bottomView.isHidden = true
            }
            self.view.layoutIfNeeded()
            
            self.tableheadView.height = self.bottomView.bottom
            self.tableView.reloadData()
            
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shop_price: UILabel!
    @IBOutlet weak var market_price: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var member_price: UILabel!
    @IBOutlet weak var goods_name: UILabel!
    @IBOutlet weak var tableheadView: UIView!
    @IBOutlet weak var goodsImageView: GLCircleView!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var collectionBtn: AnimatableButton!
    @IBOutlet weak var goodsName: UILabel!
    @IBOutlet weak var goodImage: UIImageView!
    @IBOutlet weak var bottomView: AnimatableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    var goodsNumber = 1{
        didSet{
            goods_number.text = "\(goodsNumber)"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        tableheadView.isHidden = true
        tableView.delegate = self
        bindModel()
        
    }
    
    @IBAction func allEvaluation(_ sender: Any) {
        self.performSegue(withIdentifier: "productEvaluationVC", sender: nil)
    }
    
    @IBAction func customerService(_ sender: Any) {
        
        Unicall.singleton().unicallShowView(["title":"质询商品","desc":model!.baseInfModel!.goods_name!,"iconUrl":"","url":""])
        
    }
    
    @IBOutlet weak var goods_number: AnimatableTextField!
    @IBAction func Reduction(_ sender: Any) {
        if goodsNumber == 1 {
            
            HUD.flash(.labeledError(title: nil, subtitle: "最少选择一件商品"), onView: self.view, delay: 1.0, completion: nil)
            return;
        }
        goodsNumber  = goodsNumber - 1
        
    }
    
    @IBAction func add(_ sender: Any) {
        goodsNumber  = goodsNumber + 1
    }
    @IBAction func collection(_ sender: Any) {
        //        self.collection(goods_id: goodModel!.goods_id)
        if isLogin(){
            return
        }
        self.collection(goods_id: goods_id!, big: self.disposeBag)
        
    }
    @IBAction func goShoppingCart(_ sender: Any) {
        if isLogin(){
            return
        }
        self.performSegue(withIdentifier: "shoppingCartVC", sender: nil)
    }
    
    @IBAction func addShoppingCart(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.top.constant = -151;
            self.view.layoutIfNeeded()
            
        }) { isSuccess in
            
            
        }
        
    }
    
    @IBAction func goToTheShoppingCart(_ sender: Any) {
        
        if isLogin(){
            return
        }
        self.top.constant = 80
        UIViewController.addGoodsToCart(gooods_id: goods_id!, goods_number: goodsNumber)
            .subscribe(onNext: { json in
                
                
                if json["code"].intValue == 200{
                    HUD.flash(.labeledSuccess(title: nil, subtitle: json["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                    self.performSegue(withIdentifier: "shoppingCartVC", sender: nil)
                    return
                }
                HUD.flash(.labeledError(title: nil, subtitle: json["msg"].stringValue), onView: self.view, delay: 1.0, completion: nil)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let ident = segue.identifier {
            switch ident {
            case "productEvaluationVC":
                let VC = segue.destination as! productEvaluationVC
                VC.goods_id = self.goods_id
                VC.title = "全部评价"
            default:
                break
            }
        }
    }
    
    
}
extension goodsDetailsVC:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.model else {
            return 0
        }
        
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            
            if (model?.commentList?[indexPath.row]
                .imgs?.count)! > 0 {
                return 160
            }
            return 60
        default:
            
           
            return UIScreenWidth * CGFloat(model!.baseInfModel!.goods_desc![indexPath.row].ratio!)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = AnimatableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreenWidth, height: 35))
            view.borderWidth = 0.5
            view.borderSides = .top
            view.borderColor = UIColor.init(hexString: "D9D8D9")
            view.backgroundColor = UIColor.white
            let lable = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: UIScreenWidth - 30, height: 35))
            lable.text = "商品介绍"
            lable.textColor = UIColor.init(hexString: "5D5D5D")
            lable.font = UIFont.init(name: "MicrosoftYaHei", size: 14)
            lable.textAlignment = .center
            
            view.addSubview(lable)
            return view
        }
        return UIView.init()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 35
        }
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model!.commentList!.count
        default:
            return model!.baseInfModel!.goods_desc!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "goodsEvaluationCell", for: indexPath) as! goodsEvaluationCell
            cell.model = model?.commentList?[indexPath.row]
            cell.itemSelected = { vc in
            
                self.present(vc, animated: true, completion: nil)
            
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "goodsImageCell", for: indexPath) as! goodsImageCell
            cell.model = model?.baseInfModel?.goods_desc?[indexPath.row]
            return cell
        }
    }
    
}
extension goodsDetailsVC{
    
    
    func bindModel() {
        dropsMallAddTokenProviderHUD.request(.goodsDetails(ID: goods_id!))
            .filter(statusCode: 200)
            .mapJSON()
            .map
            {
                JSON.init($0)
            }
            .filter{
                
                $0["status"]["code"].intValue == 200 ? true:false
            }
            .map{
                goodsDetailsModel.init(json: $0["data"])
                
            }
            .asObservable()
            .subscribe(onNext: { model1 in
                self.model = model1
                self.tableheadView.isHidden = false
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
}

struct goodsDetailsModel {
    
    let baseInfModel:baseInfoModel?
    let galleryList:[galleryModel]?
    var commentList:[commentModel]?
    init(json:JSON) {
        baseInfModel = baseInfoModel.init(json: json["base_info"])
        
        galleryList = json["gallery"].arrayValue.map{
            galleryModel.init(json: $0)
        }
        commentList = json["comment"].arrayValue.map{
            commentModel.init(json: $0)
        }
    }
}

struct baseInfoModel {
    let goods_name:String?
    let market_price:String?
    let shop_price:String?
    let member_price:String?
    let stock:String?
    let comment_total:String?
    let goods_desc:[goodsDesc]?
    
    init(json:JSON) {
        goods_name = json["goods_name"].stringValue
        market_price = json["market_price"].stringValue
        shop_price = json["shop_price"].stringValue
        member_price = json["member_price"].stringValue
        stock = json["stock"].stringValue
        comment_total = json["comment_total"].stringValue
        goods_desc = json["goods_desc"].arrayValue.map{
            
            goodsDesc.init(json: $0)
        }
    }
    
}
struct galleryModel {
    
    var img_url:URL?
    var thumb_url:URL?
    init(json:JSON) {
        thumb_url = json["thumb_url"].url
        img_url = json["img_url"].url
    }
}
struct commentModel {
    let content:String?
    let score:String?
    let nickname:String?
    let username:String?
    var user_avatar:URL?
    let imgs:[URL]?
    init(json:JSON) {
        content = json["content"].stringValue
        score = json["score"].stringValue
        nickname = json["nickname"].stringValue
        username = json["username"].stringValue
        user_avatar = json["user_avatar"].url
        imgs = json["imgs"].arrayValue.map{
            $0.url!
        }
    }
}
struct goodsDesc {
    
    let ratio:Double?
    var url:URL?
    init(json:JSON) {
        ratio = json["ratio"].doubleValue
        url = json["url"].url
    }
}
