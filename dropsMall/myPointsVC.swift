//
//  myPointsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON
import MJRefresh
struct myPointsModel {
    let score:String
    let desc:String
    let record_time:String
    
    init(json:JSON) {
        score = json["score"].stringValue
        desc = json["desc"].stringValue
        record_time = json["record_time"].stringValue
    }
    
}
class myPointsCell: UITableViewCell {
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var record_time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var model:myPointsModel?{
        
        didSet{
            score.text = model?.score
            record_time.text = model?.record_time
        }
    }
    
    
}
class myPointsVC:  baseViewController {
    
    @IBOutlet weak var next_grade: UILabel!
    @IBOutlet weak var user_score: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var page = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshGrade()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        setHeadValue()
        loadMoreData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "webVC", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let _ = segue.identifier else {
            return
        }
        switch segue.identifier! {
        case "webVC":
            let path = Bundle.main.path(forResource: "integral", ofType:"html")
            let urlStr = URL.init(fileURLWithPath: path!)
            let VC = segue.destination as! webVC
            VC.url = urlStr
        default:break
        }
        
        
        // Pass the selected object to the new view controller.
    }
    
    
}
extension myPointsVC{
    
    func setHeadValue()  {
        next_grade.text = userInfo.user.next_grade
        user_score.text = userInfo.user.user_score
        
    }
    
    func refreshGrade() {
        
        dropsMallAddTokenProvider.request(.userGrade)
            .filter(statusCode: 200)
            .mapJSON()
            .map{
                JSON.init($0)
            }
            .filter{
                $0["status"]["code"].intValue == 200  
            }
            .map{
                
                $0["data"]
                
            }
            .asObservable()
            .subscribe(onNext: { json in
                userInfo.user.user_score = json["score"].stringValue
                userInfo.user.grade = json["grade"].stringValue
                userInfo.user.grade_icon = json["grade_icon"].url
                userInfo.user.next_grade  = json["grade_desc"].stringValue
                self.setHeadValue()
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
    }
    func loadMoreData() {
        
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            
            return Disposables.create()
        }
        
        
        let  data =   just.startWith(page).flatMapFirst{
            dropsMallAddTokenProvider.request(.scoreList(page: $0))
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
                        myPointsModel.init(json: $0)
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
            .bindTo(tableView.rx.items(cellIdentifier: "myPointsCell", cellType: myPointsCell.self)){ tv, item, cell in
                cell.model = item
            }.addDisposableTo(disposeBag)
        
        
    }
    
    
    
    
}
