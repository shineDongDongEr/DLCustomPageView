//
//  UIColor+Extension.swift
//  DLPageView
//
//  Created by laidongling on 17/5/17.
//  Copyright © 2017年 LaiDongling. All rights reserved.

import UIKit

extension UIColor{

    //randColor(swift中class修饰的函数相当于oc中的类方法)
    class func randColor() -> UIColor{
        return UIColor(red:CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1)
        
    }
    //rgb()
    //swift中在extension中扩展构造函数
    //1.必须使用便利构造函数使用convenience
    //2.必须调用self.init()原有的某一个构造函数
    
    //默认参数的使用
   convenience init(r:CGFloat ,g:CGFloat ,b:CGFloat ,a: CGFloat = 1.0) {
    self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    //hex（16进制）
    convenience init?(hexString: String) {
        // ## # 0x 0X
        //1.判断字符串长度是否大于等于6
        guard hexString.characters.count >= 6 else {
            return nil
        }
        //2.将字符串全部转成大写
         var hexTempString = hexString.uppercased()
        //3.判断前缀是否是“##”或者“0X”
        if hexTempString.hasPrefix("##") || hexTempString.hasPrefix("0X") {
            hexTempString = (hexTempString as NSString).substring(from: 2)
            
        }
        //4.判断前缀是否是“#”
        if hexTempString.hasPrefix("#") {
            hexTempString = (hexTempString as NSString).substring(from: 1)
        }
        
        //5.获取rgb对应的 16进制(r:FF ,g:00 ,b:22)
        var range = NSRange(location: 0, length: 2)
        let rHex = (hexTempString as NSString).substring(with: range)
        range.location = 2
        let gHex = (hexTempString as NSString).substring(with: range)
        range.location = 4
        let bHex = (hexTempString as NSString).substring(with: range)
        
        //6.将16进制转成数值FF 22
        var r : UInt32 = 0
        var g : UInt32 = 0
        var b : UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)

        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
        
     }
}

//MARK:- 从颜色中获取rgb值
extension UIColor{
    func getRGBValue() -> (CGFloat, CGFloat, CGFloat) {
        guard let cmps = cgColor.components else {
            fatalError("重大错误，请确定颜色为rgb形式！！！")
        }
        return (cmps[0] / 255.0 , cmps[1] / 255.0, cmps[2] / 255.0)
    }
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        getRed(&red, green: &green, blue: &blue, alpha: nil)
//        return (red / 255, green / 255, blue / 255)
//    }
}
