//
//  BilibiliApi.swift
//  bilibili
//
//  Created by xiaomabao on 2017/5/18.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import Foundation
//
//  XiaoMaBaoAPI.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/24.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import Result
import PKHUD
import SwiftyJSON
public let  HN = "Helvetica Neue";

/// 默认域名
let  api_live = "https://api.laosijivip.com";
//let appendedParams: Dictionary<String, String> = [:]
public func JSONResponseDataFormatter(_ data: Data) -> Data {
    
    
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        
        return data // fallback to original data if it can't be serialized.
    }
}

let endpointClosure = { (target: dropsMall) -> Endpoint<dropsMall> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    return Endpoint<dropsMall>(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task)
        //        .adding(parameters: appendedParams as [String : AnyObject])
        .adding(newHTTPHeaderFields:  ["device":"ios","accessToken":userInfo.user.token ?? "","Content-Type":"application/x-www-form-urlencoded"])
}

let endpointClosureX = { (target: dropsMall) -> Endpoint<dropsMall> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    return Endpoint<dropsMall>(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task)
        //        .adding(parameters: appendedParams as [String : AnyObject])
        .adding(newHTTPHeaderFields:  ["accessToken":userInfo.user.token ?? "","Content-Type":"application/x-www-form-urlencoded"])
}
let  dropsMallAddTokenProvider =  RxMoyaProvider<dropsMall>(endpointClosure: endpointClosure,plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
let  dropsMallProvider =  RxMoyaProvider<dropsMall>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

let dropsMallAddTokenProviderHUD =  RxMoyaProvider<dropsMall>(endpointClosure: endpointClosure,plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter),RequestAlertPlugin()])


/// 自定义插件实现请求添加HUD
final class RequestAlertPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        //实现发送请求前需要做的事情
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
       
        HUD.show(.systemActivity, onView: UIViewController.topViewController()?.view)
        
    }
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        HUD.hide()
        guard case Result.failure(_) = result else { return }//只监听失败
        HUD.flash(.labeledError(title: "提示", subtitle: "无网络连接，请检查下你的网络！"), delay: 1)
    }
}


public enum dropsMall {
    
    // MARK: - 登录
    case authLogin(username:String,password:String)
    // MARK: - 刷新token
    case authRefreshToken
    // MARK: - 退出登录
    case authLogout
    // MARK: - 用户注册
    case authRegister(dic:[String:String])
    // MARK: - 找回密码
    case authFindpass(dic:[String:String])
    // MARK: - 获取短信验证码
    case authSendcode(mobil:String)
    // MARK: - 注册当司机
    case authDriverRegister(dic:[String:String])
    // MARK: - 地址列表数据
    case addressList
    // MARK: - 删除地址
    case deleteAddress(address_id:String)
    // MARK: - 设置默认地址
    case setDefauladdress(address_id:String)
    // MARK: -  首页分类数据
    case category_v(version:Int)
    // MARK: - 首页数据
    case index(city:String)
    // MARK: - 用户信息刷新
    case refreshUser
    // MARK: - 用户积分列表
    case scoreList(page:Int)
    // MARK: - 获取用户积分信息。
    case userGrade
    // MARK: - 用户收藏列表
    case collectionList(page:Int)
    // MARK: - 收藏
    case collection(good_id:Int)
    // MARK: - 取消收藏
    case collectionBatch(arr:Any)
    // MARK: - 活动列表
    case topicList(page:Int)
    // MARK: - 更换用户头像
    case authModify( image:UIImage,name:String)
    // MARK: - 用户签到
    case userSign
    // MARK: -  根据分类找商品
    case goodsCategory(ID:String,page:Int)
    // MARK: -  商品详情
    case goodsDetails(ID:Int)
    // MARK: -  热搜
    case searchRecommend
    // MARK: -  搜索商品
    case searchGoods(goodName:String, page:Int)
    // MARK: -  添加商品到购物车
    case addCart(goods_id:Int, goods_number:Int)
    // MARK: -  购物车列表
    case getCartList
    // MARK: - 从购物车删除商品
    case deleteCareGoods( goods_id:Any)
    // MARK: - 去结算
    case orderCheckout( address_id:String,voucher:String,coupon_id:String)
    // MARK: -获取优惠券信息
    case orderCheckVoucher(voucher:String)
    // MARK: - 购物车商品选中和取消选中
    case cartBath(goods_ids:Any,type:String)
    // MARK: - 提交订单数据
    case orderCreate(address_id:String,remark:String,voucher:String,coupon_id:String)
    
   
    // MARK: - 商品评价
    case goodsComment(goods_id:Int,page:Int,t:String)
    // MARK: - 获取退换货商品
    case  aftersalePrepare(order_sn:String)
    // MARK: - 提交退换货数据
    case  aftersaleOperate(data:[String:Any],dataImage:[UIImage])
    // MARK: - 获取可评价商品数据
    case  aftersaleCommetshow(parent_order_sn:String)
    // MARK: - 发起评价商品
    case aftersaleCommet(data:[String:Any],imageList:[[UIImage]])
     // MARK: - 提交物流单号
    case aftersaleFilllogistic(data:[String:Any])
    // MARK: - 获取支付宝支付签名参数
    case pay(parent_order_sn:String)
    // MARK: - 获取微信支付签名参数
    case wxChatPay(parent_order_sn:String)
    
