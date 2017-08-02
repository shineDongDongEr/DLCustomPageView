//
//  DLContentView.swift
//  DLPageView
//
//  Created by laidongling on 17/5/8.
//  Copyright © 2017年 LaiDongling. All rights reserved.
//

import UIKit

private let KContentCellId = "cellId"
/*
    self.常见有两个地方不能省略
    1.和上下文有歧义的时候
    2.闭包中的self不能省略
 */
protocol DLContentViewDelegate: class {
    func contentView(_ contentView: DLContentView, didEndScroll inIndex: Int)
    func contentView(_ contentView: DLContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}

class DLContentView: UIView {
    //MARK:- 属性
    weak var delegate: DLContentViewDelegate?
    fileprivate var startOffsetX: CGFloat = 0
    fileprivate var isForbid: Bool = false
    fileprivate  var childVs: [UIViewController]
    fileprivate  var parentVc: UIViewController
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: KContentCellId)
        
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        
        return collectionView
    }()
    
    //构造函数
       init(frame: CGRect , childVs: [UIViewController], parentVc: UIViewController) {
        self.childVs = childVs
        self.parentVc = parentVc
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK:- 设置UI界面
extension DLContentView{
   fileprivate func setupUI() {
   
    //1.将childVCs中的控制器添加到parentVC中
    for childVc in childVs{
        parentVc.addChildViewController(childVc)
    
    }
    //2.给collectionView添加属性
     addSubview(collectionView)
    
    }


}

//MARK:-数据源 UICollectionViewDataSource
extension DLContentView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        //1.添加cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KContentCellId, for: indexPath)
        
        //2.删除因为重用而重复添加的View
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        //3.把外界传进来的自控制器上的View添加到cell.contenView上面去
        let childVc = childVs[indexPath.row];
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }

}

//MARK:-代理 UICollectionViewDelegate
extension DLContentView:UICollectionViewDelegate{
    //scrollView 减速完成
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDeceEnd()
    }
    //scrollView 拖拽完成
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDeceEnd()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbid = false
        startOffsetX = scrollView.contentOffset.x
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
       //0.判断有没有进行滑动
       guard  (contentOffsetX != startOffsetX) && !isForbid else {
            return
        }
        //1.定义出变量
        var sourceIndex = 0
        var targetIndex = 0
        var progress: CGFloat = 0
        
        let collectionW = collectionView.bounds.width
        //2.判断左滑还是右滑
        if contentOffsetX > startOffsetX     //左滑
        {
            sourceIndex = Int(contentOffsetX / collectionW)
            targetIndex = sourceIndex + 1
            //一般有“+1”，一定要判断数组越界问题
            if targetIndex >= childVs.count {
                targetIndex = childVs.count - 1
            }
            //刚好左滑动一个宽度的时候
            progress = (contentOffsetX - startOffsetX) / collectionW
            if (contentOffsetX - startOffsetX) == collectionW
            {
                targetIndex = sourceIndex;
            }

            
         }else                                //右滑
        {
            targetIndex = Int(contentOffsetX / collectionW)
            sourceIndex = targetIndex + 1
            progress = (startOffsetX - contentOffsetX) / collectionW
            
        }
        //swift中的拼接，直接可以用\()
//        print("sourceIndex\(sourceIndex),targetIndex\(targetIndex),progress\(progress)")
        
        delegate?.contentView(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
    
    private func scrollViewDeceEnd(){
        let index = (Int)(collectionView.contentOffset.x / collectionView.bounds.width)
        delegate?.contentView(self, didEndScroll: index)
    }
    
}

//MARK:- 遵守DLTitleViewDelegate
extension DLContentView:DLTitleViewDelegate{
    func titleView(_ titleView: DLTitleView, targetIndex: Int) {
    //0.禁止掉代理方法（防止contenview滚动触发的代理方法）
        isForbid = true
    //1.创建indexPath
        let indexPath = IndexPath(item: targetIndex, section: 0)
        
    //2.滚动到对应的位置
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}
