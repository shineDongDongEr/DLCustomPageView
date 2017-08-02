//  ViewController.swift
//  DLPageView
//  Created by laidongling on 17/5/8.
//  Copyright © 2017年 LaiDongling. All rights reserved.

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置UI
        setupUI()
    }
}

extension ViewController
{
    func setupUI() {
        //你所需要的视图控制器title
        let titles = ["推荐", "shineDongDongEr","嘻哈一下", "段子",  "懵逼一下", "哈哈", "😀"]
        //创建控制器的数组，有几个title，就对应创建几个viewController
        var childVCs = [UIViewController]()
        for _ in 0..<titles.count{
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.randColor()
            childVCs.append(vc)
           }
        let titleStyle = DLPageStyle()
        
        //*************以下默认设置可根据你项目的实际情况进行修改******************
        
        //设置titleView（标题栏是否可以滚动，根据你的titles的个数来决定）
        titleStyle.isScrollEnabel = true
        //是否显示遮盖
        titleStyle.isShowCoverView = false
        //切换标题的时候，是否有动画
        titleStyle.isAnimate = true
        //是否显示下划线
        titleStyle.isShowBottomLine = false
        //是否需要缩放字体
        titleStyle.isNeedScale = true
        
        //*************以上默认设置可根据你项目的实际情况进行修改******************

        //初始化你的整个pageView（包括标题栏（titleView）和内容View（contentView））
        let pageView = DLPageView.init(frame: view.bounds, titles: titles, childVCs: childVCs, parentVC: self, titleStyle: titleStyle)
        //添加你的pageView到主视图上
        view.addSubview(pageView)

    }
}
