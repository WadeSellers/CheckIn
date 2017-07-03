//
//  NewScanPopoverView.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/13/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit
import QuartzCore

protocol NewScanPopoverViewDelegate {
  func topButtonPressed(controller: NewScanPopoverView, topButton: NewScanPopoverCustomButton)
  func middleButtonPressed(controller: NewScanPopoverView, middleButton: NewScanPopoverCustomButton)
  func bottomButtonPressed(controller: NewScanPopoverView, bottomButton: NewScanPopoverCustomButton)

}

@IBDesignable class NewScanPopoverView: UIView {

  var delegate: NewScanPopoverViewDelegate?
  @IBOutlet weak var customerTypeIconImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var topButton: NewScanPopoverCustomButton!
  @IBOutlet weak var middleButton: NewScanPopoverCustomButton!
  @IBOutlet weak var bottomButton: NewScanPopoverCustomButton!
  @IBOutlet weak var backgroundRectangle: UIView!
  @IBOutlet weak var customerTypeIconBackerCircle: UIView!
  @IBOutlet weak var yearsOldLabel: UILabel!
  @IBOutlet weak var birthDateLabel: UILabel!
  @IBOutlet weak var additionalInfoLabelOne: UILabel!
  @IBOutlet weak var additionalInfoLabelTwo: UILabel!
  @IBOutlet weak var yearsOldVerificationImageView: UIImageView!
  @IBOutlet weak var additionalInfoLabelOneImageView: UIImageView!
  @IBOutlet weak var licenseExpiredRedBackroundView: UIView!
  @IBOutlet weak var underAgeRedBackgroundView: UIView!
  
  var customerState:CustomerState?
  var view: UIView!
  var scannedCustomer: Customer!

  //Dictionary used to turn state abbreviation into full state name
  let statesDictionary : NSDictionary = ["AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas", "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware", "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland", "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi", "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada", "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York", "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VT": "Vermont", "VA": "Virginia", "WA": "Washington", "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"]

  // MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    view = loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = UIViewAutoresizing.FlexibleWidth ; UIViewAutoresizing.FlexibleHeight
    self.customerTypeIconBackerCircle.layer.cornerRadius = 42.5
    self.backgroundRectangle.layer.cornerRadius = 5.0

    licenseExpiredRedBackroundView.backgroundColor = UIColor.clearColor()
    underAgeRedBackgroundView.backgroundColor = UIColor.clearColor()

