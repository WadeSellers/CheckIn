//
//  NewScanPopoverCustomButton.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 3/31/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation
import UIKit

class NewScanPopoverCustomButton : UIButton {

  var buttonIconImageView = UIImageView()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupButton()
    setupIconImageView()
  }

  func setupButton() {
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.whiteColor().CGColor
    self.layer.cornerRadius = 2.0
  }

  func setupIconImageView() {
    buttonIconImageView.frame = CGRect(x: self.frame.size.width * 0.90, y: 8.5, width: 30.0, height: 30.0)
    buttonIconImageView.contentMode = UIViewContentMode.Center
    self.addSubview(buttonIconImageView)
  }
}
