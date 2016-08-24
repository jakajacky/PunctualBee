//
//  Created by Pete Callaway on 26/06/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {

  var st:STTableViewController!
  
  var detailView:UILabel! {
    didSet {
      
    }
  }
  var dian:NSString! {
    didSet {

    }
  }
  
    lazy var dimmingView :UIView = {
      
        let width  = self.containerView!.bounds.width
        let height = self.containerView!.bounds.height
        let view = UIView(frame: CGRectMake(0, 0, width, height - 66))
        view.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.9)
        view.alpha = 1
        return view
    }()

    override func presentationTransitionWillBegin() {

		guard
			let containerView = containerView,
			let presentedView = presentedView()
		else {
			return
		}

        // Add the dimming view and the presented view to the heirarchy
      let width  = self.containerView!.bounds.width
      let height = self.containerView!.bounds.height
      
        dimmingView.frame = CGRectMake(0, 0, width, height - 66 - 45)
      
      // 增加蒙版，但是不要添加到containerView上，会盖住一部分plusButton，加载底层VC的mapView上
      let tab = self.presentingViewController as! CYLTabBarController
      let vc = tab.childViewControllers[0].childViewControllers[0] as! ViewController

//        containerView.addSubview(dimmingView)
        vc._mapView!.addSubview(dimmingView)
        containerView.addSubview(presentedView)

        // Fade in the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1.0
            }, completion:nil)
        }
      
        // 在蒙板上增加 操作信息
      let y = (height - 105) / 2 - 50
      detailView = UILabel(frame: CGRectMake(20, y, width - 40, 30))
      detailView.text = "点击选择目的地"
      detailView.textColor = UIColor.lightGrayColor()
      detailView.textAlignment = NSTextAlignment.Center
      dimmingView.addSubview(detailView)
      
    }

    override func presentationTransitionDidEnd(completed: Bool)  {
        // If the presentation didn't complete, remove the dimming view
      
     
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin()  {
        // Fade out the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha  = 0.0
            }, completion:nil)
        }
    }

    override func dismissalTransitionDidEnd(completed: Bool) {
        // If the dismissal completed, remove the dimming view
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {

		guard
			let containerView = containerView
		else {
			return CGRect()
		}

        // We don't want the presented view to fill the whole container view, so inset it's frame
        var frame = containerView.bounds;
        frame = CGRectInset(frame, 20.0, 115.0)

        return frame
    }


    // ---- UIContentContainer protocol methods

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator transitionCoordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: transitionCoordinator)

		guard
			let containerView = containerView
		else {
			return
		}

        transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
          let width  = self.containerView!.bounds.width
          let height = self.containerView!.bounds.height
          
            self.dimmingView.frame = CGRectMake(0, 0, width, height - 66 - 45)
        }, completion:nil)
    }
  
  // tip 动画
  func oneAnimation() {
    UIView.animateWithDuration(1, delay: 0.7, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
      self.detailView.transform = CGAffineTransformScale(self.detailView.transform, 1.2, 1.2)

    }) { (stop) in
      UIView.animateWithDuration(1.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.detailView.transform = CGAffineTransformScale(self.detailView.transform, 5.0 / 6, 5.0 / 6)
        
      }) { (stop) in
        
      }
    }
    
  }
  
}
