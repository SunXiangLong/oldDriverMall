//
//  webVC.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class webVC:  baseViewController{

    @IBOutlet weak var webView: UIWebView!
    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url1 = url {
             webView.loadRequest(URLRequest(url:url1))
        }
       
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
extension webVC : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.navigationController?.progress = 0.5
        
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.navigationController?.finishProgress()
            
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.navigationController?.cancelProgress()
        
    }
}
