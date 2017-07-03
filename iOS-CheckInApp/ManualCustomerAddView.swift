//
//  ManualCustomerAddView.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 2/26/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

protocol ManualCustomerAddViewDelegate {
  func manualCustomerViewAcceptButtonPressed(customerName:String, customerBirthday:String,customerState:String)
  func manualCustomerViewCancelButtonPressed()
//  func customerNameFieldChanged(customerName:String)
//  func birthdayFieldChanged(birthday:String)
//  func stateFieldChanged(state:String)
}
class ManualCustomerAddView: UIView, UITextFieldDelegate, UIPickerViewDelegate  {

  @IBOutlet weak var topLayerView: UIView!
  @IBOutlet weak var topIconBlueBackground: UIView!
  @IBOutlet weak var customerNameTextField: UITextField!
  @IBOutlet weak var customerBirthdayTextField: UITextField!
  @IBOutlet weak var customerStateTextField: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var topIconImageView: UIImageView!

  @IBOutlet weak var customerNameLine: UIView!
  @IBOutlet weak var birthdayLine: UIView!
  @IBOutlet weak var stateLine: UIView!

//  let customerBirthdayDatePicker:UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 200, width: 300, height: 100))
  @IBOutlet weak var customerBirthdayDatePicker: UIDatePicker!
  var statePicker:UIPickerView?
  
