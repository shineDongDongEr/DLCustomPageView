//
//  DLTitleView.swift
//  DLPageView
//
//  Created by laidongling on 17/5/8.
//  Copyright © 2017年 LaiDongling. All rights reserved.

import UIKit
//定义协议,添加class，表示该协议只能被类遵守
protocol DLTitleViewDelegate: class {
    //不用参数时，可以在参数前添加下划线
    func titleView(_ titleView: DLTitleView, targetIndex: Int)
}

class DLTitleView: UIView {
    fileprivate var style: DLPageStyle
    weak var delegate : DLTitleViewDelegate?
    fileprivate lazy var normalRGB: (CGFloat, CGFloat, CGFloat) = self.style.normalColor.getRGBValue()
    fileprivate lazy var selectRGB: (CGFloat, CGFloat, CGFloat) = self.style.selectColor.getRGBValue()
    fileprivate lazy var deltaRGB: (CGFloat, CGFloat, CGFloat) = {
        let deltaR = self.selectRGB.0 - self.normalRGB.0
        let deltaG = self.selectRGB.1 - self.normalRGB.1
        let deltaB = self.selectRGB.2 - self.normalRGB.2
        return (deltaR, deltaG, deltaB)
    }()

    //属性
    fileprivate var titles: [String]
//    weak var rect:CGRect = CGRect()
    //weak 一般不能修饰值类型
    fileprivate lazy var scrollview : UIScrollView = {
        let scrollview = UIScrollView(frame: self.bounds)
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.scrollsToTop = false
        return scrollview
    }()
    //下划线
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        return bottomLine
    }()
    //遮盖
    fileprivate lazy var coverView : UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverViewColor
        coverView.alpha = self.style.coverViewAlpha
        
        return coverView
    
    
    }()
    
    fileprivate lazy var titleLabels: [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0

    //MARK:- 构造函数
    init(frame: CGRect , titles: [String],style: DLPageStyle)
    {
        self.titles = titles
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:-  设置ui界面
extension DLTitleView{
    fileprivate func setupUI(){
        //1.添加scrollview
        addSubview(scrollview)
        
        //2.初始化所有label
        setupTitleLabels()
        
        //3.初始化下划线
        if style.isShowBottomLine {
            setupBottomLine()
        }
        //4.添加遮盖
        if style.isShowCoverView {
            addCoverView()
        }
    }
    
    private func addCoverView(){
//        scrollview.insertSubview(coverView, at: 0)
        scrollview.addSubview(coverView)
        let coverX: CGFloat = titleLabels.first!.frame.origin.x
        let coverY: CGFloat = (style.titleViewHeight - style.coverViewHeight) * 0.5
        let coverH: CGFloat = style.coverViewHeight
        let coverW: CGFloat = titleLabels.first!.frame.width
        coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        if style.isScrollEnabel {
            coverView.frame.size.width += 2 * style.coverMargin
            coverView.frame.origin.x -= style.coverMargin
        }
        coverView.layer.cornerRadius = style.coverViewCoradius

        
        
     }
    
    private func setupBottomLine(){
        scrollview.addSubview(bottomLine)
        bottomLine.frame = titleLabels.first!.frame
        bottomLine.frame.size.height = style.bottomLineHeight
        bottomLine.frame.origin.y = style.titleViewHeight - style.bottomLineHeight
    }
    
    private func setupTitleLabels(){
        
        for (i,title) in titles.enumerated() {
            //1.创建label
            let titleLabel: UILabel = UILabel()
            //2.设置label属性
            titleLabel.text = title
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.textColor =  (i == 0) ? style.selectColor : style.normalColor
            titleLabel.font = style.titleFont
            titleLabel.isUserInteractionEnabled = true
            //3.将label加到scrollview上去
            scrollview.addSubview(titleLabel)
            
            //4.监听label的点击
            let tapGes = UITapGestureRecognizer(target:self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
            //5.把label添加到数组中
            titleLabels.append(titleLabel)
        }
        //2.设置label的frame
        var titleLabelX : CGFloat = 0
        let  titleLabelY : CGFloat = 0
        var titleLabelW : CGFloat = bounds.width / CGFloat(titles.count)
        let titleLabelH : CGFloat = style.titleViewHeight
        
        for (i , titleLabel) in titleLabels.enumerated() {
            
            if style.isScrollEnabel {
                //可以滚动
                //a.根据字体font和内容算出宽度
                
                titleLabelW = (titleLabel.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName: style.titleFont], context: nil).width
                titleLabelX = i == 0 ? (style.titleMargin * 0.5) : (titleLabels[i - 1].frame.maxX + style.titleMargin)
                
            }else
            {
                //不能滚动
                titleLabelX = CGFloat(i) * titleLabelW
             }
            titleLabel.frame = CGRect(x: titleLabelX, y: titleLabelY, width: titleLabelW, height: titleLabelH)
        }
        
                //设置contentsize
        if style.isScrollEnabel {
            scrollview.contentSize = CGSize(width:titleLabels.last!.frame.maxX + style.titleMargin * 0.5 , height: 0)
        }
        //设置缩放
        if style.isNeedScale {
            titleLabels.first?.transform = CGAffineTransform(scaleX: style.maxScale, y: style.maxScale)
        }
        
     }

}

//MARK:-  事件监听
/*外部参数前加下划线*/
extension DLTitleView{
      func titleLabelClick(_ tapGes: UITapGestureRecognizer) {
        
        //0.判断目标选择的label有值
        guard  let targetLabel = tapGes.view as? UILabel else{
            return
        }
        //1.判断是否是之前点击过的label
        guard  targetLabel.tag != currentIndex else{
            return
        }
        
        print("点击了第\(targetLabel.tag)个标题 currentIndex = \(currentIndex)")
        //2.让新的label选中
    
        let sourceLabel = titleLabels[currentIndex];
        sourceLabel.textColor = style.normalColor;
        targetLabel.textColor = style.selectColor;
        
        //3.赋值新的currentIndex
        currentIndex = targetLabel.tag;
        //4.调整label位置点击居中
        titleLabelSelected()
        //5.通知代理
        //可选链：如果有值执行代码，没有值，什么都不发生
        delegate?.titleView(self, targetIndex: currentIndex)
        //6.调整缩放title
        if style.isNeedScale {
            UIView.animate(withDuration: 0.25, animations: {
                sourceLabel.transform = CGAffineTransform.identity
                targetLabel.transform = CGAffineTransform(scaleX: self.style.maxScale, y: self.style.maxScale)
            })
        }

        //7.调整bottomLine位置
        if style.isShowBottomLine {
         
            if self.style.isAnimate {
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                    self.bottomLine.frame.size.width = targetLabel.frame.width
                })
            }else
            {
                    bottomLine.frame.origin.x = targetLabel.frame.origin.x
                    bottomLine.frame.size.width = targetLabel.frame.width
            }
        }
        //8.调整coverView位置
        if style.isShowCoverView {
            UIView.animate(withDuration: 0.3, animations: { 
                self.coverView.frame.origin.x = self.style.isScrollEnabel ? (targetLabel.frame.origin.x - self.style.coverMargin):targetLabel.frame.origin.x
                self.coverView.frame.size.width = self.style.isScrollEnabel ? (targetLabel.frame.width + 2 * self.style.coverMargin):targetLabel.frame.width

            })
            
        }
        
     }
    
    //titleLabel被选中
        fileprivate  func titleLabelSelected(){
         guard style.isScrollEnabel else {return}
        let targetLabel = titleLabels[currentIndex]
        var offsetX = targetLabel.center.x - scrollview.bounds.size.width * 0.5;
        if offsetX < 0
        {
            offsetX = 0
        }
        let maxOffsetX = scrollview.contentSize.width - scrollview.bounds.width;
        if offsetX > maxOffsetX
        {
            offsetX = maxOffsetX
        }
        scrollview.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

//MARK:- 遵循DLContentViewDelegate
extension DLTitleView:DLContentViewDelegate{
    func contentView(_ contentView: DLContentView, didEndScroll inIndex: Int) {
       currentIndex = inIndex
       titleLabelSelected()
        
    }
    
    func contentView(_ contentView: DLContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
//        print(sourceIndex, targetIndex, progress)
        //1.根据index获取对应的label
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        //2.改变颜色
        
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        print("sourceLabel:\(sourceLabel.textColor)  andTargetLabel:\(targetLabel.textColor)")
        
        //3.计算bottomLIne的width变化
        let detalWidth = targetLabel.frame.width - sourceLabel.frame.width
        let detalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        if style.isShowBottomLine {
           
            bottomLine.frame.size.width = sourceLabel.frame.size.width + progress * detalWidth
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + detalX * progress
         
            
        }
        //4.title缩放变化
        if style.isNeedScale {
            let detalScale = style.maxScale - 1.0
            sourceLabel.transform = CGAffineTransform(scaleX: style.maxScale - detalScale * progress, y: style.maxScale - detalScale * progress)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + detalScale * progress, y: 1.0 + detalScale * progress)
            
        }

        //5.coverView渐变
        if style.isShowCoverView {
            UIView.animate(withDuration: 0.3, animations: { 
                self.coverView.frame.origin.x = self.style.isScrollEnabel ? (sourceLabel.frame.origin.x - self.style.coverMargin + detalX * progress): (sourceLabel.frame.origin.x + detalX * progress)
                self.coverView.frame.size.width = self.style.isScrollEnabel ? ((sourceLabel.frame.size.width + detalWidth * progress) + 2 * self.style.coverMargin) : (sourceLabel.frame.size.width + detalWidth * progress)

            })
        }
        
    }
}

