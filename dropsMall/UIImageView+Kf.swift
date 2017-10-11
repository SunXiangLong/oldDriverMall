//
//  UIImageView+Kf.swift
//  dropsMall
//
//  Created by xiaomabao on 2017/7/14.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import Foundation
import Kingfisher
extension UIImageView{

    
    func setImage(with resource: Resource?,placeholder:Image? = nil)  {
        self.kf.setImage(with: resource, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
    }

    func setImage(with resource: Resource?)  {
        self.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
    }


}
