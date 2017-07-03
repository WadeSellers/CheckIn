//
//  UIViewAnimationsExtension.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/26/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIView {

  func fadeIn() {
    UIView.animateWithDuration(0.5,
      delay: 0.2,
      options: .CurveEaseIn,
      animations: { () -> Void in
      self.alpha = 1.0
      }, completion: nil)
  }

  func fadeOut() {
    UIView.animateWithDuration(0.5,
      delay: 0.2,
      options: .CurveEaseIn,
      animations: { () -> Void in
        self.alpha = 0.0
      }) { (finished: Bool) -> Void in
        self.removeFromSuperview()
        print("view removed")
    }
  }

  func fadeInWithoutDelay() {
    UIView.animateWithDuration(0.5) {
      self.alpha = 1.0
    }
  }

  














}