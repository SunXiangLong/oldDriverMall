//
//  HomeVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/13.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import IBAnimatable
import RxDataSources
import CoreLocation

class headView: UICollectionReusableView {
    
    @IBOutlet weak var bannerView: GLCircleView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var modeList:[GLImageModel]?{
        didSet{
            self.bannerView.imageModelArray = modeList
            self.bannerView.timeInterval = 5
            self.bannerView.clickCircleViewClosure = { index in
                log.debug(index)
            }
        }
        
    }
    
    
    
}
class homeCategoryCell: UICollectionViewCell {
    @IBOutlet weak var cat_icon: UIImageView!
    
    var model:URL?{
        
        didSet{
            
            cat_icon.setImage(with: model)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
class homeSecondsKillCell: UICollectionViewCell,UICollectionViewDelegate {
    let disposeBag = DisposeBag()
    var itemSelected:((_ row:Int)-> Void)?
    @IBOutlet weak var collectionView: UICollectionView!
    var modelList:[goodsModel]?{
        
        didSet{
            
            collectionView.dataSource = nil
            collectionView.delegate = self
            Observable.just(modelList!)
                
                .bindTo(collectionView.rx.items(cellIdentifier: "secondsKillCell", cellType: secondsKillCell.self)){ tv, item, cell in
                    
                    cell.model = item
                    
                }.addDisposableTo(disposeBag)
            
            
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.itemSelected!(indexPath.row)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: (UIScreenWidth - 65)/3, height: (UIScreenWidth - 65)/3 + 60)
        collectionView.collectionViewLayout = layout
    }
}
class secondsKillCell: UICollectionViewCell {
    @IBOutlet weak var goods_icon: UIImageView!
    @IBOutlet weak var goods_price: UILabel!
    @IBOutlet weak var goods_originalPrice: UILabel!
    var model:goodsModel?{
        
        didSet{
            goods_icon.setImage(with: model?.goods_thumb_img)
            goods_price.text = model!.member_price
            goods_originalPrice.text =  model!.shop_price
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
class homeGoodsCell: UICollectionViewCell {
    @IBOutlet weak var goods_icon: UIImageView!
    @IBOutlet weak var goods_price: UILabel!
    @IBOutlet weak var goods_originalPrice: UILabel!
    @IBOutlet weak var goods_name: UILabel!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    var model:goodsModel?{
        
        didSet{
            goods_icon.setImage(with: model?.goods_thumb_img)
            goods_price.text =   model!.member_price
            goods_originalPrice.text =  model!.shop_price
            goods_name.text = model?.goods_name
            
            self.layoutIfNeeded()
            imageHeight.constant  =  goods_name.top - 10
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
class HomeVC: baseViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indexCell = 0
    
    @IBOutlet weak var searchTextField: AnimatableTextField!
    
    @IBOutlet weak var cityBtn: UIButton!
    var homeModel:homeModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
        let ss = CLLocationManager.init()
        ss.desiredAccuracy = kCLLocationAccuracyBest
        ss.delegate = self
        ss.distanceFilter = kCLDistanceFilterNone
        ss.startUpdatingLocation()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
    }
    
    override func reloadThe(){
    
     bindViewModel()
    
    }
    var oldCity = "北京"
    
    @IBAction   func citySelection(_ sender: Any) {
        
        
        
        let cityViewController = JFCityViewController.init()
        cityViewController.title = "城市"
        cityViewController.choseCityBlock {[unowned self]  (city) in
            let ss = city! as NSString
            let citynameStr = ss.replacingOccurrences(of: "市", with: "")
        
            self.cityBtn.titleLabel?.text = citynameStr;
            self.cityBtn.setTitle(citynameStr, for:.normal)
            log.debug(ss)
            log.debug(citynameStr)
            if self.oldCity != citynameStr{
                self.oldCity = citynameStr
                self.obser?.onNext(citynameStr)
            }
           
            
            
            
            
        }
        
        let  nav = UINavigationController.init(rootViewController: cityViewController)
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    func getLabWidth(_ labelStr:String,_ font:UIFont,_ height:CGFloat) -> CGFloat {
        
        
        
        let size = CGSize.init(width: 900, height: height)
        
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = labelStr.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        
        return strSize.width
        
        
    }
    var obser:AnyObserver<String>?
    func bindViewModel() {
        HUD.show(.systemActivity, onView: self.view)
        
     
        let just = Observable<String>.create { observer in
            self.obser = observer
            
            
            
            
            return Disposables.create()
        }
        
        let viewModel = homeViewModel.init(navigator: self.navigationController!)
        let intPut  =  homeViewModel.Input.init(type:just.startWith("北京"))
        let output = viewModel.transform(input: intPut)
        
        output
            .homModel
            .subscribe(onNext: { model in
                self.homeModel = model
                self.collectionView.reloadData()
                self.removeNoNetworkView()
                HUD.hide()
            }, onError: { error in
                
                log.error(error)
            }, onCompleted: {
                log.debug("Comp")
            }) {
                self.noNetwork(64)
                HUD.hide()
            }.addDisposableTo(disposeBag)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let ident = segue.identifier {
            switch ident {
            case "homeGoodsCategoryVC":
                let VC = segue.destination as!  homeGoodsCategoryVC
                VC.model = sender as? categoryModel
                VC.title = VC.model?.cat_name
            case "goodsDetailsVC":
                let VC = segue.destination as!  goodsDetailsVC
                VC.goods_id = sender as? Int
            default:break
            }
        }
    }
    
    
}
extension HomeVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let geoCoder  =  CLGeocoder.init()
        geoCoder.reverseGeocodeLocation(locations.last!) { (placemarks, error) in
            
            let  sss = placemarks?.first?.addressDictionary?["City"] as! String
            
            log.debug(sss)
        }
        
        manager.stopUpdatingLocation()
    }
    
    
}
extension HomeVC:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.performSegue(withIdentifier: "searchGoodsVC", sender: nil)
        
        return false
    }
}
extension HomeVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let rusableView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headView", for: indexPath) as! headView
            rusableView.modeList = homeModel?.bannerList.map{
                
                GLImageModel.init($0.banner!.absoluteString, type: .url)
            }
            rusableView.bannerView.clickCircleViewClosure = { row in
            
                let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
                VC.url = self.homeModel?.bannerList[row].url
                VC.title = self.homeModel?.bannerList[row].title
                self.navigationController?.pushViewController(VC, animated: true)
            }
            return rusableView
        default: return UICollectionReusableView()
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) ->Int{
        
        guard let _ = homeModel else {
            return 0
        }
        return 2 +  homeModel!.topicsList.count
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return homeModel!.categoryList.count
        case 1:
            return 1
        default:
            return  homeModel!.topicsList[section - 2].goods.count + 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCategoryCell", for: indexPath) as! homeCategoryCell
            
            cell.model = homeModel?.categoryList[indexPath.row].cat_icon;
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeSecondsKillCell", for: indexPath) as! homeSecondsKillCell
            cell.modelList = homeModel?.hotList
            cell.itemSelected = { row in
                
                self.performSegue(withIdentifier: "goodsDetailsVC", sender: self.homeModel?.hotList[row].goods_id)
            }
            return cell
        default:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCategoryCell", for: indexPath) as! homeCategoryCell
                cell.model = homeModel?.topicsList[indexPath.section - 2 ].banner
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeGoodsCell", for: indexPath) as! homeGoodsCell
                cell.model = homeModel?.topicsList[indexPath.section - 2].goods[indexPath.row - 1]
                return cell
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.performSegue(withIdentifier: "homeGoodsCategoryVC", sender: homeModel?.categoryList[indexPath.row])
            return
        }
        if indexPath.section > 1&&indexPath.row != 0 {
            
            self.performSegue(withIdentifier: "goodsDetailsVC", sender:homeModel?.topicsList[indexPath.section - 2].goods[indexPath.row - 1].goods_id)
            
        }else{
            
            let VC = UIStoryboard.init(name: "activity", bundle: nil).instantiateViewController(withIdentifier: "activityWebVC") as! activityWebVC
            VC.url = homeModel?.topicsList[indexPath.section - 2].url
            VC.title = homeModel?.topicsList[indexPath.section - 2].title
            self.navigationController?.pushViewController(VC, animated: true)
            
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch section {
            
        case 0:
            return UIEdgeInsetsMake(15,30, 15,30)
        case 1:
            return UIEdgeInsetsMake(0,0, 0,0)
        default:
            return UIEdgeInsetsMake(20,15, 15,20)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
            
        case 0:
            return 15
        case 1:
            return 0
        default:
            return 15
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0:
            return 40
        case 1:
            return 0
        default:
            return 20
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.section {
        case 0:
            return CGSize.init(width: (UIScreenWidth - 180) * 0.25, height: (UIScreenWidth - 180) * 0.25 * 141/100)
        case 1:
            return CGSize.init(width: UIScreenWidth , height: 250)
        default:
            return CGSize.init(width: (UIScreenWidth - 55) * 0.5, height:(UIScreenWidth - 55) * 0.5 * 440/321  )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        if section == 0 {
            return CGSize.init(width:UIScreenWidth, height: UIScreenWidth * 35/75)
        }
        
        return CGSize.init(width:0, height: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        
        
        return CGSize.init(width:0, height: 0)
        
    }
    
}
final class homeViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let type:Observable<String>
    }
    struct Output {
        let homModel: Observable<homeModel>
        let refreshStatus: Observable<refreshStatus>
    }
    
    private let navigator: UINavigationController
    init(navigator: UINavigationController) {
        
        self.navigator = navigator
    }
    func selected(model:addressModel) {
        print(model)
    }
    
    func transform( input: homeViewModel.Input) -> homeViewModel.Output {
        var obser:AnyObserver<refreshStatus>?
        let refreshStatus = Observable<refreshStatus>.create{ observable in
            obser = observable
            return Disposables.create()
        }
        let  mode  = input.type.flatMapFirst{
        
            self.initData(city: $0)
        
        }
//        let homModel = input.type.flatMapFirst { type -> SharedSequence<DriverSharingStrategy, homeModel> in
//            
//
//        }
        
        
        return Output.init(homModel: mode, refreshStatus: refreshStatus)
    }
    
    func initData(city:String) -> Observable<homeModel>{
        return Observable.combineLatest(homeCategoryList(),homeIndexData(city: city)) {
            
            return  homeModel.init(json: $1, category: $0.category)
        }
        
    }
    
    func homeCategoryList() -> Observable<versionModel> {
        
        let version = UserDefaults.standard.object(forKey: "version") as? Int
        
        return dropsMallAddTokenProvider.request(.category_v(version:version ?? 2 ))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                $0["status"]["code"].intValue == 200  
            }
            .asObservable()
            .map{
                versionModel.init(json: $0["data"])
        }
    }
    
    func homeIndexData(city: String) -> Observable<JSON> {
        return dropsMallAddTokenProvider.request(.index(city: city))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                $0["status"]["code"].intValue == 200  
            }
            .asObservable()
            .map{
                $0["data"]
        }
        
    }
}


//struct sectionsModel {
//    var headerModel: partitionModel
//    var  rows: [Item]
//    init(headerModel:partitionModel,rows: [Item]) {
//        self.headerModel = headerModel
//        self.rows = rows;
//    }
//}
//extension sectionsModel:SectionModelType{
//
//    typealias Item = livesModel
//    var items: [Item]{
//        return rows
//    }
//
//
//
//    init(original: sectionsModel, items: [sectionsModel.Item]) {
//        self = original
//        self.rows = items;
//
//    }
//
//}

struct homeModel {
    
