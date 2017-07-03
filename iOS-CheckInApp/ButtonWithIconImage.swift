//
//  ButtonWithIconImage.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/8/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class ButtonWithIconImage: UIButton {

  var iconImageView: UIImageView!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    //iconImageView.frame = CGRectMake(0, 0, 20, 20)
    iconImageView.image = UIImage(named: "icon-over-customertype-rec")

    self.addSubview(iconImageView)
    


  }

}