    case coupon(page:Int)
    
    case orderCoupon()
}
// MARK: - 请求的参数
extension dropsMall:TargetType{
   
    
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: api_live)!
        }
    }
    public var headers: [String : String]? {
        return nil;
    }
    public var path: String {
        switch self {
        case  .authLogin(_, _):
            return "/auth/login"
        case  .authRefreshToken:
            return "/auth/refresh"
        case  .authLogout:
            return "/auth/logout"
        case .addressList:
            return "/address/list"
        case .deleteAddress(let  address_id):
            return "/address/" + address_id
        case .setDefauladdress(let  address_id):
            return "/address/" + address_id
        case .category_v(let version):
            return  "/category/v/\(version)"
        case .refreshUser:
            return "/user"
        case .scoreList(let page ):
            return "/scoreList/\(page)"
        case .collectionList(let page ):
            return "/collection/\(page)"
        case .collectionBatch(_):
            return "/collection/batch"
        case .topicList(let page):
            return "/topicList/\(page)"
        case .authModify(_, name: _):
            return "/auth/modify"
        case .userGrade:
            return "/user/grade"
        case .userSign:
            return "/user/sign"
        case .authSendcode(_):
            return "/auth/sendcode"
        case .authDriverRegister(_):
            return "/auth/driver_register"
        case .authRegister(_):
            return "/auth/register"
        case .authFindpass(_):
            return "/auth/findpass"
        case .index(_):
            return "/index"
        case .goodsCategory(let Id, _):
            return "/goods/" + Id + "/cat"
        case .goodsDetails(let Id):
            return "/goods/\(Id)"
        case .collection(_):
            return "/collection"
        case .searchRecommend:
            return "/search_recommend"
        case .searchGoods(let goodName,_):
            return "/search/" + goodName
        case .getCartList,.addCart(_,_),.deleteCareGoods(_):
            return "/cart"
        case .orderCheckout(_,_,_):
            return "/order/checkout"
        case.orderCheckVoucher(_):
            return "/order/check/voucher"
        case .cartBath(_, _):
            return "/cart/batch"
        case .orderCreate(_, _, _,_):
            return "/order/create"
        case .pay(let parent_order_sn):
            return "/pay/" + parent_order_sn
        case .goodsComment(let goods_id, _,_):
            return "/goods/\(goods_id)/comment"
        case .aftersalePrepare(let order_sn):
            return "/aftersale/prepare/" + order_sn
        case .aftersaleOperate(_, _):
            return "/aftersale/operate"
        case .aftersaleCommetshow(let parent_order_sn):
            return "/aftersale/commetshow/" + parent_order_sn
        case .aftersaleCommet(_,_):
           return "/aftersale/comment"
        case .aftersaleFilllogistic(_):
            return "/aftersale/filllogistic"
        case .wxChatPay(let parent_order_sn):
            return "/wpay/" + parent_order_sn
        case .coupon(let page):
            return "coupon/\(page)"
        case .orderCoupon():
            return "order/coupon"
        }
        
    }
    public var method: Moya.Method {
        switch self {
        case   .authLogin(_, _),.authRefreshToken,.authLogout,.setDefauladdress(_),.collectionBatch(_),.authModify(_, name: _),.authSendcode(_),.authDriverRegister(_),.authRegister(_),.authFindpass(_),.index(_),.orderCheckout(_,_,_),.orderCheckVoucher(_),.cartBath(_, _),.deleteCareGoods(_),.aftersaleOperate(_, _),.aftersaleCommet(_,_),.aftersaleFilllogistic(_):
            return .post
        case .addressList,.category_v(_),.refreshUser,.scoreList(_),.collectionList(_),.topicList(_),.userGrade,.goodsCategory(_,_),.goodsDetails(_),.searchRecommend,.searchGoods(_,_),.getCartList,.pay(_),.goodsComment(_, _,_),.aftersalePrepare(_),.aftersaleCommetshow(_),.wxChatPay(_),.coupon(_),.orderCoupon():
            return .get
        case .deleteAddress(_):
            return .delete
        case .userSign,.collection(_),.addCart(_,_),.orderCreate(_, _, _,_):
            return .put
        }
        
    }
    public var parameters: [String: Any]? {
        switch self {
        case .authLogin( let username,let  password):
            return ["username":username,"password":password]
        case .setDefauladdress(_):
            return ["is_default":"1"];
        case   .collectionBatch(let arr):
            return ["method":"delete","ids":arr]
        case   .authModify(_, let name):
            return ["nickname":name]
        case   .authSendcode(let mobilePhone):
            return ["phone":mobilePhone]
        case .authDriverRegister(let dic),.authRegister(let dic),.authFindpass(let dic):
            return dic
        case .goodsCategory(_,let page):
            return ["page":"\(page)"]
        case .collection(let good_id):
            return ["goods_id":good_id]
        case .searchGoods(_,let page):
            return ["page":"\(page)"]
        case .deleteCareGoods(let arr):
            return ["goods_ids":arr]
        case .addCart(let goods_id,let goods_number):
            return ["goods_id":goods_id,"goods_number":goods_number]
        case .orderCheckVoucher(let voucher):
            return ["voucher":voucher]
        case .orderCheckout(let address_id,let voucher,let coupon_id):
            return ["address_id":address_id,"voucher":voucher,"coupon_id":coupon_id]
        case .cartBath(let arr, let type):
            return ["goods_ids":arr,"type":type,"param":"flow"];
        case .orderCreate(let address_id, let remark,let  voucher,let coupon_id):
            return ["address_id":address_id,"remark":remark,"voucher":voucher,"coupon_id":coupon_id]
        case .index(let city):
            return ["city":city]
        case .goodsComment(_,let page,let t):
            return ["p":page,"t":t]
        case .aftersaleOperate(let data, _),.aftersaleCommet(let data, _),.aftersaleFilllogistic(let data):
            return data
        
        default:
            return [:]
        }
    }
    public var task: Task {
        switch self {
        case .authModify(let image, _):
            let data = UIImageJPEGRepresentation(image, 0.7)
            let img = MultipartFormData(provider: .data(data!), name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg")
            return  .uploadMultipart([img])
        case .aftersaleOperate(_, let dataImage):
            var imageList:[MultipartFormData] = []
            for item in dataImage.enumerated() {
                let form =  MultipartFormData(provider: .data(UIImageJPEGRepresentation(item.element,0.7)!), name: "review_img_\(item.offset + 1)", fileName: "review_img.jpg", mimeType: "image/jpeg")
                imageList.append(form)
            }
            return .uploadMultipart(imageList)
            
        case .aftersaleCommet(let data,let imageList):
            
            var list:[MultipartFormData] = []
            
            for item in imageList.enumerated() {
                let json =  data["comment"] as! JSON
                let good_id = json.arrayValue[item.offset]["goods_id"].intValue
                for childItem in item.element.enumerated() {
                    let form =  MultipartFormData(provider: .data(UIImageJPEGRepresentation(childItem.element,0.7)!), name: "goods_\(good_id)_\(childItem.offset + 1)", fileName: "goods_image.jpg", mimeType: "image/jpeg")
                
                    list.append(form)
                }
                
                
            }
            if list.count > 0 {
                return   .uploadMultipart(list)
            }
             return .requestPlain
            
        default:
            return .requestPlain
        }
        
    }
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var validate: Bool {
        
        switch self {
        default:
            return true
        }
    }
    public var sampleData: Data {
        return "请检查你的网络连接和联系客服".data(using: String.Encoding.utf8)!
        //        switch self {
        //        case .getCategoryGoods(_, _):
        //
        //        case .getCategoryGoodsTest(_, _):
        //            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        //        }
    }
    
}

// MARK: - 字符串转url字符串
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
