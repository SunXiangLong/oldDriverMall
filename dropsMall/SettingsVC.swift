//
//  SettingsVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import Kingfisher
class SettingsOneCell: UITableViewCell {
    
    @IBOutlet weak var notice: UISwitch!
    
    
    @IBAction func informManagement(_ sender: UISwitch) {
        sender.isOn = !sender.isOn
    }
}
class SettingsTwoCell: UITableViewCell {
    
    @IBOutlet weak var imageCase: UILabel!
}
class SettingsThreeCell: UITableViewCell {
    
}
class SettingsVC: baseViewController {

    var cacheSize = "0.00M"
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView.init()
        tableView.delegate = self
    
        
        let cache = KingfisherManager.shared.cache

        cache.calculateDiskCacheSize { (size) in
         
            let num = Double(size)/(1024 * 1024)
            self.cacheSize =   "\(num.roundTo(places: 1))" + "M"
            self.tableView.reloadData()
            
            
        }

       
        
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

extension SettingsVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsOneCell", for: indexPath) as! SettingsOneCell
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTwoCell", for: indexPath) as! SettingsTwoCell
            cell.imageCase.text = self.cacheSize
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsThreeCell", for: indexPath) as! SettingsThreeCell
            
            return cell
        }
        
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 2:
            self.performSegue(withIdentifier: "VersionNumber", sender: nil)

        case 1:
            let cache = KingfisherManager.shared.cache
            cache.clearMemoryCache()
            self.cacheSize = "0.00M"
            self.tableView.reloadData()
        default:break
            
            
        }
        
    }
    
    
    
    
}
