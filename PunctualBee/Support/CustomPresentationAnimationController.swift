//
//  Created by Pete Callaway on 26/06/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import UIKit


class CustomPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting :Bool
    let duration :NSTimeInterval = 0.5

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting

        super.init()
    }


    // ---- UIViewControllerAnimatedTransitioning methods

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        }
        else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }


    // ---- Helper methods
    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView(),
            let presentingController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        else {
            return
        }

        // containerView就是UIWindow上的UITransitionView，重新设置frame，才能将plusButton不被它覆盖，进而响应点击事件
        let x = containerView.frame.origin.x
        let y = containerView.frame.origin.y
        let width = containerView.frame.size.width
        let height = containerView.frame.size.height - 49
         containerView.frame = CGRectMake(x, y, width, height)
        // 推出悬浮窗后，底层视图除了plusButton用于dismiss之外，其他tabBarItem均不可点击
        let tab = presentingController as! CYLTabBarController
        for (idx, item) in tab.tabBar.items!.enumerate() {
          let it = item as UITabBarItem
          it.enabled = false
        }

        // Position the presented view off the top of the container view
        presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
        presentedControllerView.center.y -= containerView.bounds.size.height

        containerView.addSubview(presentedControllerView)

        // Animate the presented view to it's final position
        UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
            presentedControllerView.center.y += containerView.bounds.size.height
        }, completion: {(completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }

    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let containerView = transitionContext.containerView(),
            let presentingController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        else {
            return
        }

      // 推出悬浮窗后，底层视图除了plusButton用于dismiss之外，其他tabBarItem均不可点击
      let tab = presentingController as! CYLTabBarController
      for (idx, item) in tab.tabBar.items!.enumerate() {
        let it = item as UITabBarItem
        it.enabled = true
      }
      
      
        // Animate the presented view off the bottom of the view
        UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
            presentedControllerView.center.y += containerView.bounds.size.height
        }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
}
