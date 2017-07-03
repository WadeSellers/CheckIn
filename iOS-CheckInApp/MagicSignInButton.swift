//
//  MagicSignInButton.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 1/22/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

class MagicSignInButton: UIButton {
  var animationTimer:NSTimer?
  var delegate:MagicSignInButtonDelegate?
  let magicActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func magicSignButtonReset(frame: CGRect) {
    self.enabled = true
    self.frame = frame
    self.layer.cornerRadius = 0
    self.setTitle("Sign In", forState: UIControlState.Normal)
    self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.magicActivityIndicator.stopAnimating()
    self.magicActivityIndicator.hidesWhenStopped = true
  }
  
  func magicSignInButtonPressed() {
    self.enabled = false
    self.setTitle("", forState: UIControlState.Normal)
//    self.titleLabel?.text = " "
    UIView.animateWithDuration(0.4, animations:{
      // TODO:Make this a sensible number and not so random please
      self.frame = CGRectMake(135, 300, 50, 50)
      self.layer.cornerRadius = 25
      }, completion: {
        (value: Bool) in
        self.setTitle("", forState: UIControlState.Normal)
        //Make this half of the magic sign in button height and width
        self.magicActivityIndicator.center = CGPointMake(25, 25)
        
        self.addSubview(self.magicActivityIndicator)
        self.magicActivityIndicator.startAnimating()
        self.delegate?.magicSignInButtonWasPressed()
    })
  }
  
  func startAnimatingNetworkingConnection() {
    self.setTitle("Waiting for connection", forState: UIControlState.Normal)
    self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector:#selector(MagicSignInButton.updateLoadingLabel), userInfo: nil, repeats: true)
  }
  
  func updateLoadingLabel () {
    if(self.titleLabel?.text != "Waiting for connection...") {
      var newUpdatedStringWithElipses:String = self.titleLabel!.text!
      newUpdatedStringWithElipses.appendContentsOf(".")
      self.setTitle(newUpdatedStringWithElipses, forState: UIControlState.Normal)
    } else {
      self.setTitle("Waiting for connection", forState: UIControlState.Normal)
    }
  }
  
  func endLoadingAnimation () {
    self.animationTimer?.invalidate()
    self.animationTimer = nil
  }
  
  func magicSignInButtonExpandAndSegue() {
    print("magic sign in button being pressed")
    self.magicActivityIndicator.stopAnimating()
    UIView.animateWithDuration(0.4, animations:{
      let scale:CGFloat = 15
      self.transform = CGAffineTransformMakeScale(scale, scale)
      self.transform = CGAffineTransformRotate((self.transform), CGFloat(M_PI / 2))
      self.backgroundColor = ColorPalette.getFlowhubDarkGrey()
      }, completion: {
        (value: Bool) in
        self.delegate?.magicSignInButtonFullyExpanded()
    })
  }

}