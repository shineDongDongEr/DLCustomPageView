//
//  DLPageView.swift
//  DLPageView
//
//  Created by laidongling on 17/5/8.
//  Copyright © 2017年 LaiDongling. All rights reserved.
//

import UIKit

class DLPageView: UIView {
    fileprivate var titles: [String]
    fileprivate var childVCs: [UIViewController]
    fileprivate var parentVC: UIViewController
    fileprivate var titleStyle: DLPageStyle
    
    init(frame: CGRect, titles: [String], childVCs: [UIViewController], parentVC: UIViewController, titleStyle: DLPageStyle) {
        self.titles = titles
        self.childVCs = childVCs
        self.parentVC = parentVC
        self.titleStyle = titleStyle
        super.init(frame:frame)    //init之前必须初始化所有的属性
        setupUI()
        
    }
    //调用xib的时候会调用此方法，但不希望外界调用它，所以抛错误
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DLPageView{
    fileprivate func setupUI(){
        //添加titleView
        let titleFrame = CGRect(x: 0, y: 64, width: bounds.width, height: titleStyle.titleViewHeight)
        let  titleView = DLTitleView(frame: titleFrame, titles: titles, style: titleStyle)
        titleView.backgroundColor = UIColor.init(hexString: "##FF0022")
        addSubview(titleView)
        //添加contentView
        let contentFrame = CGRect(x:0, y: titleFrame.maxY, width: bounds.width, height: bounds.height - 64)
        let   contentView = DLContentView(frame: contentFrame, childVs: childVCs, parentVc: parentVC)
        contentView.backgroundColor = UIColor.randColor()
        addSubview(contentView)
        //两个View联系起来
        titleView.delegate = contentView
        contentView.delegate = titleView
        
    
    }

}
