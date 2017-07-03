//
//  BlurWithSpinnerView.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 4/6/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

// BlurView is setup to be init with an Alpha of 0.0 and the animateBlurViewIntoView method will fade it in

class BlurWithSpinnerView: UIView {

  override func awakeFromNib() {

  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupBlurViewBackground()
    setupSpinner()
    setupInfoLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }



  func setupBlurViewBackground() {
    let blurEffect = UIBlurEffect(style: .Dark)
    let blurBackground = UIVisualEffectView(effect: blurEffect)
    //blurBackground.alpha = 0.8
    blurBackground.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)

    self.addSubview(blurBackground)
  }

  func setupSpinner() {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    spinner.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
    spinner.center = CGPoint(x: self.center.x, y: self.center.y - 40)

    self.addSubview(spinner)

    spinner.startAnimating()
  }

  func setupInfoLabel() {
    let infoLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 30))
    infoLabel.center = CGPoint(x: self.center.x, y: self.center.y)
    infoLabel.textAlignment = .Center

    let labelAttributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17.0)!,
    ]

    let attributedString = NSMutableAttributedString(string: "Firing up the camera", attributes: labelAttributes)
    infoLabel.attributedText = attributedString

    self.addSubview(infoLabel)
  }


}