    let categoryList:[categoryModel]
    let bannerList:[bannerModel]
    let topicsList:[topicsModel]
    let hotList:[goodsModel]
    
    init(json:JSON,category:[categoryModel]) {
        categoryList = category
        bannerList = json["ads"].arrayValue.map{
            bannerModel.init(json: $0)
        }
        topicsList = json["topics"].arrayValue.map{
            topicsModel.init(json: $0)
            
        }
        hotList = json["hot"].arrayValue.map{
            goodsModel.init(json: $0)
            
        }
    }
    
}
struct versionModel {
    
    let version:String
    let category:[categoryModel]
    
    init(json:JSON) {
        
        if let version =  json["version"].int {
            
            if let _ =  json["category"].array {
                
                UserDefaults.standard.set(version, forKey: "version")
                UserDefaults.standard.set(json.debugDescription, forKey: "DataVersion")
                UserDefaults.standard.synchronize()
            }
           
            
        }

        version = json["version"].stringValue
        
        if let arr =  json["category"].array {
            category = arr.map{
                categoryModel.init(json: $0)
            }
        }else{
            
            let dataStr = UserDefaults.standard.object(forKey: "DataVersion")
        
            if let data  = dataStr{
            
                let str = data as! String
                let json = JSON.init(parseJSON: str)
                log.debug(json)
                category = json["category"].arrayValue.map{
                    categoryModel.init(json: $0)
                }
                
            }else{
            
                let path = Bundle.main.path(forResource: "category", ofType:"json")
                let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
                let json1 = JSON.init(data: data!)
                
                
                category = json1["category"].arrayValue.map{
                    categoryModel.init(json: $0)
                }
            }
            
            
            

            
        }
        
    }
    
}

struct goodsModel{
    let goods_id:Int
    let goods_name:String
    let shop_price:String
    let market_price:String
    let member_price:String
    var goods_thumb_img:URL?
    
    
    
