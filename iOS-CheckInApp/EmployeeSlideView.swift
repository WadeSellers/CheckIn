//
//  EmployeeSlideView.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class EmployeeSlideView: UIView {
  

  @IBOutlet weak var employeeImageView: UIImageView!
  @IBOutlet weak var employeeName: UILabel!
  
  @IBOutlet weak var employeeIDAndTitle: UILabel!
  
  @IBOutlet weak var dispensaryName: UILabel!
  @IBOutlet weak var signOutButton: UIButton!
  override func awakeFromNib() {
    setupEmployeeView()
  }
  
  func setupEmployeeView() {
    self.backgroundColor = ColorPalette.getFlowhubGrey()
    self.employeeName.text = CurrentUser.sharedInstance.fullName
    self.dispensaryName.text = CurrentUser.sharedInstance.currentDispensary
    
    self.employeeIDAndTitle.text = CurrentUser.sharedInstance.position
    self.employeeImageView.image = CurrentUser.sharedInstance.profPic
    self.employeeImageView.layer.cornerRadius = self.employeeImageView.frame.height/2
    self.employeeImageView.clipsToBounds = true
    setupSignOutButton()
    setupEmployeeViewObservers()
  }
  
  func setupEmployeeViewObservers() {
     NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EmployeeSlideView.didReceiveEmployeeImage(_:)), name:"employeeImageRecieved:", object:nil)
  }
  
  func setupSignOutButton() {
    signOutButton.backgroundColor = ColorPalette.getFlowhubGrey()
    signOutButton.layer.borderColor = ColorPalette.getFlowhubEmployeeButtonBorderColor().CGColor
    signOutButton.layer.borderWidth = 1.0
  }
  
  func didReceiveEmployeeImage(notification:NSNotification) {
    self.employeeImageView.image = CurrentUser.sharedInstance.profPic
    self.employeeImageView.layer.cornerRadius = self.employeeImageView.frame.height/2
    self.employeeImageView.clipsToBounds = true
  }
  
}
