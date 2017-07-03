//
//  AddionalInfoOneViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 2/26/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class AddionalInfoOneViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {

  @IBOutlet weak var addressTF: UITextField!
  @IBOutlet weak var suiteTF: UITextField!
  @IBOutlet weak var cityTF: UITextField!
  @IBOutlet weak var stateTF: UITextField!
  @IBOutlet weak var zipTF: UITextField!
  @IBOutlet weak var phoneTF: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var statePickerView: UIPickerView!

  @IBOutlet weak var addressLine: UIView!
  @IBOutlet weak var suiteLine: UIView!
  @IBOutlet weak var cityLine: UIView!
  @IBOutlet weak var stateLine: UIView!
  @IBOutlet weak var zipLine: UIView!
  @IBOutlet weak var phoneLine: UIView!

  var currentMedCustomer : CurrentMedCustomerThroughWorkflow = CurrentMedCustomerThroughWorkflow.sharedInstance

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTextFields()
    setupPickerView()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    autopopulateTextField()
    setupFirstRespondingTextField()
  }

  // MARK: NextButton Methods
  @IBAction func onNextButtonTapped(sender: UIButton) {

    addInfoToCurrentMedCustomer()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "segueFromInfoOneToInfoTwo" {
      self.navigationController?.navigationBar.topItem?.title = ""
    }
  }

  // MARK: PickerView Methods
  func setupPickerView() {
    statePickerView.hidden = true
    statePickerView.delegate = self
  }

  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return StateConstants.statesArray.count
  }

  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    let titleData: String = StateConstants.statesArray[row]
    let shownTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])

    return shownTitle
  }

  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let fullNameState:String = StateConstants.statesArray[row]
    let stateAbbreviationArray:Array = StateConstants.statesDictionary.allKeysForObject(fullNameState)
    let stateAbbreviationString:String = stateAbbreviationArray.first as! String
    stateTF.text = stateAbbreviationString
  }

  // MARK: TextField Methods
  func autopopulateTextField() {
    if let addressOne = currentMedCustomer.addressOne {
      addressTF.text = addressOne
    }
    if let suite = currentMedCustomer.addressTwo {
      suiteTF.text = suite
    }
    if let city = currentMedCustomer.city {
      cityTF.text = city
    }
    if let state = currentMedCustomer.usState {
      stateTF.text = state
    }
    if let zip = currentMedCustomer.zipCode {
      zipTF.text = zip
    }
    if let phone = currentMedCustomer.phoneNumber {
      phoneTF.text = phone
    }
  }

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

    //This line resigns the keyboard so that we can expose the statePickerView for input
    stateTF.inputView = UIView()
  }

  func setupFirstRespondingTextField() {
    if addressTF.text == nil {
      addressTF.becomeFirstResponder()
    }else {
      phoneTF.becomeFirstResponder()
    }
  }

  func textFieldDidBeginEditing(textField: UITextField) {
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: true)
  }

  func textFieldDidEndEditing(textField: UITextField) {
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: false)
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {

    if textField == addressTF {
      suiteTF.becomeFirstResponder()
    }else if textField == suiteTF {
      cityTF.becomeFirstResponder()
    }else if textField == cityTF {
      stateTF.becomeFirstResponder()
    }else if textField == stateTF {
      zipTF.becomeFirstResponder()
    }
    //We cannot go further than this due to using NumPad keyboard for the rest of the textfields
    return true
  }

  // Found code for manipulation of textfield into phone numbers and also created for licenseTF too
  // Found this at: http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number
  // For extended explanations to this, see the same delegate method in AdditionalInfoTwoViewController
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if (textField == phoneTF) {
      let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
      let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)

      let decimalString = components.joinWithSeparator("") as NSString
      let length = decimalString.length
      let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)

      if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
        let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

        return (newLength > 10) ? false : true
      }
      var index = 0 as Int
      let formattedString = NSMutableString()

      if hasLeadingOne {
        formattedString.appendString("1 ")
        index += 1
      }
      if (length - index) > 3 {
        let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
        formattedString.appendFormat("(%@) ", areaCode)
        index += 3
      }
      if (length - index) > 3 {
        let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
        formattedString.appendFormat("%@-", prefix)
        index += 3
      }
      let remainder = decimalString.substringFromIndex(index)
      formattedString.appendString(remainder)
      textField.text = formattedString as String
      return false
    }else if (textField == zipTF) {
      let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
      let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
      let decimalString = components.joinWithSeparator("") as NSString
      let length = decimalString.length
      if length < 6 {
        return true
      }
      return false
    }else {
      return true
    }
  }

  @IBAction func zipcodeTFDidChange(sender: UITextField) {
    if zipTF.text?.characters.count == 5 {
      phoneTF.becomeFirstResponder()
    }
  }

  @IBAction func stateTFDidBeginEditing(sender: UITextField) {
    statePickerView.hidden = false
  }

  @IBAction func stateTFDidEndEditing(sender: UITextField) {
    statePickerView.hidden = true
  }

  // MARK: Adding all info to MedCustomer
  func addInfoToCurrentMedCustomer() {
    currentMedCustomer.addressOne = addressTF.text?.removeTrailingSpaces()
    currentMedCustomer.addressTwo = suiteTF.text?.removeTrailingSpaces()
    currentMedCustomer.city = cityTF.text?.removeTrailingSpaces()
    currentMedCustomer.usState = stateTF.text?.removeTrailingSpaces()
    currentMedCustomer.zipCode = zipTF.text?.removeTrailingSpaces()
    currentMedCustomer.phoneNumber = phoneTF.text?.removeTrailingSpaces()
  }

  func findLineToHighlightForTextField(textField: UITextField) -> UIView {
    switch textField {
    case addressTF:
      return addressLine
    case suiteTF:
      return suiteLine
    case cityTF:
      return cityLine
    case stateTF:
      return stateLine
    case zipTF:
      return zipLine
    default:
      return phoneLine

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

}
