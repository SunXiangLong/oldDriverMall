//
//  searchGoodsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/17.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import RxDataSources
import PKHUD
import IBAnimatable
import MJRefresh

class searchGoodsCell: UITableViewCell {
    let disposeBag = DisposeBag()
    var itemSelected:((_ row:Int,_ section:Int)-> Void)?
    var section:Int?
    @IBOutlet weak var noSearchHistory: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var modelList:[String]?{
        
        didSet{
            
            collectionView.dataSource = nil
            Observable.just(modelList!)
                .filter{ list in
                    self.noSearchHistory.isHidden = list.count > 0  
                    return true
                }
                
                .bindTo(collectionView.rx.items(cellIdentifier: "goodsCategoryCollCell", cellType: goodsCategoryCollCell.self)){ tv, item, cell in
                    //                    goodsCategoryCell
                    cell.text = item
                    
                }.addDisposableTo(disposeBag)
            
            collectionView.rx.itemSelected.asObservable().subscribe(onNext: { indexPath in
                log.debug(indexPath.row)
                self.itemSelected!(indexPath.row,self.section!)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
            
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 15)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize.init(width: (UIScreenWidth - 45)/4, height: 30)
        collectionView.collectionViewLayout = layout
    }
    
}
class searchGoodsVC: baseViewController {
    
    
    
    var dataStr:[[String]]?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    lazy var searchHistory:[String] = {
        if let list = UserDefaults.standard.value(forKeyPath: "searchHistory"){
            
            return list as! [String]
            
        }
        
        return []
    }()
    
    
    @IBOutlet weak var searchGoodsTextField: AnimatableTextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hotSearch()
        tableView.delegate = self
        searchGoodsTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func deleteSearchHistory(_ sender: Any) {
        
        let aleView = UIAlertController.init(title: "提示", message: "确定删除全部的历史记录", preferredStyle: .alert)
        aleView.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        aleView.addAction(UIAlertAction.init(title: "确定", style: .default, handler: {[unowned self]  _ in
            UserDefaults.standard.removeObject(forKey: "searchHistory")
            self.dataStr = [[] ,self.dataStr!.last!]
        }))
        
        self.present(aleView, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let ident = segue.identifier  {
            
            switch ident {
            case "searchResultsVC":
                let VC = segue.destination as! searchResultsVC
                VC.searchText = sender as? String
                VC.title = sender as? String
            default:break
            }
            
        }
    }
    
    
}

extension searchGoodsVC{
    
    func hotSearch() {
        
        dropsMallAddTokenProvider.request(.searchRecommend)
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
                    $0.stringValue
                }
                
            }
            .asObservable()
            .subscribe(onNext: { arr in
                
              self.dataStr = [ self.searchHistory ,arr]
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
}
extension searchGoodsVC:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let  results = (self.dataStr?[indexPath.section].count)! / 4
        let  remainder =  (self.dataStr?[indexPath.section].count)! % 4
        
        if indexPath.section == 0 &&  self.dataStr?[indexPath.section].count == 0  {
        
            return 40
        }
        if remainder != 0 {
        
            return CGFloat((results + 1) * 30 + (results + 2) * 10)
        
        }
        
        return CGFloat(results * 30 +  (results + 1) * 10)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreenWidth, height: 50))
        view.backgroundColor = UIColor.white
        let lable = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: UIScreenWidth, height: 50))
        lable.textColor = UIColor.init(hexString: "bcbcbc")
        lable.font = UIFont.init(name: "MicrosoftYaHei", size: 18)
        view.addSubview(lable)
        switch section {
        case 1:
            lable.text = "大家都在搜"
            return view
            
        default:
            return UIView.init()
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 50
        case 2:
            return 50
        default:
            return 0.001
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let _ = self.dataStr {
            return 2
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchGoodsCell", for: indexPath) as! searchGoodsCell
        cell.modelList = self.dataStr![indexPath.section]
        cell.section = indexPath.section
        cell.itemSelected = { row,section  in
            
            self.performSegue(withIdentifier: "searchResultsVC", sender: self.dataStr![section][row])
        }
        return cell
        
    }
    
    
}

extension searchGoodsVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
       
     
        var isNO = false
        
        for item in self.searchHistory {
            if item == textField.text! {
               isNO = true
            }
        }
        if !isNO {
            self.searchHistory.append(textField.text!)
        }
    
        
        
        self.dataStr = [self.searchHistory,dataStr!.last!]
        
        
        UserDefaults.standard.set(self.searchHistory as NSArray, forKey: "searchHistory")
        UserDefaults.standard.synchronize()
        textField.resignFirstResponder()
        self.performSegue(withIdentifier: "searchResultsVC", sender: textField.text!)
        return true
    }
}

