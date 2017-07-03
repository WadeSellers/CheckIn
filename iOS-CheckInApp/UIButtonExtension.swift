//
//  UIButtonExtension.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 3/11/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

extension UIButton {

  func enableButton(enable: Bool) {
    if enable {
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.enabled = true
        self.alpha = 1.0
      })
    }else {
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.enabled = false
        self.alpha = 0.2
      })
    }
  }
}