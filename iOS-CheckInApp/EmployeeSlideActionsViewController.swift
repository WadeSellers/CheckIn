//
//  EmployeeSlideActionsViewController.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class EmployeeSlideActionsViewController: UIViewController {

  @IBOutlet var employeeSlideView: EmployeeSlideView!
  @IBOutlet weak var versionLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    setupVersionLabel()
  }

  override func didReceiveMemoryWarning() {
    // Dispose of any resources that can be recreated.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return UIStatusBarAnimation.Slide
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

    // TODO:Fix this later
  @IBAction func signOutButtonPressed(sender: AnyObject) {
    exit(0)
  }

  func setupVersionLabel() {
    let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    versionLabel.textColor = UIColor.whiteColor()
    versionLabel.text = "Version \(version)"
  }
}