    addSubview(view)
  }

  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: "NewScanPopoverView", bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView

    return view
  }

  func setYearsOldText(years: String) -> NSMutableAttributedString {
    let ageAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!]
    let ageAttributedString = NSAttributedString(string: years, attributes: ageAttributes)
    let yearsOldAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-thin", size: 17)!]
    let yearsOldAttributedString = NSAttributedString(string: " years old", attributes: yearsOldAttributes)

    let ageYearsOldString = NSMutableAttributedString(attributedString: ageAttributedString)
    ageYearsOldString.appendAttributedString(yearsOldAttributedString)

    return ageYearsOldString
  }

  // MARK: Configure the view with Data
  func configureWithCustomerData(customer: Customer) {
    self.scannedCustomer = customer
    setNameLabel()
    setBirthDateLabel()
    setYearsOldLabel()
    situationIsUserOfAge()
    setPurchaseLimitLabel(self.scannedCustomer)
    setAdditionalInfoOneLabel()
  }

  // MARK: subviewHelperMethods
  func setNameLabel() {
    nameLabel.text = scannedCustomer.name
  }

  func setBirthDateLabel() {
    let dateString = scannedCustomer.birthDate!
    birthDateLabel.text = addSlashesToDateString(dateString) as String
  }

  func setYearsOldLabel() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    let date: NSDate = dateFormatter.dateFromString(scannedCustomer.birthDate!)!
    let yearsOld : Int = calculateAge(date)
    let yearsOldString = String(yearsOld)
    yearsOldLabel.attributedText = (setYearsOldText(yearsOldString))
  }

  func situationIsUserOfAge() {
    //Actions Based on whether user is or is not of age
    if (CustomerChecker.isUserIs21(self.scannedCustomer) == true) {
      yearsOldVerificationImageView.image = UIImage(named: "check_Icon19x14")
      print(yearsOldVerificationImageView.image?.description)
    } else {
      yearsOldVerificationImageView.image = UIImage(named: "x_Icon21x21")
      underAgeRedBackgroundView.backgroundColor = ColorPalette.getFlowhubRed()
    }
  }

  func setPurchaseLimitLabel(inputCustomer:Customer) {
    if(CustomerChecker.isFromColorado(inputCustomer) == true) {
      additionalInfoLabelTwo.text = "(28 grams max)"
    } else {
      additionalInfoLabelTwo.text = "(7 grams max)"
    }
  }

  // FIXME:State discrepency between two letter abbrievation and full state
  // i.e Co vs Colorado
  func setAdditionalInfoOneLabel() {
    let stateFromLicense : String = scannedCustomer.usState!

    let fromAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-thin", size: 17)!]
    let fromAttributedString = NSAttributedString(string: "from ", attributes: fromAttributes)

    let stateAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!]
    let stateAttributedString = NSAttributedString(string: stateFromLicense, attributes: stateAttributes)

    let fromStateString = NSMutableAttributedString(attributedString: fromAttributedString)
    fromStateString.appendAttributedString(stateAttributedString)

    additionalInfoLabelOne.attributedText = fromStateString

  }

  // MARK: Set Button States
  func setButtonStates(inputCustomerState: CustomerState) {
      switch inputCustomerState {
      case .NotInDatabase:
        topButton.setTitle("Check-in Rec", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeRec")
        middleButton.setTitle("Add Med Patient", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeMed")
        bottomButton.setTitle("Cancel", forState: .Normal)
        bottomButton.buttonIconImageView.image = UIImage(named: "iconWhiteX")
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeRec")
        self.customerState = inputCustomerState
        break
      case .RecCustomerInDatabase:
        topButton.setTitle("Check-in Rec", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeRec")
        middleButton.setTitle("Add Med Patient", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeMed")
        bottomButton.setTitle("Cancel", forState: .Normal)
        bottomButton.buttonIconImageView.image = UIImage(named: "iconWhiteX")
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeLoyalty")
        self.customerState = inputCustomerState
        break
      case .MedCustomerInDatabase:
        topButton.setTitle("Check-in Rec", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeRec")
        middleButton.setTitle("Check-in Med", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeMed")
        bottomButton.setTitle("Cancel", forState: .Normal)
        bottomButton.buttonIconImageView.image = UIImage(named: "iconWhiteX")
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeMed")
        self.customerState = inputCustomerState
        break
      case .MedCustomerInDatabaseAndUnder21:
        topButton.setTitle("Check-in Med", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeMed")
        middleButton.hidden = true
        middleButton.enabled = false
        bottomButton.setTitle("Cancel", forState: .Normal)
        bottomButton.buttonIconImageView.image = UIImage(named: "iconWhiteX")
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeRec")
        self.customerState = inputCustomerState
        break
      case .Under21CustomerNotInDatabase:
        topButton.setTitle("Add Med Patient", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "iconWhiteCustomerTypeMed")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "iconWhiteX")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeMed")
        self.customerState = inputCustomerState
        break
      case .Under18CustomerNotInDatabase:
        topButton.setTitle("Add Med Patient", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "med_customer30x30")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeMed")
        self.customerState = inputCustomerState
        break
      case .DispensaryIsOnlyRecAndCustomerIsNotInDatabase:
        topButton.setTitle("Check-in Rec", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "rec_customer30x30")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeRec")
        self.customerState = inputCustomerState
        break
      case .DispensaryIsOnlyRecAndCustomerIsInDatabase:
        topButton.setTitle("Check-in Rec", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "rec_customer30x30")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeRec")
        self.customerState = inputCustomerState
        break
      case .DispensaryIsOnlyRecAndCustomerIsUnder21:
        topButton.setTitle("Cancel", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        middleButton.hidden = true
        middleButton.enabled = false
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeRec")
        self.customerState = inputCustomerState
        break
      case .DispensaryIsOnlyMedAndCustomerIsInDatabase:
        topButton.setTitle("Check-in Med", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "med_customer30x30")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeMed")
        self.customerState = inputCustomerState
        break
      case .DispensaryIsOnlyMedAndCustomerIsNotInDatabase:
        topButton.setTitle("Add New Patient", forState: .Normal)
        topButton.buttonIconImageView.image = UIImage(named: "med_customer30x30")
        middleButton.setTitle("Cancel", forState: .Normal)
        middleButton.buttonIconImageView.image = UIImage(named: "x_Icon9x9")
        bottomButton.hidden = true
        bottomButton.enabled = false
        customerTypeIconImageView.image = UIImage(named: "scanCustomerTypeMed")
        self.customerState = inputCustomerState
        break
      }
  }
  
  // MARK: Actions
  @IBAction func onTopButtonPressed(sender: NewScanPopoverCustomButton) {
    if let delegate = self.delegate {
      delegate.topButtonPressed(self, topButton: sender)
    }
  }
  @IBAction func onMiddleButtonPressed(sender: NewScanPopoverCustomButton) {
    if let delegate = self.delegate {
      delegate.middleButtonPressed(self, middleButton: sender)
    }
  }
  @IBAction func onBottomButtonPressed(sender: NewScanPopoverCustomButton) {
    if let delegate = self.delegate {
      delegate.bottomButtonPressed(self, bottomButton: sender)
    }
  }

}
