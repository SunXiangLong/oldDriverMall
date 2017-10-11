//
//  activityVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/15.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON
import MJRefresh
import PKHUD
struct activityModel {
    let title:String
    var banner:URL?
    var url:URL?
    
    init(json:JSON) {
        title = json["title"].stringValue
        banner = json["banner"].url
        url = json["url"].url
    }
    
}
class activityCell: UITableViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var model:activityModel?{
        didSet{
            bannerImage.setImage(with: model?.banner)
            
            
        }
        
    }
}
class activityVC: baseViewController {
    var modeList:[activityModel]?
    
    @IBOutlet weak var tableView: UITableView!
    
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        tableView.delegate = self
        bindModel()
        
        // Do any additional setup after loading the view.
    }
    override func reloadThe() {
        bindModel()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let VC = segue.destination as! activityWebVC
        let model = sender as? activityModel
        VC.url = model?.url
        VC.title = model?.title
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension activityVC:UITableViewDelegate,UITableViewDataSource{

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let list = self.modeList {
            return list.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! activityCell
        cell.model = self.modeList?[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "activityWebVC", sender: self.modeList?[indexPath.section])
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreenWidth * 565/1125
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let view  = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreenWidth, height: 5))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        return 5
    }
}
extension activityVC{
    
    func bindModel() {
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            self.tableView.mj_footer.isHidden = true
            return Disposables.create()
        }
        
        
        
        
        let  data =   just.startWith(page)
            .flatMapFirst{
                dropsMallAddTokenProviderHUD.request(.topicList(page: $0))
                    .filter(statusCode: 200)
                    .mapJSON()
                    .map{
                        JSON.init($0)
                    }
                    .filter{
                        $0["status"]["code"].intValue == 200  
                    }
                    .map{
                        
                        $0["data"].arrayValue.map{
                            activityModel.init(json: $0)
                        }
                        
                    }.filter{ modelList in
                        self.tableView.mj_footer.endRefreshing()
                        
                        
                        if modelList.count >  0{
                            self.page = self.page + 1
                        }else{
                            
                            
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                            
                        }
                        return true
                }
                
        }
        
        
        
        data.scan([]){$0+$1}
            
            .subscribe(onNext: { (list) in
                self.modeList = list
                self.tableView.mj_footer.isHidden = false
                if self.modeList?.count == 0{
                    self.noData()
                    
                }else{
                    self.removeNoDataView()
                }
                self.tableView.reloadData()
                self.removeNoNetworkView()
            }, onError: nil, onCompleted: nil, onDisposed: {
                self.noNetwork(nil)
            })
            .addDisposableTo(disposeBag)
        
//        tableView.rx.itemSelected.asObservable().withLatestFrom(data.scan([]){$1 + $0}) { (indexPath, dataList) -> activityModel in
//             log.debug(indexPath.row)
//            log.debug(dataList.count)
//            return dataList[indexPath.row]
//            }.subscribe(onNext: { model in
//                log.debug(model)
//                
//            }, onError: nil, onCompleted: nil, onDisposed: nil)
//            .addDisposableTo(disposeBag)
    }
    
    
}
