//
//  homeGoodsCategoryVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/16.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import PageMenu


class homeGoodsCategoryVC: baseViewController {
    
    var model:categoryModel?
    var controllerArray : [goodsCategoryVC] = []
    var pageMenu:CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controllerArray =  model!.child_categories.map{ childModel -> goodsCategoryVC in
            
            let VC =  UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "goodsCategoryVC") as!goodsCategoryVC
            VC.pusVC = { good_id in
            
                let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "goodsDetailsVC") as! goodsDetailsVC
                VC.goods_id = good_id
                    
                    self.navigationController?.pushViewController(VC, animated: true)
            
            }
            VC.childModel = childModel
            VC.title = childModel.cat_name
            return VC
            
            
        }
        
        let parameters: [CAPSPageMenuOption] = [
            .menuHeight(40),
            .menuItemSeparatorWidth(4.3),
            .useMenuLikeSegmentedControl(false),
            .menuItemSeparatorPercentageHeight(0.5),
            .scrollMenuBackgroundColor(UIColor.init(hexString: "bcbdbe")),
//            .bottomMenuHairlineColor(UIColor.red),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor.init(hexString: "5D5D5D")),
            .selectionIndicatorColor(UIColor.orange),
            .menuItemWidthBasedOnTitleTextWidth(true)
            
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect.init(x: 0, y: 64, width: UIScreenWidth, height: UIScreenHeight), pageMenuOptions: parameters)
        pageMenu!.delegate = self
    
        self.view.addSubview(pageMenu!.view)
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

extension homeGoodsCategoryVC:CAPSPageMenuDelegate{
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
       
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        
        
       
    }
    
}
