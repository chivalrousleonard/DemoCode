//
//  PopAnimator.swift
//  Cook
//
//  Created by Dariel on 16/7/25.
//  Copyright © 2016年 Dariel. All rights reserved.
//

import UIKit

// 转场动画的原理:
/**
    当两个控制器发生push或dismiss的时候,系统会把原始的view放到负责转场的控制器容器中,也会把目的的view也放进去,但是是不可见的,因此我们要做的就是把新的view显现出来,把老的view移除掉

  */


// 遵守协议
class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->())?

    // 动画持续时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    // 
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 获得容器
        let containerView = transitionContext.containerView()!
        // 获得目标view
        // viewForKey 获取新的和老的控制器的view
        // viewControllerForKey 获取新的和老的控制器
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        // 一直是需要做动画的view
        let herbView = presenting ? toView : fromView
        
        // 获取初始和最终的frame
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        // 设置缩放比率
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: CGRectGetMidX(initialFrame), y: CGRectGetMidY(initialFrame))
            herbView.clipsToBounds = true
        }
        
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(herbView)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            
            herbView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform
            herbView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
            
            }) { (_) -> Void in
                
                if !self.presenting {
                    self.dismissCompletion?()
                }
                transitionContext.completeTransition(true)
        }
        
        // 设置圆角
        let round = CABasicAnimation(keyPath: "cornerRadius")
        round.fromValue = !presenting ? 0.0 : 20.0/xScaleFactor
        round.toValue = presenting ? 0.0 : 20.0/xScaleFactor
        round.duration = duration / 2
        herbView.layer.addAnimation(round, forKey: nil)
        herbView.layer.cornerRadius = presenting ? 0.0 : 20.0/xScaleFactor

    }
}
