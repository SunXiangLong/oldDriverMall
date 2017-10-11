//
//  physicalExaminationVC.swift
//  dropsMall
//
//  Created by imstayreal on 2017/8/10.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class physicalExaminationVC: baseViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.title = "体验查询"
        let url = URL.init(string: "https://api.xiaomabao.com/health3/index")
        let request = try? URLRequest.init(url:url! , method:.get, headers: ["accessToken":userInfo.user.token ?? ""] )
        webView.loadRequest(request!);

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
extension physicalExaminationVC : UIWebViewDelegate{
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
