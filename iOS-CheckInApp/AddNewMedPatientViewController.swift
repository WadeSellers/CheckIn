//
//  AddNewMedPatientViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/28/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class AddNewMedPatientViewController: UIViewController, UITextFieldDelegate, CaptuvoEventsProtocol, UINavigationControllerDelegate {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var mmrNumberTextField: UITextField!
  @IBOutlet weak var mmrExpirationDatePicker: UIDatePicker!
  @IBOutlet weak var takePhotosButton: UIButton!
  var passedRecCustomer : Customer?
  var selectedDate : String?
  var mmrNumberLength: Int?

  var captureDevice : AVCaptureDevice?
  let captureSession = AVCaptureSession()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupDatePicker()

  }

  override func viewWillAppear(animated: Bool) {
    setupNavControllerBar()
    validateCameraButtonAndAnimateAccordingly()

    Captuvo.sharedCaptuvoDevice().addCaptuvoDelegate(self)
    Captuvo.sharedCaptuvoDevice().startDecoderHardware()
  }

  // MARK: NavController Setup
  func setupNavControllerBar() {
    self.navigationController?.navigationBarHidden = false
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.topItem?.title = "New Med Patient"
  }

  // MARK: TextField methods

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    mmrNumberLength = (textField.text!.characters.count) + (string.characters.count) - range.length
    validateCameraButtonAndAnimateAccordingly()
    return true
  }

  func MMRNumberIsValid() -> Bool {
    if let mmrNumberLength = mmrNumberLength {
      if mmrNumberLength > 6 && mmrNumberLength < 9 {
        return true
      }else {
        return false
      }
    }
    return false
  }

  func validateCameraButtonAndAnimateAccordingly() {
    if MMRNumberIsValid() {
      takePhotosButton.enabled = true
      if (takePhotosButton.alpha != 1.0) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
          self.takePhotosButton.alpha = 1.0
        })
      }
    }else {
      takePhotosButton.enabled = false
      if (takePhotosButton.alpha != 0.2) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
          self.takePhotosButton.alpha = 0.2
        })
      }
    }
  }

  // MARK: Captuvo Delegate Methods
  // TODO: Break into helpers 
  func decoderDataReceived(data: String!) {
    if data.lowercaseString.rangeOfString("mmr") != nil {
      let lowercaseStringToRemove : String = "mmr"
      let uppercaseStringToRemove : String = "MMR"
      var newDataString : String = data.stringByReplacingOccurrencesOfString(lowercaseStringToRemove, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
      newDataString = data.stringByReplacingOccurrencesOfString(uppercaseStringToRemove, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
      mmrNumberTextField.text = newDataString
      mmrNumberLength = mmrNumberTextField.text?.characters.count
    } else {
      mmrNumberTextField.text = data
      mmrNumberLength = mmrNumberTextField.text?.characters.count
    }
    validateCameraButtonAndAnimateAccordingly()
  }

  // MARK: Date Picker Setup and Action
  func setupDatePicker() {
    mmrExpirationDatePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    let setHighlightsTodaySelector = NSSelectorFromString("setHighlightsToday:")
    mmrExpirationDatePicker.performSelector(setHighlightsTodaySelector, withObject: UIColor.whiteColor())
    mmrExpirationDatePicker.subviews[0].subviews[1].backgroundColor = UIColor.whiteColor()
    mmrExpirationDatePicker.subviews[0].subviews[2].backgroundColor = UIColor.whiteColor()
    mmrNumberTextField.delegate = self
    mmrNumberTextField.becomeFirstResponder()
    datePickerAction(mmrExpirationDatePicker)

    // setting up the minimum date allowed to be entered in the DatePicker
    let today = NSDate()
    let oneDayFromNow = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: today, options: NSCalendarOptions(rawValue: 0))
    mmrExpirationDatePicker.minimumDate = oneDayFromNow
    // setting the default date 1 year from today to allow the moving of months first without a reset of the date
    let currentDate = NSDate()
    //seconds * minutes * hours * days
    mmrExpirationDatePicker.date = currentDate
  }

  @IBAction func datePickerAction(sender: UIDatePicker) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    //must do this otherwise it 
    let lastHourOfDayInSelectedDate = mmrExpirationDatePicker.date.dateByAddingTimeInterval((82800 ))
    let stringDate = dateFormatter.stringFromDate(lastHourOfDayInSelectedDate)
   
    self.selectedDate = stringDate
  }

  @IBAction func onTempButtonPressed(sender: UIButton) {
    convertRecToMedCustomerAsTemp(true)
  }
  // MARK: Camera Button Action
  // This is where we convert from a Rec Customer to a Med Customer prior to passing through the segue
  @IBAction func onCameraButtonPressed(sender: UIButton) {
    convertRecToMedCustomerAsTemp(false)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "segueFromAddNewMedToPhotoGallery" {
      self.navigationController?.navigationBar.topItem?.title = ""
    }
  }

  // MARK: Rec to Med Customer conversion method
  func convertRecToMedCustomerAsTemp(isTemp: Bool) {
    let currentMedCustomer = CurrentMedCustomerThroughWorkflow.sharedInstance
    let recCustomer = self.passedRecCustomer!

    // Info pulled in from passedRecCustomer
    currentMedCustomer.name = recCustomer.name
    currentMedCustomer.usState = recCustomer.usState
    currentMedCustomer.driversLicenseNumber = recCustomer.licenseExpiration
    currentMedCustomer.addressOne = recCustomer.addressOne
    currentMedCustomer.addressTwo = recCustomer.addressTwo
    currentMedCustomer.city = recCustomer.city
    currentMedCustomer.zipCode = recCustomer.zipCode
    currentMedCustomer.driversLicenseNumber = recCustomer.driversLicenseNumber
    currentMedCustomer.driversLicenseExpiration = recCustomer.licenseExpiration
    currentMedCustomer.driversLicenseExpirationUTC = DateHelper.convertDateFormatFromMMddyyyyStringToUTCString(currentMedCustomer.driversLicenseExpiration!)
    currentMedCustomer.birthdate = recCustomer.birthDate
    currentMedCustomer.birthdateUTC = DateHelper.convertDateFormatFromMMddyyyyStringToUTCString(currentMedCustomer.birthdate!)

    if isTemp {
      currentMedCustomer.medId = ""
      currentMedCustomer.medLicenseExpirationDate = ""
      currentMedCustomer.medLicenseExpirationDateUTC = ""
    } else {
      // New information we gain from this View Controller
      currentMedCustomer.medId = self.mmrNumberTextField.text!
      currentMedCustomer.medLicenseExpirationDate = self.selectedDate!
      currentMedCustomer.medLicenseExpirationDateUTC = DateHelper.convertDateFormatFromMMddyyyyStringToUTCString(currentMedCustomer.medLicenseExpirationDate!)
    }
  }

}