  var delegate:ManualCustomerAddViewDelegate?
  //make delegates between the view and the vc don't put hard business logic in here
  override func awakeFromNib() {
    setupTopIcon()
    self.backgroundColor = UIColor.clearColor()
    setupTextFieldDelegates()
    setTextFieldColors()
    setupTextFieldsPlaceholderStyle()
    setupButtonStyling()
    setupActionsForTextFields()
    setupCustomerDatePicker()
    setNameAsFirstResponder()
    disableKeyboardForBirthdateAndStateTextfields()
    customerBirthdayDatePicker.hidden = true
    statePicker = UIPickerView(frame: CGRect(x: customerBirthdayDatePicker.bounds.origin.x - 40, y: customerBirthdayDatePicker.bounds.origin.y + 190, width: customerBirthdayDatePicker.frame.width, height: customerBirthdayDatePicker.frame.height))
    self.addSubview(statePicker!)
    statePicker?.hidden = true
    statePicker?.delegate = self

    validateForAcceptButtonActivation()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  class func instanceFromNib() -> ManualCustomerAddView {
    return UINib(nibName: "ManualCustomerAddView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ManualCustomerAddView
  }

  func setNameAsFirstResponder() {
    customerNameTextField.becomeFirstResponder()
  }
  
  // MARK: Text Field Methods
  func setTextFieldColors() {
    customerNameTextField.backgroundColor = UIColor.clearColor()
    customerBirthdayTextField.backgroundColor = UIColor.clearColor()
    customerStateTextField.backgroundColor = UIColor.clearColor()
    customerNameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
  }

  func setupTextFieldDelegates () {
    customerNameTextField.delegate = self
    customerBirthdayTextField.delegate = self
    customerStateTextField.delegate = self
  }
  
  //makes the keyboard not popup but still shows blinking cursor
  func disableKeyboardForBirthdateAndStateTextfields() {
    customerBirthdayTextField.inputView = UIView()
    customerStateTextField.inputView = UIView()
  }
  
  func setupCustomerDatePicker() {
    customerBirthdayDatePicker.datePickerMode = UIDatePickerMode.Date
    let currentDate = NSDate()
    //seconds * minutes * hours * days
    let oneYearPastCurrentDate = currentDate.dateByAddingTimeInterval(60*60*24*365)
    customerBirthdayDatePicker.date = currentDate
    customerBirthdayDatePicker.maximumDate = oneYearPastCurrentDate

    customerBirthdayDatePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    let setHighlightsTodaySelector = NSSelectorFromString("setHighlightsToday:")
    customerBirthdayDatePicker.performSelector(setHighlightsTodaySelector, withObject: UIColor.whiteColor())
    customerBirthdayDatePicker.addTarget(self, action: #selector(ManualCustomerAddView.dateHasChanged), forControlEvents: UIControlEvents.EditingChanged)
    self.insertSubview( customerBirthdayDatePicker, aboveSubview:topLayerView )
  }

  func textFieldDidBeginEditing(textField: UITextField) {
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: true)
  }

  func textFieldDidEndEditing(textField: UITextField) {
    highlightUIViewLine(findLineToHighlightForTextField(textField), highlight: false)
  }

  func findLineToHighlightForTextField(textField: UITextField) -> UIView {
    switch textField {
    case customerNameTextField:
      return customerNameLine
    case customerBirthdayTextField:
      return birthdayLine
    default:
      return stateLine
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

  @IBAction func birthdayTextFieldDidBeginEditing(sender: UITextField) {
    customerBirthdayDatePicker.hidden = false
    customerBirthdayDatePicker.enabled = true
  }
  
  @IBAction func birthdayTextFieldEditingDidEnd(sender: UITextField) {
    customerBirthdayDatePicker.hidden = true
    customerBirthdayDatePicker.enabled = false
  }
  
  @IBAction func stateTextFieldDidBeginEditing(sender: UITextField) {
    statePicker?.hidden = false
  }
  
  @IBAction func stateTextFieldDidEndEditing(sender: UITextField) {
    statePicker?.hidden = true
  }
  
  @IBAction func dateHasChanged(datePicker: UIDatePicker) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy" //format style. Browse online to get a format that fits your needs.
    let dateAsString:String = dateFormatter.stringFromDate(datePicker.date)
    customerBirthdayTextField.text = dateAsString
  }

  
  func setupActionsForTextFields () {
//    customerNameTextField.addTarget(self, action:"customerNameTextFieldsDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
//    customerBirthdayTextField.addTarget(self, action:"customerBirthdayTextFieldsDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
//    customerStateTextField.addTarget(self, action:"customerStateTextFieldsDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
  }

  // MARK: Pickerview delegate methods
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
    customerStateTextField.text = stateAbbreviationString
  }
  
  // MARK: TextField Methods
  func setupTextFieldsPlaceholderStyle() {
    // Placeholder text attributes
    let attributes = [
      NSForegroundColorAttributeName: UIColor(red: 175.0/255.0, green: 175.0/255.0, blue: 175.0/255.0, alpha: 0.2),
      NSFontAttributeName : UIFont(name: "HelveticaNeue-Italic", size: 14)!
    ]
    let IBSetNamePlaceholderString: String? = customerNameTextField.placeholder
    let IBSetStatePlaceholderString: String? = customerStateTextField.placeholder
    let IBSetBirthdayPlaceholderString: String? = customerBirthdayTextField.placeholder

    customerNameTextField.attributedPlaceholder = NSAttributedString(string: IBSetNamePlaceholderString!, attributes: attributes)
    customerStateTextField.attributedPlaceholder = NSAttributedString(string: IBSetStatePlaceholderString!, attributes: attributes)
    customerBirthdayTextField.attributedPlaceholder = NSAttributedString(string: IBSetBirthdayPlaceholderString!, attributes: attributes)

    customerBirthdayTextField.clearButtonMode = .WhileEditing
    customerNameTextField.clearButtonMode = .WhileEditing
    customerStateTextField.clearButtonMode = .WhileEditing
  }

  // MARK: Top Icon Setup
  func setupTopIcon() {
    topIconImageView.layer.cornerRadius = CGRectGetWidth(topIconImageView.frame)/2
    topIconBlueBackground.layer.cornerRadius = 35
  }

  // MARK: Button Methods
  func setupButtonStyling() {
    let buttonArray: [UIButton] = [cancelButton, acceptButton]
    for button in buttonArray {
      button.layer.cornerRadius = 2
      button.layer.borderWidth = 1
      button.layer.borderColor = UIColor.whiteColor().CGColor
    }
  }

  func validateForAcceptButtonActivation() {
    let name = customerNameTextField.text!
    let birthday = customerBirthdayTextField.text!
    let state = customerStateTextField.text!

    if name.isEmpty && birthday.isEmpty && state.isEmpty {
      acceptButton.enableButton(true)
      acceptButton.alpha = 1.0
    }else {
      acceptButton.enableButton(false)
      self.acceptButton.alpha = 0.2
    }
  }

  // MARK: Button Actions
  @IBAction func acceptButtonPressed(sender: UIButton) {
    let customerNameFromTextField:String = customerNameTextField.text!.removeTrailingSpaces()
    let customerBirthdateFromTextField:String = customerBirthdayTextField.text!
    let customerStateFromTextField:String = customerStateTextField.text!
    
    delegate?.manualCustomerViewAcceptButtonPressed(customerNameFromTextField,customerBirthday:customerBirthdateFromTextField,customerState:customerStateFromTextField)
  }
  
  @IBAction func cancelButtonPressed(sender: UIButton) {
    delegate?.manualCustomerViewCancelButtonPressed()
  }


}
