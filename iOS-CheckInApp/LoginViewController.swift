//
//  LoginViewController.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/7/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveDDP
import NSLogger

class LoginViewController: UIViewController, UITextFieldDelegate, MagicSignInButtonDelegate {
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var forgotYourPasswordButton: UIButton!

  var magicSignInButton: MagicSignInButton?
  let screenSize:CGRect = UIScreen.mainScreen().bounds

  override func viewWillAppear(animated: Bool) {
    print("The Bucket is: \(AWSNetworking.amazonMedCustomerBucket)")

    let observingOption = NSKeyValueObservingOptions.New
     MeteorNetworking.meteor.addObserver(self, forKeyPath:"websocketReady", options: observingOption, context:nil)
     MeteorNetworking.meteor.addObserver(self, forKeyPath:"websocketDisconnected", options: observingOption, context:nil)
    if (MeteorNetworking.meteor.websocketReady) {
      self.magicSignInButton!.setTitle("Sign In", forState: UIControlState.Normal)
      self.magicSignInButton!.enabled = true;
      self.magicSignInButton!.endLoadingAnimation()
    } else {
      setupMagicLoginButtonWithDefault()
    }

  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if (keyPath == "websocketReady" &&  MeteorNetworking.meteor.websocketReady) {
        self.magicSignInButton!.setTitle("Sign In", forState: UIControlState.Normal)
        self.magicSignInButton!.enabled = true;
        self.magicSignInButton!.endLoadingAnimation()
    } else {
      setupMagicLoginButtonWithDefault()
    }
  }
  
  // MARK: View Did Load
  override func viewDidLoad() {
    super.viewDidLoad()
    //setup the data formatters every time you login because they are actually a very intensive operation
    DateHelper.setupDateFormatters()
    setupLoginScreen()
    self.magicSignInButton?.delegate = self
    let customersRecieved = #selector(LoginViewController.customersRecieved(_:))
    NSNotificationCenter.defaultCenter().addObserver(self, selector: customersRecieved, name:"customersRecieved:", object:nil)
  }
  
  // MARK: Setup UI Elements
  func setupLoginScreen() {
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BG_5_Check-in-Login")!)
    self.forgotYourPasswordButton.tintColor = UIColor.whiteColor()
    self.initialMagicLoginButtonSetup()
    self.setupLoginTextFields()
    self.magicSignInButton!.startAnimatingNetworkingConnection()
  }
  
  func initialMagicLoginButtonSetup() {
     //Make this a sensible number and not so random please
    magicSignInButton = MagicSignInButton(frame: CGRectMake(0, 300, screenSize.width, 52))
    setupMagicLoginButtonWithDefault()
    magicSignInButton?.backgroundColor = ColorPalette.getFlowhubBlue()
    self.view.addSubview(magicSignInButton!)
  }
  
  // MARK: Magic Login Button
  func setupMagicLoginButtonWithDefault() {
    magicSignInButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    let magicSignInButtonPressed = #selector(magicSignInButton?.magicSignInButtonPressed)
    magicSignInButton!.addTarget(magicSignInButton!, action: magicSignInButtonPressed, forControlEvents: UIControlEvents.TouchUpInside)
    self.magicSignInButton!.alpha = AlphaValues.Opacity.SemiTransparent.rawValue
    self.magicSignInButton!.enabled = false
  }
  
  func setupLoginTextFields() {
    let placeholderAttributes = [
      NSForegroundColorAttributeName : UIColor.init(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0),
      NSFontAttributeName: UIFont(name: "HelveticaNeue-thinItalic", size: 14)!
    ]
    usernameTextField.backgroundColor = UIColor.clearColor()
    usernameTextField.borderStyle = UITextBorderStyle.None
    usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
    usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: placeholderAttributes)
    passwordTextField.backgroundColor = UIColor.clearColor()
    passwordTextField.borderStyle = UITextBorderStyle.None
    passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark
    passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: placeholderAttributes)


    // Set up dummy login here for dev purposes
    usernameTextField.text = "M"
    //usernameTextField.text = "M56565"
    //passwordTextField.text = "Password1"

    let textFieldsDidChange = #selector(LoginViewController.textFieldsDidChange(_:))
    usernameTextField.addTarget(self, action: textFieldsDidChange, forControlEvents: UIControlEvents.EditingChanged)
    passwordTextField.addTarget(self, action: textFieldsDidChange, forControlEvents: UIControlEvents.EditingChanged)
    addWhiteUsernameFieldBorder()
    usernameTextField.becomeFirstResponder()
  }
  
  func addWhiteUsernameFieldBorder() {
    let bottomBorder = CALayer()
    bottomBorder.frame = CGRectMake(0.0, usernameTextField.frame.size.height - 1, usernameTextField.frame.size.width, 1.0);
    bottomBorder.backgroundColor = UIColor.whiteColor().CGColor
    usernameTextField.layer.addSublayer(bottomBorder)
  }
  
  // MARK: Login Methods
  func loginWithUserNameAndPassword(username: String, password: String) {
     MeteorNetworking.meteor.logonWithUsername(username, password: password) {(response, error) -> Void in
      if((error) != nil) {
        //make an error alert here
        print("the error is ", error)
        //0xFFFFFF is the hex for white 
        let _: SCLAlertViewResponder = SCLAlertView().showError("Error", subTitle: "The Username or Password is incorrect. Please try again", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
        self.magicSignInButton!.magicSignButtonReset(CGRectMake(0, 300, self.screenSize.width, 52))
      } else {
          CurrentUser.sharedInstance.username = self.usernameTextField.text!
          MeteorNetworking.setupCurrentUserAndCustomers()
      }
    }
  }
  
  // MARK: Text Field Methods
  func textFieldsDidChange(textField:UITextField) {
    if(usernameTextField.text?.characters.count >= 3 && passwordTextField.text?.characters.count >= 3) {
       self.magicSignInButton!.alpha = AlphaValues.Opacity.Opaque.rawValue
    } else {
       self.magicSignInButton!.alpha = AlphaValues.Opacity.SemiTransparent.rawValue
    }
  }
  
  // MARK: Magic Button Delegate Methods
  func magicSignInButtonWasPressed() {
    self.view.endEditing(true)
    self.loginWithUserNameAndPassword(self.usernameTextField.text!, password: self.passwordTextField.text!)
  }
  
  func magicSignInButtonFullyExpanded() {
    self.performSegueWithIdentifier("segueToLanding", sender: nil)
  }
    
  func customersRecieved(notification:NSNotification) {
//      print("customers sucessfully recieved sucessfully logged in")
      NSNotificationCenter.defaultCenter().removeObserver(self, name:"customersRecieved:" , object: nil)
      self.magicSignInButton!.magicSignInButtonExpandAndSegue()
  }
    
  // MARK: Unwind To Login Screen Seque
  // TODO: Forgotten Password Implementation
  // Doing cool animations for button
  @IBAction func forgotYourPasswordButtonPressed(sender: AnyObject) {
    usernameTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    let _: SCLAlertViewResponder = SCLAlertView().showError("Yikes!", subTitle: "You can reset your password from the Flowhub POS WebApp", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
  }
}
