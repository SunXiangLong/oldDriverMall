//
//  myCollectionVC.swift
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
import PKHUD
struct myCollectionModel {
    
    let goods_id:String?
    let goods_name:String?
    let goods_thumb_img:URL?
    let sale_price:String?
    init(json:JSON) {
         goods_id = json["goods_id"].stringValue
         goods_name = json["goods_name"].stringValue
         goods_thumb_img = json["goods_thumb_img"].url
         sale_price = json["sale_price"].stringValue
    }
    
    
}
class myCollectionCell: UITableViewCell {
    
    @IBOutlet weak var goodsImage: UIImageView!
    @IBOutlet weak var goodsPrice: UILabel!
    @IBOutlet weak var goodsName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    var model:myCollectionModel?{
        didSet{
            goodsImage.setImage(with: model?.goods_thumb_img, placeholder: #imageLiteral(resourceName: "placeholder_num2"))
            goodsPrice.text = "￥"+model!.sale_price!
            goodsName.text = model?.goods_name
        
        }
    
    }
    
    
    
    
}
class myCollectionVC: baseViewController {

    var page = 1
    var modelList:[myCollectionModel]?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noCollectionView: UIView!
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init()
        tableView.delegate = self
        loadMoreData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    @IBAction func deletes(_ sender: UIButton) {
        
        if let selectedItems = tableView!.indexPathsForSelectedRows {
            let arr =   selectedItems.map{
                (modelList?[$0.row].goods_id)!
            }
           
            collectionBatch(arr: JSON.init(arr)).subscribe(onNext: { isSuccess in
                if isSuccess {
                    for index in selectedItems {
                        self.modelList?.remove(at: index.row)
                    }
                    self.noCollectionView.isHidden = false
                    HUD.flash(.label("删除成功"))
                }else{
                    HUD.flash(.label("删除失败"))
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            
        
            
        }
    }
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func tapBtn(_ sender: UIButton) {
        
        if  sender.titleLabel!.text == "编辑"{
            tableView.isEditing = true
            tableView.allowsMultipleSelectionDuringEditing = true
            editBtn.isSelected = true
            bottomView.isHidden = false
            
        }else{
            
            

        }
        
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
extension myCollectionVC:UITableViewDelegate{

//    - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//    }
//    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle(rawValue: 1 | 2)!
    }

}
extension myCollectionVC{
    
    func collectionBatch(arr:Any) -> Observable<Bool> {
        
        return dropsMallAddTokenProviderHUD.request(.collectionBatch(arr: arr))
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
    func loadMoreData() {
        let just = Observable<Int>.create { observer in
            
            self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
                
                observer.onNext(self.page)
                
                
            });
            
            return Disposables.create()
        }
        
        
        let  data =   just.startWith(page).flatMapFirst{
            dropsMallAddTokenProvider.request(.collectionList(page: $0))
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
                        myCollectionModel.init(json: $0)
                    }
                    
                }.filter{ modelList in
                    self.tableView.mj_footer.endRefreshing()
                    if modelList.count >  0{
                        self.page = self.page + 1
                    }else{
                        
                        if self.page == 1{
                        
                            self.noCollectionView.isHidden = false
                        }else{
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                        
                        
                    }
                    return true
            }
            
        }
        
        
        
        data.scan([]){$0+$1}
            .filter{ arr in
                self.modelList = arr
                return true
            }
            .bindTo(tableView.rx.items(cellIdentifier: "myCollectionCell", cellType: myCollectionCell.self)){ tv, item, cell in
                cell.model = item
                cell.tintColor = UIColor.orange
            }.addDisposableTo(disposeBag)
        
        
    }
    
    
    
}