    init(json:JSON) {
        goods_id = json["goods_id"].intValue
        goods_name = json["goods_name"].stringValue
        shop_price = json["shop_price"].stringValue
        market_price = json["market_price"].stringValue
        member_price = json["member_price"].stringValue
        goods_thumb_img = json["goods_thumb_img"].url
        
    }
    
}
struct topicsModel{
    let title:String
    var banner:URL?
    var url:URL?
    let goods:[goodsModel]
    init(json:JSON) {
        title = json["title"].stringValue
        banner = json["banner"].url
        url = json["url"].url
        goods = json["goods"].arrayValue.map{
            goodsModel.init(json: $0)
        }
        
    }
}
struct bannerModel{
    let title:String
    var banner:URL?
    var url:URL?
    init(json:JSON) {
        title = json["title"].stringValue
        banner = json["banner"].url
        url = json["url"].url
        
    }
}
struct categoryModel {
    let cat_id:String?
    let cat_name:String?
    var cat_icon:URL?
    let child_categories:[childCategories]
    init(json:JSON) {
        cat_id = json["cat_id"].stringValue
        cat_name = json["cat_name"].stringValue
        cat_icon = json["cat_icon"].url
        child_categories = json["child_categories"].arrayValue.map{
            childCategories.init(json: $0)
        }
    }
}
struct childCategories {
    let cat_id:String
    let cat_name:String
    var cat_icon:URL?
    let child_categories:[categoryChildModel]
    init(json:JSON) {
        cat_id = json["cat_id"].stringValue
        cat_name = json["cat_name"].stringValue
        cat_icon = json["cat_icon"].url
        child_categories = json["child_categories"].arrayValue.map{
            categoryChildModel.init(json: $0)
        }
    }
}
struct categoryChildModel{
    let cat_id:String
    let cat_name:String
    var cat_icon:URL?
    init(json:JSON) {
        cat_id = json["cat_id"].stringValue
        cat_name = json["cat_name"].stringValue
        cat_icon = json["cat_icon"].url
    }
    
    
    
}

