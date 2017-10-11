//
//  UIImage+color.swift
//  bilibili
//
//  Created by xiaomabao on 2017/5/24.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import MJRefresh

extension UIImage {


    func imageWithTintColor(tintColor:UIColor, blendMode:CGBlendMode) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        tintColor.setFill()
        
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIRectFill(bounds)
        
        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        
        if blendMode != .destinationIn {
            
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
            
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return tintedImage!
        
    }
   class   func imageWithColor(_ color:UIColor,size:CGSize) -> UIImage? {
        guard  size.width > 0 && size.height > 0  else {
            return nil
        }
        
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let  context   = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    func creatImageWithColor(color:UIColor)->UIImage{
        let rect = CGRect(x:0,y:0,width:1,height:1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func generateCenterImageWithBgColor(_ bgImageColor:UIColor,bgImageSize:CGSize) -> UIImage {
        
        let bgImage = UIImage.imageWithColor(bgImageColor, size: bgImageSize)
        UIGraphicsBeginImageContext((bgImage?.size)!)
        bgImage?.draw(in: CGRect.init(x: 0, y: 0, width: (bgImage?.size.width)!, height: (bgImage?.size.height)!))
        
        self.draw(in: CGRect.init(x: ((bgImage?.size.width)! - self.size.width) * 0.5, y: ((bgImage?.size.height)! - self.size.height) * 0.5, width: self.size.width, height: self.size.width))
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
        
        
    }
}
extension Array{

    /// 随机获取数组中的不重复的值
    ///
    /// - Parameter num: 获取几个值
    /// - Returns: 获取的值
    func randomNumber(num:Int) -> Array<Element> {
        let random1 = createRandomMan(start: 0,end: self.count - 1)
        var arr =  [Element]();
        for _ in 0..<num {
             let ss = random1()

            arr.append(self[ss!])
        }
        
        return arr
    }

}
//随机数生成器函数
func createRandomMan(start: Int, end: Int) ->() ->Int! {
    //根据参数初始化可选值数组
    var nums = [Int]();
    for i in start...end{
        nums.append(i)
    }
    func randomMan() -> Int! {
        if !nums.isEmpty {
            //随机返回一个数，同时从数组里删除
            let index = Int(arc4random_uniform(UInt32(nums.count)))
            return nums.remove(at: index)
        }else {
            //所有值都随机完则返回nil
            return nil
        }
    }
    return randomMan
}

