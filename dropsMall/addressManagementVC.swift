//
//  addressManagementVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/12.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
class addressTabCell: UITableViewCell {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UILabel!
    @IBOutlet weak var defaultBtn: UIButton!
    var btnTap:((_ type:dataType) -> Void)?
    var model:addressModel?{
        didSet{
            address.text = model?.address
            name.text = model?.consignee
            photo.text = model?.mobile
            defaultBtn.isSelected =    model?.is_default == "1"  
            

        }
        
    }
    
    @IBAction func tapBtn(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.btnTap!(.setDefaultaddressData(model: self.model!))
        case 1:
            self.btnTap!(.editAddressData(model: self.model!))
        case 2:
            self.btnTap!(.deleteAddressData(model: self.model!))
        default:break
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    
}

class addressManagementVC: baseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var selectTheAddress:((_ goods_id:Int)-> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView  = UIView()
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addAddress(_ sender: Any) {
        self.performSegue(withIdentifier: "addAddressVC", sender: nil)
    }
     var obser:AnyObserver<dataType>?
    
    
    func bindViewModel() {
       
        let just = Observable<dataType>.create { observer in
             self.obser = observer
//            self.collectionView.mj_header = SXBilibiliNormalRefresh.init(refreshingBlock: {
//                observer.on(.next(.initializeTheData))
//            })
            
            return Disposables.create()
        }
        
        let viewModel = addressViewModel.init(navigator: self.navigationController!)
        let intPut  =  addressViewModel.Input.init(type:just.startWith(.initAddressData).asDriver(onErrorJustReturn: .initAddressData) )
        
        let output = viewModel.transform(input: intPut)
        
        output.addressModelArr
            
            .filter{_ in 
                true
            }.drive(tableView.rx.items(cellIdentifier: "addressTabCell", cellType: addressTabCell.self)){ tv, item, cell in
                
                cell.model = item
                
                cell.btnTap = { type in
                    switch type {
                        
                    case .setDefaultaddressData(let model):
                        self.obser!.onNext(.setDefaultaddressData( model: model))
                    case .deleteAddressData(let model):
                        
                        self.obser!.onNext(.deleteAddressData( model: model))
                    case .editAddressData(let model):
                        self.performSegue(withIdentifier: "addAddressVC", sender: model.address_id)
                        
                    default:break
                    }
                }
                
            }.addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.asObservable().withLatestFrom( output.addressModelArr.scan([]){$1}) { (indexPath, addressModelList) -> addressModel in
            return addressModelList[indexPath.row]
        }.subscribe(onNext: { model in
            guard let block = self.selectTheAddress else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            block(Int.init(model.address_id!)!)
            self.navigationController?.popViewController(animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(disposeBag)

        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        log.debug("\(String.init(describing: type(of: self))) ---> 被销毁 ")
    }
    
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let idef = segue.identifier {
            switch idef {
            case  "addAddressVC":
                let VC = segue.destination as! addAddressVC
                VC.refreshTheAddress = {  _ in
                
                self.obser!.onNext(.initAddressData)
                }
                VC.title = "添加地址"
                VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/addresses/create");
                if let address_id   =  sender  {
                    let ID = address_id as! String
                    VC.url = URL.init(string: "https://api.laosijivip.xiaomabao.com/web/addresses/" + ID + "/edit")
                    VC.title = "编辑地址"
                }
            default:
                break
            }
        }
       
       
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        
     }
 
    
}

enum dataType {
    case initAddressData // 初始化或上拉加载更多地址数据
    case deleteAddressData(model:addressModel) //删除一个地址数据
    case setDefaultaddressData(model:addressModel) //设置默认地址数据
    case editAddressData(model:addressModel) //编辑地址数据
}
enum refreshStatus: Int {
    case dropDownSuccess // 下拉成功
    case pullSuccessHasMoreData // 上拉，还有更多数据
    case pullSuccessNoMoreData // 上拉，没有更多数据
    case invalidData // 无效的数据，请求失败或返回空数据等
}
final class addressViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let type:Driver<dataType>
    }
    struct Output {
        let addressModelArr: Driver<[addressModel]>
        let refreshStatus: Driver<refreshStatus>
    }
    
    private let navigator: UINavigationController
    init(navigator: UINavigationController) {
        
        self.navigator = navigator
    }
    func selected(model:addressModel) {
        print(model)
    }
    func transform( input: addressViewModel.Input) -> addressViewModel.Output {
        var obser:AnyObserver<refreshStatus>?
        var oldModel:[addressModel]?
        let refreshStatus = Observable<refreshStatus>.create{ observable in
            obser = observable
            return Disposables.create()
        }
        
        
        let addressModelArray = input.type.flatMapFirst { type -> SharedSequence<DriverSharingStrategy, [addressModel]> in
            switch type {
                
            case .initAddressData:
                return self.addressListData()
                    .filter({ model -> Bool in
                        oldModel = model
                        
                        if model.count > 0{
                            obser?.onNext(.dropDownSuccess)
                        }else{
                            obser?.onNext(.invalidData)
                        }
                        return true
                        
                    }).asDriver(onErrorJustReturn: [])
            case .deleteAddressData(let model):
                return self.deleteAddressData(model.address_id!).map{
                    if $0{
                        
                        oldModel = oldModel!.filter({ address -> Bool in
                            address.address_id == model.address_id ? false:true
                        })
                      
                    }
                    return oldModel!
                    
                    }.asDriver(onErrorJustReturn: [])
                
            case .setDefaultaddressData(let model):
                return self.setDefaultaddressData(model.address_id!).map{
                    if $0{
                         oldModel =  oldModel!.map{ address in
                            
                            if  address.address_id == model.address_id{
                                var  test1 = address
                                test1.is_default = "1"
                                return test1
                            }else if(address.is_default == "1") {
                                var  test1 = address
                                test1.is_default = "0"
                                return test1
                            }
                            
                            return address
                        }
                        
                    }
                        return oldModel!
                    
                    
                    }.asDriver(onErrorJustReturn: [])
                
                case .editAddressData(let model):
                    return self.setDefaultaddressData(model.address_id!).map{
                        if $0{
                            return oldModel!.map{ address in
                                
                                if  address.address_id == model.address_id{
                                    var  test1 = address
                                    test1.is_default = "1"
                                    return test1
                                }else if(address.is_default == "1") {
                                    var  test1 = address
                                    test1.is_default = "0"
                                    return test1
                                }
                                
                                return address
                            }
                            
                        }else{
                            return oldModel!
                        }
                        
                        }.asDriver(onErrorJustReturn: [])
                
            }
            
        }
        
        
        return Output.init(addressModelArr: addressModelArray, refreshStatus: refreshStatus.asDriverOnErrorJustComplete())
        
    }
    
    
    /// 获取地址列表
    ///
    /// - Returns: 地址列表数据
    func addressListData() -> Observable<[addressModel]> {
        return dropsMallAddTokenProvider.request(.addressList)
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
                $0["data"].arrayValue.map{
                    addressModel.init(json: $0)
                }
        }
    }
    func deleteAddressData( _ address_id:String) -> Observable<Bool>{
        
        return dropsMallAddTokenProvider.request(.deleteAddress(address_id: address_id))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .asObservable()
            .map{
                $0["status"]["code"].intValue == 200  
        }

    }
    
    
    func setDefaultaddressData(_ address_id:String) -> Observable<Bool> {
        return dropsMallAddTokenProvider.request(.setDefauladdress(address_id: address_id))
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .asObservable()
            .map{
                $0["status"]["code"].intValue == 200  
        }
    }
    
}
struct addressModel {
    
    let address_id:String?
    let consignee:String?
    let address:String?
    let mobile:String?
    var is_default:String?
    init(json:JSON) {
        address = json["address"].stringValue
        consignee = json["consignee"].stringValue
        address_id = json["address_id"].stringValue
        mobile = json["mobile"].stringValue
        is_default = json["is_default"].stringValue
    }
    
}
