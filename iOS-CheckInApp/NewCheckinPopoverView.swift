//
//  NewCheckinPopoverView.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/8/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class NewCheckinPopoverView: UIView {

  @IBOutlet var backgroundView: UIView!
  @IBOutlet var customerTypeFrameView: UIView!
  @IBOutlet var customerTypeImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var yearsOldLabel: UILabel!
  @IBOutlet var dateOfBirthLabel: UILabel!
  @IBOutlet var additionalInfoLabel: UILabel!
  @IBOutlet var maxSellableWeighLabel: UILabel!

  var view: UIView!

  var nibName: String = "NewCheckinPopoverView"

  //init methods

//  override init(frame: CGRect) {
//    //properties set here
//
//    super.init(frame: frame)
//    //Set anthing that uses the view or visible bounds
//    setup()
//  }

  // Mark: Initialization

//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//  }

//  func setup() {
//    view = loadViewFromNib()
//
//    view.frame = bounds
//    view.autoresizingMask = UIViewAutoresizing.FlexibleWidth; UIViewAutoresizing.FlexibleHeight
//
//    addSubview(view)
//  }
//
//  func loadViewFromNib() -> UIView {
//    let bundle = NSBundle(forClass: self.dynamicType)
//    let nib = UINib(nibName: nibName, bundle: bundle)
//    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
//
//    return view
//  }

}
