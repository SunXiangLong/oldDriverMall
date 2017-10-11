//
//  productEvaluationVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/21.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import MJRefresh
import IBAnimatable
import YYText

class productEvaluationVC: baseViewController {

    @IBOutlet weak var text5: UILabel!
    @IBOutlet weak var text4: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var left: NSLayoutConstraint!

    
    var model : productEvaluationModel?{
        didSet{
            text1.text = model?.comment_summary?.comment_total
            text2.text = model?.comment_summary?.comment_praise_total
            text3.text = model?.comment_summary?.comment_medium_total
            text4.text = model?.comment_summary?.comment_bad_total
            text5.text = model?.comment_summary?.comment_pic_total
        }
    }
    let textList = ["all","praise","medium","bad","pic"]
    var goods_id:Int?
    var page =  1
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        tableView.delegate  = self
        getcommentData(name:textList.first!)
        // Do any additional setup after loading the view.
    }

    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        page = 1
        
        UIView.animate(withDuration: 0.5) { 
            self.view.layoutIfNeeded()
            self.left.constant = UIScreenWidth / 5 * CGFloat((sender.view?.tag)!) + 7.5
        }
        
        
        getcommentData(name:textList[(sender.view?.tag)!])
        
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
extension productEvaluationVC{
    

    func getcommentData(name:String) {
        
        let just = Observable<(Int,String)>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext((self.page,name))
                
                
            });
            
            return Disposables.create()
        }
        
        let  data = just.startWith((self.page,name)).flatMapFirst{
            
            dropsMallAddTokenProvider.request(.goodsComment(goods_id: self.goods_id!, page: $0.0, t: $0.1))
                .filter(statusCode: 200)
                .mapJSON()
                .map{
                    JSON.init($0)
                }.filter{ json  in
                    
                    if json["status"]["code"].intValue != 200{
                        HUD.flash(.labeledError(title: nil, subtitle:  json["status"]["msg"].stringValue))
                        return false
                    }
                    
                    return true
                }
                
                .map{
                    
                  productEvaluationModel.init(json: $0["data"])
                    
                }.filter{ model in
                    
                    self.tableView.mj_footer.endRefreshing()
                    
                    if self.page == 1{
                        self.model = model
                        self.model?.comment_list?.removeAll()
                    }
                    if (model.comment_list?.count)! >  0{
                        self.page = self.page + 1
                    }else{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        
                    }
                    return true
                }
                .map{
                    $0.comment_list!
                }

            
        }
        
    
       
        
      
        data.subscribe(onNext: { list in
                
               self.model?.comment_list =  (self.model?.comment_list)! + list
               self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }

    
    
}

extension productEvaluationVC:UITableViewDataSource,UITableViewDelegate {
    
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (model?.comment_list?[indexPath.row]
            .imgs?.count)! > 0 {
            return 160
        }
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = model?.comment_list {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goodsEvaluationCell", for: indexPath) as! goodsEvaluationCell
        cell.model = model?.comment_list?[indexPath.row]
        cell.itemSelected = { vc in
            
            self.present(vc, animated: true, completion: nil)
            
        }
        return cell
    }
    
}

struct productEvaluationModel {
    let comment_summary:commetSummaryModel?
    
    var  comment_list:[commentModel]?
    
    init(json:JSON) {
        comment_summary = commetSummaryModel.init(json: json["comment_summary"])
        comment_list = json["comment_list"].arrayValue.map{
             commentModel.init(json: $0)
        }
        
    }
    
    
}

struct commetSummaryModel {
    let comment_total:String?
    let comment_praise_total:String?
    let comment_medium_total:String?
    let comment_bad_total:String?
    let comment_pic_total:String?
    
    init(json:JSON) {
        comment_total = json["comment_total"].stringValue
        comment_praise_total = json["comment_praise_total"].stringValue
        comment_medium_total = json["comment_medium_total"].stringValue
        comment_bad_total = json["comment_bad_total"].stringValue
        comment_pic_total = json["comment_pic_total"].stringValue
    }
    
}
