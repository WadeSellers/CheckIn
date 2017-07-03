//
//  AdditionalInfoTwoViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 3/4/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class AdditionalInfoTwoViewController: UIViewController, UITextFieldDelegate, AWSNetworkingDelegate, MeteorNetworkingUploadDelegate {

  @IBOutlet weak var loyaltySwitch: UISwitch!
  @IBOutlet weak var taxExemptSwitch: UISwitch!
  @IBOutlet weak var dispensaryPrimarySwitch: UISwitch!
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var phoneTF: UITextField!
  @IBOutlet weak var uploadPatientButton: UIButton!
  @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
  @IBOutlet weak var phoneLine: UIView!
  @IBOutlet weak var emailLine: UIView!

  let currentMedCustomer : CurrentMedCustomerThroughWorkflow = CurrentMedCustomerThroughWorkflow.sharedInstance
  var currentCustomerUploadedToMeteor:Bool = false
  var currentMedCustomerAcquiredMongoId:String = ""


  let loadingView = SCLAlertView()


  override func viewDidLoad() {
    AWSNetworking.delegate = self
    MeteorNetworking.meteorNetworkingUploadDelegate = self
    setupTextFields()
    super.viewDidLoad()
    observeKeyboard()
    uploadPatientButton.enabled = true
    let loyaltySwitchChanged = #selector(AdditionalInfoTwoViewController.loyaltySwitchChanged)
    loyaltySwitch.addTarget(self, action: loyaltySwitchChanged, forControlEvents: UIControlEvents.ValueChanged)
    let taxExemptSwitchChanged = #selector(AdditionalInfoTwoViewController.taxExemptSwitchChanged)
    taxExemptSwitch.addTarget(self, action: taxExemptSwitchChanged, forControlEvents: UIControlEvents.ValueChanged)
    let primarySwitchChanged = #selector(AdditionalInfoTwoViewController.primarySwitchChanged)
    dispensaryPrimarySwitch.addTarget(self, action: primarySwitchChanged, forControlEvents: UIControlEvents.ValueChanged)
  }

  override func viewWillAppear(animated: Bool) {
    checkUploadButtonActivation()
    checkForPatientDispenaryPrimaryAndSetSwitch()
  }

  // MARK: Keyboard Methods
  func observeKeyboard() {
    let keyboardWillShow = #selector(AdditionalInfoTwoViewController.keyboardWillShow(_:))
    let keyboardWillHide = #selector(AdditionalInfoTwoViewController.keyboardWillHide(_:))
    NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillChangeFrameNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
  }


  func onUserInfoUploadError(notification: NSNotification) {
    let userInfo: Dictionary<String,NSError!> = notification.userInfo as! Dictionary<String,NSError!>
    let errorMessage = userInfo["errorMessage"]
    print(errorMessage)
    let _: SCLAlertViewResponder = SCLAlertView().showError("Error", subTitle: (errorMessage?.localizedDescription)!, closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
  }

  func keyboardWillShow(notification: NSNotification) {
    let info: NSDictionary = notification.userInfo!
    let kbFrame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)
    let animationDuration: NSTimeInterval = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
    let keyboardFrame: CGRect = (kbFrame?.CGRectValue)!

    let height: CGFloat = keyboardFrame.size.height
    keyboardHeight.constant = height
    //print(keyboardHeight.constant)

    UIView.animateWithDuration(animationDuration) { () -> Void in
      self.view.layoutIfNeeded()
    }
  }

  func keyboardWillHide(notification: NSNotification) {
    let info: NSDictionary = notification.userInfo!
    let animationDuration: NSTimeInterval = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! Double
    keyboardHeight.constant = 0

    UIView.animateWithDuration(animationDuration) { () -> Void in
      self.view.layoutIfNeeded()
    }

  }

  // MARK: UISwitch Action Methods
  func loyaltySwitchChanged() {
    checkUploadButtonActivation()

    switch loyaltySwitch.on {
    case true:
      currentMedCustomer.loyaltyMember = true
      checkForPhoneNumber()
      if phoneTF.text == "" {
        phoneTF.becomeFirstResponder()
      }else {
        emailTF.becomeFirstResponder()
      }
    case false:
      currentMedCustomer.loyaltyMember = false
      resetTextFieldsToPlacemarkText()
      if emailTF.isFirstResponder() || phoneTF.isFirstResponder() {
        emailTF.resignFirstResponder()
        phoneTF.resignFirstResponder()
      }
    }
  }

  func taxExemptSwitchChanged() {
    switch taxExemptSwitch.on {
    case true:
      currentMedCustomer.taxExempt = true
    case false:
      currentMedCustomer.taxExempt = false
    }
  }

  func primarySwitchChanged() {
    switch dispensaryPrimarySwitch.on {
    case true:
      currentMedCustomer.isPrimary = true
    case false:
      currentMedCustomer.isPrimary = false
    }
  }

  func checkForPatientDispenaryPrimaryAndSetSwitch() {
    if currentMedCustomer.isPrimary == true{
      dispensaryPrimarySwitch.setOn(true, animated: true)
    } else {
      dispensaryPrimarySwitch.setOn(false, animated: true)
    }
  }

  // MARK: UIButton Methods
  @IBAction func onUploadPatientButtonPressed(sender: UIButton) {
    if checkUploadButtonActivation() == true {
      if currentCustomerUploadedToMeteor == false {
        uploadPatientButton.enabled = false
        addAndCheckInNewMedCustomer()
        loadingView.showCloseButton = false
        loadingView.showWait("Please Wait", subTitle: "Saving Patient Info To Cloud", duration: 0.0,  colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF)
      } else {
        AWSNetworking.sendMedCardInfoToAwsWithPhotoArrayTuple(currentMedCustomer.photoArray!, mongoId: currentMedCustomerAcquiredMongoId, addMongoIdToPhotoName: false)
      }

    }
  }

  // MARK: MeteorNetworkingUploadDelegate methods
  func customerWasSuccessfullyUploaded(mongoId:String) {
    currentMedCustomerAcquiredMongoId = mongoId
    currentCustomerUploadedToMeteor = true
    AWSNetworking.sendMedCardInfoToAwsWithPhotoArrayTuple(currentMedCustomer.photoArray!, mongoId: currentMedCustomerAcquiredMongoId, addMongoIdToPhotoName: true)
  }

  // MARK: When the meteor call fails, this is fired off
  func customerUploadFailed() {
    currentCustomerUploadedToMeteor = false
    loadingView.hideView()
    let customerUploadFailed: SCLAlertView = SCLAlertView()
    customerUploadFailed.showError("Error", subTitle:"We had trouble uploading customer. Please try uploading again", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
    uploadPatientButton.enabled = true
  }

  // MARK: Verifies proper fields are filled out for Upload button to function correctly
  func checkUploadButtonActivation() -> Bool {
    if loyaltyInfoFieldsAreValid() {
      uploadPatientButton.enableButton(true)

      return true
    }else {
      phoneTF.becomeFirstResponder()
      uploadPatientButton.enableButton(false)

      return false
    }
  }
  
  // MARK: AWSNetworking Delegate 
  func medPhotosUploadedSucessfully() {
    uploadPatientButton.enabled = true
    loadingView.hideView()
    let sucessAlert: SCLAlertView = SCLAlertView()
    sucessAlert.addButton("Okay") { 
      self.performSegueWithIdentifier("unwindToLandingScreenVC", sender: self)
    }
    sucessAlert.showCloseButton = false 
    sucessAlert.showSuccess("Sucess", subTitle:"The photos sucessfully were sent to the database", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
  }

  // MARK: If AWS call fails, this is fired off and what's remaining in the array is returned for retry
  func medPhotosErroredOrTimedout(photoArrayTuple: [(name: String, photo: UIImage)]) {
    currentMedCustomer.photoArray = photoArrayTuple
    uploadPatientButton.enabled = true
    loadingView.hideView()
    let medPhotosFailureToUploadAlert: SCLAlertView = SCLAlertView()
    medPhotosFailureToUploadAlert.showError("Error", subTitle:"The medical documents could not be uploaded at this time. Please try again", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
  }

  // MARK: UITextfield Methods
  func setupTextFields() {
    // Placeholder text attributes
    let attributes = [
      NSForegroundColorAttributeName: UIColor(red: 175.0/255.0, green: 175.0/255.0, blue: 175.0/255.0, alpha: 0.2),
      NSFontAttributeName : UIFont(name: "HelveticaNeue-Italic", size: 14)!
    ]

    for view in self.view.subviews {
      if let textField = view as? UITextField {
        textField.clearButtonMode = .WhileEditing
        let IBSetPlaceholderString: String? = textField.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: IBSetPlaceholderString!, attributes: attributes)
      }
    }
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == emailTF {
      phoneTF.becomeFirstResponder()
    }

    return true
  }

  func textFieldDidBeginEditing(textField: UITextField) {
    loyaltySwitch.setOn(true, animated: true)
    checkForPhoneNumber()
    checkUploadButtonActivation()
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: true)
  }

  func textFieldDidEndEditing(textField: UITextField) {
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: false)
  }

  func findLineToHighlightForTextField(textField: UITextField) -> UIView {
    switch textField {
    case phoneTF:
      return phoneLine
    default:
      return emailLine
    }
  }

  func highlightUIViewLine(lineInQuestion: UIView, highlight: Bool) {
    if highlight {
      UIView.animateWithDuration(0.5, animations: {
        lineInQuestion.backgroundColor = UIColor.whiteColor()
      })
    } else {
      UIView.animateWithDuration(0.5, animations: {
        lineInQuestion.backgroundColor = ColorPalette.getPlaceholderTextColor()
      })
    }
  }

  // Found code for manipulation of textfield into phone numbers and also created for licenseTF too
  // Found this at: http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if (textField == phoneTF) {
      // This grabs the current string and adds on the new letter that was just typed
      let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
      // This sets a an array with decimal between each letter of string, leaving out decimals that might already be in string
      let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
      // This stringifies the array and sets a "" between each component
      let decimalString = components.joinWithSeparator("") as NSString
      print("decimal string: \(decimalString)")
      let length = decimalString.length
      print("decimal string length: \(length)")
      let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
      // If the phone number has a 1 like for 1 800, this will adjust the length to incorporate for the added 1 to the prefix
      if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
        let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
        // if after making the adjustments to the length, if the amount of digits is greater than 10, do not allow for the new number to be added. 
        //This is how we keep the amount of digits entered to 10 and make for a consistent phone number. Obviously if it's less than 10 than add the digit.
        return (newLength < 10) ? true : false
      }
      var index = 0 as Int
      let formattedString = NSMutableString()
      // This area of the method is where the physical changes are made based on index length parameters while typing is occurring and increasing the count.
      if hasLeadingOne {
        formattedString.appendString("1 ")
        index += 1
      }
      // This looks to see if you are typing in the 4th number. If so it appends the (###) # styling. it also adds to the index after the 1st block and stops hitting the second block till the space is at the right place due to the length of the string being 1 less than the needed amount.
      if (length - index) > 3 {
        let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
        formattedString.appendFormat("(%@) ", areaCode)
        index += 3
      }

      // Upon tapping the 4th number in, the index is adjusted to include the 4th number and this method is fired off to create the (###) # situation. From this point forward, this method fires off each time
      if (length - index) > 3 {
        let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
        formattedString.appendFormat("%@-", prefix)
        index += 3
      }
      // The dash makes the length long enough to fire off the above methods no problem and the remainder of the strings is added to the end. Once you reach the 10 digit limit up above, false is returned forever and the phone number will never break the 10 digit threshold.
      let remainder = decimalString.substringFromIndex(index)
      formattedString.appendString(remainder)
      textField.text = formattedString as String

      checkUploadButtonActivation()

      return false
    }else {
      checkUploadButtonActivation()

      return true
    }
  }

  func loyaltyInfoFieldsAreValid() -> Bool {
    if loyaltySwitch.on {
      // phone is a required field for adding new med patient
      if phoneTF.text!.isPhoneNumber && phoneNumberIsCorrectLength() {
        currentMedCustomer.phoneNumber = phoneTF.text

        // email is only optional so this will include if it's good but it's not necessary
        if emailTF.text!.isEmail {
          currentMedCustomer.phoneNumber = phoneTF.text
        }
        return true
      }else {
        return false
      }
    }else {
      // if loyalty is turned off, then these fields don't matter so we return true
      return true
    }
  }

  func phoneNumberIsCorrectLength() -> Bool {
    if phoneTF.text?.characters.count == 14 {
      return true
    } else {
      return false
    }
  }

  func checkForPhoneNumber() {
    if let phoneNumber = currentMedCustomer.phoneNumber {
      phoneTF.text = phoneNumber
    }
  }

  func resetTextFieldsToPlacemarkText() {
    phoneTF.text = ""
    emailTF.text = ""
  }

  // MARK: addNewMedAndQueue Customer API Call
  func addAndCheckInNewMedCustomer() {
    var arrayOfImageNames : [String] = []
    for item : (name: String, photo: UIImage) in currentMedCustomer.photoArray! {
      var convertedImageName = item.name
      convertedImageName = convertedImageName.substituteDashesInForSpacesAndMakeAllLowercase()
      arrayOfImageNames.append(convertedImageName)
    }

    let addressOne = currentMedCustomer.addressOne ?? ""
    let addressTwo = currentMedCustomer.addressTwo ?? ""
    let city = currentMedCustomer.city ?? ""
    let zip = currentMedCustomer.zipCode ?? ""
    let phone = currentMedCustomer.phoneNumber!.removeTrailingSpaces() ?? ""
    let email = currentMedCustomer.emailAddress!.removeTrailingSpaces() ?? ""
    let driversLicenseNumber = currentMedCustomer.driversLicenseNumber ?? ""

    MeteorNetworking.addAndCheckInMedCustomerToQueueForFirstTime("med",
      name: currentMedCustomer.name!,
      state: currentMedCustomer.usState!,
      birthDateUTC: currentMedCustomer.birthdateUTC!,
      medId: currentMedCustomer.medId!,
      medExpUTC: currentMedCustomer.medLicenseExpirationDateUTC!,
      addressOne: addressOne,
      addressTwo: addressTwo,
      city: city,
      zip: zip,
      isLoyal: currentMedCustomer.loyaltyMember!,
      isTaxExempt: currentMedCustomer.taxExempt!,
      isPrimary: currentMedCustomer.isPrimary!, 
      phone: phone,
      email: email,
      driversLicenseNumber: driversLicenseNumber,
      uploadingImagesNames: arrayOfImageNames,
      plantCount: "6",
      gramLimit: "56"
    )
  }


}
