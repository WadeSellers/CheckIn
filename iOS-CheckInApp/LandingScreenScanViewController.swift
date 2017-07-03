//
//  LandingScreenScanViewController.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/7/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit
import NSLogger
import Crashlytics

class LandingScreenScanViewController: UIViewController, SWRevealViewControllerDelegate, CaptuvoEventsProtocol, NewScanPopoverViewDelegate, QueueViewControllerDelegate, ManualCustomerAddViewDelegate, MeteorNetworkingLookupDelegate {
  
  @IBOutlet weak var queueButton: UIButton!
  @IBOutlet weak var manualAddCustomerButton: UIButton!
  @IBOutlet weak var instructionLabel: UILabel!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  var numLabel:UILabel = UILabel(frame: CGRectMake(6,1,15,15))
  var newCustomer:Customer?
  var recievedName:String?
  var recievedBirthDate:String?
  var recievedUSState:String?
  var genericCustomerForManualCheckIn:GenericCustomer = GenericCustomer()
  
  var isStatusBarHidden:Bool = false
  
  var recievedNamePointer:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var recievedBirthDatePointer:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var recievedUSStatePointer:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var scannedLicenseExpirationDate:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  
  var scannedLicenseAddressOne:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var scannedLicenseAddressTwo:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var scannedLicenseCity:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var scannedLicenseNumber:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  var scannedZipcode:UnsafeMutablePointer<String> = UnsafeMutablePointer<String>.alloc(1)
  
  var mongoIDFromMeteor:String?
  var arrayOfRecievedData:Array<UnsafeMutablePointer<String>> = Array<UnsafeMutablePointer<String>>()
  
  var customerDataArray = [String]()
  // MARK: View Will/Did Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupNavigationBar()
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    self.revealViewController().delegate = self
    QueueViewController.delegate = self
    self.addObservers()
    setupViews()
  }
  
  //Updates queue even when queue vc isn't loaded
  func didReceiveCustomers(notification:NSNotification) {
    MeteorNetworking.getCustomerQueueArray {
        (result: NSArray) in
    }
  }

  override func viewWillAppear(animated: Bool) {
    //Captuvo hardware shuts off if screen shuts so so we must reinitialize here
    Captuvo.sharedCaptuvoDevice().addCaptuvoDelegate(self)
    Captuvo.sharedCaptuvoDevice().startDecoderHardware()
    self.navigationController?.navigationBarHidden = true
    resetCurrentCustomerSingleton()
  }

  override func viewDidAppear(animated: Bool) {
    /* You can test a scan out here manually. Use this format...     "state,firstlastName,birthdate,licenseExpirationDate,address1,address2,city,state,licenseNumber,zipCode" 
    */

    //    sleep(3)
    //    decoderDataReceived("CO,Testing Primary,09011985,09082018,1020 15th st,unit 24m,denver,D1234567890,80202")
  }

  // MARK: App Activated
  func appActivated() {
    Captuvo.sharedCaptuvoDevice().addCaptuvoDelegate(self)
    Captuvo.sharedCaptuvoDevice().startDecoderHardware()
  }
  
  // MARK: Add Observers
  func addObservers() {
    let changeLabelCount = #selector(LandingScreenScanViewController.changeLabelCount)
    let appActivated = #selector(LandingScreenScanViewController.appActivated)
    let didReceiveCustomers = #selector(LandingScreenScanViewController.didReceiveCustomers(_:))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector:changeLabelCount, name:"updateCountLabel", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: appActivated, name: notifyAppBecameActive, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveCustomers, name: "customers_added", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveCustomers, name: "customers_updated", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveCustomers, name: "customers_changed", object: nil)
    
    addDelegates()
  }
  
  // MARK: Add Delegates
  func addDelegates() {
    MeteorNetworking.meteorNetworkingLookupDelegate = self
  }

  func setupViews() {
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Main_Background_Image")!)
    spinnerActivate(false)
  }

  // MARK: Setup Navigation Bar
  // TODO: Abstract this to the view
  func setupNavigationBar() {
    let startView:UIView = UIView(frame: CGRectMake(20, 20,18,18))
    startView.backgroundColor = UIColor.whiteColor()
    startView.layer.cornerRadius = 9
    numLabel.textColor = UIColor.blackColor()
    numLabel.backgroundColor = UIColor.clearColor()
    
    numLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
    MeteorNetworking.getCustomerQueueArray {_ in 
      //centers the text in the label if it's >=10
      if(MeteorNetworking.customerCount >= 10) {
        self.numLabel.frame = CGRectMake(4,1,15,15)
      } else {
        self.numLabel.frame =  CGRectMake(6,1,15,15)
      }
    }
    numLabel.text = String(MeteorNetworking.customerCount)
    startView.addSubview(numLabel)
    queueButton.addSubview(startView)
  }

  // MARK: Change Label Count
  func changeLabelCount() {
    numLabel.text = String(MeteorNetworking.customerCount)
    //centers the text in the label if it's >=10
    if(MeteorNetworking.customerCount >= 10) {
      numLabel.frame =  CGRectMake(4,1,15,15)
    } else {
        numLabel.frame =  CGRectMake(6,1,15,15)
    }
  }
  
  // MARK: Button pressed methods
  @IBAction func customerQueueButtonPressed(sender: UIButton) {
    revealViewController().revealToggleAnimated(true)
  }
  
  @IBAction func employeeMenuButtonPressed(sender: UIButton) {
    revealViewController().rightRevealToggleAnimated(true)
  }

  @IBAction func addCustomerManuallyButtonPressed(sender: UIButton) {
    showManualCustomerAddButton(false)
    let manualCustomerView:ManualCustomerAddView = ManualCustomerAddView.instanceFromNib()
    manualCustomerView.delegate = self
    manualCustomerView.frame = CGRect(x: 0, y: 0, width: 250, height: 400)
    manualCustomerView.center = CGPointMake(super.view.center.x, super.view.center.y + 40)
    showManualCustomerAddButton(false)
    self.view.addSubview(manualCustomerView)
  }
  
  func removePreviousViewIfItExits () {
    for view in self.view.subviews {
      if view.isKindOfClass(NewScanPopoverView) {
        view.fadeOut()
      }
      if view.isKindOfClass(ManualCustomerAddView) {
        view.fadeOut()
      }
    }
  }
  
  // MARK: Scanner Delegate Methods
  func decoderDataReceived(data: String!) {
    LogMessageRaw(data)
    if(self.view.window != nil) {
      manualAddCustomerButton.hidden = false
      manualAddCustomerButton.enabled = true
      spinnerActivate(true)
      removePreviousViewIfItExits()
      customerDataArray = data.componentsSeparatedByString(",")
      dump(customerDataArray)
      checkMeteorForExistenceOfCustomer()
    }
  }
  
  // MARK: Check Meteor For Existence of Customers
  private func checkMeteorForExistenceOfCustomer() {
    if(scannedBarcodeComesFromLicense() == true) {
      let newScannedCustomer:Customer = self.setupNewCustomer()
      guard let unwrappedCustomerBirthdate = newScannedCustomer.birthDate else {
        showScanCannotBeParsedAlert()
        return
      }
      guard let unwrappedCustomerName = newScannedCustomer.name else {
        showScanCannotBeParsedAlert()
        return
      }
      guard let unwrappedCustomerState = newScannedCustomer.usState else {
       showScanCannotBeParsedAlert()
       return
      }
      
      if (ScanValidator.isNameValid(unwrappedCustomerName)) {
        let utcBirthDate = DateHelper.convertDateFormatFromMMddyyyyStringToUTCString(unwrappedCustomerBirthdate)
        MeteorNetworking.getCustomersForNameAndBirthdate(unwrappedCustomerName, customerBirthdate: utcBirthDate, customerState: unwrappedCustomerState)
      } else {
        showScanCannotBeParsedAlert()
      }
    }
  }
  
  private func showScanCannotBeParsedAlert() {
    let alertView:SCLAlertView = SCLAlertView()
    let subWarningTitle:String =  "Cannot read barcode off license. Please try again or enter in manaully"
    alertView.showWarning("Cannot Parse Scan", subTitle:subWarningTitle, closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
    spinnerActivate(false)
  }
  
  // MARK: Delegate Methods for customer methods
  func customerWasNotFound() {
    let newScannedCustomer:Customer = setupNewCustomer()
      if (CustomerChecker.isLicenseExpired(newScannedCustomer)) {
        let alertView:SCLAlertView = SCLAlertView()
        let subWarningTitle:String =  "This license is expired. Please provide an alternative form of identification"
        alertView.showWarning("License Expired", subTitle:subWarningTitle, closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
      } else if (CustomerChecker.isUserIs21(newScannedCustomer) == false) {
        if(CustomerChecker.isUserOver18(newScannedCustomer) == false ) {
          let alertView:SCLAlertView = SCLAlertView()
          let subWarningTitle:String =  "This person is under 18. Please make sure they have the required documents"
          alertView.showWarning("Under 18", subTitle:subWarningTitle, closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
          displayScanPopoverWithPlainCustomer(newScannedCustomer, popOverState: .Under18CustomerNotInDatabase)
        } else {
          displayScanPopoverWithPlainCustomer(newScannedCustomer, popOverState: .Under21CustomerNotInDatabase)
        }
      } else {
        displayScanPopoverWithPlainCustomer(newScannedCustomer, popOverState: .NotInDatabase)
      }
    spinnerActivate(false)
  }

  func multipleCustomersFoundInDatabase(arrayOfCustomerDictionaries:NSMutableArray) {
    var arrayOfCustomersFoundInDatabase = Array<Customer>()
    let newScannedCustomer:Customer = setupNewCustomer()
     for arrayIndex in 0..<arrayOfCustomerDictionaries.count {
      let currentDictionaryForCustomer = arrayOfCustomerDictionaries[arrayIndex]
      //If they don't have a type then return out for swiftynesss
      let type = currentDictionaryForCustomer.objectForKey("type") as? String
      guard let unwrappedType = type
      else {
        MeteorNetworking.throwErrorToMeteor("Multiple Customers found, but some have no type - iOS", additionalInfo: "")
        return
      }
      //Get mongo and phone number for med and rec
      let mongoID = currentDictionaryForCustomer.objectForKey("_id") as? String
      let phone = currentDictionaryForCustomer.objectForKey("phone") as? String
      if(unwrappedType == "medCustomer") {
        let medId = currentDictionaryForCustomer.objectForKey("medId") as? String
        var expirationDateString:String? = nil
        let expirationDateDictionary = currentDictionaryForCustomer.objectForKey("medExp") as? NSMutableDictionary
        if let unwrappedDateDictionary = expirationDateDictionary {
          let dateInSeconds = unwrappedDateDictionary.objectForKey("$date") as? Double
          if let unwrappedDateInSeconds = dateInSeconds {
            expirationDateString = DateHelper.convertTimeFrom1970DateToBirthDateString(unwrappedDateInSeconds)
          }
        }
        //support for temp customres
        if let unwrappedMedId = medId {
          let newMedCustomer = MedCustomer(inputMedID: unwrappedMedId, inputMedLicenseExpirationDate: expirationDateString!, inputCustomer: newScannedCustomer)
          newMedCustomer.id = mongoID
          newMedCustomer.phoneNumber = phone
          newMedCustomer.customerType = unwrappedType
          arrayOfCustomersFoundInDatabase.append(newMedCustomer)
        } else {
          let newMedCustomer = MedCustomer(inputMedID: "Temp", inputMedLicenseExpirationDate: "07/29/2020", inputCustomer: newScannedCustomer)
          newMedCustomer.id = mongoID
          newMedCustomer.phoneNumber = phone
          newMedCustomer.customerType = unwrappedType
          arrayOfCustomersFoundInDatabase.append(newMedCustomer)
        }
      } else {
        newScannedCustomer.id = mongoID
        newScannedCustomer.phoneNumber = phone
        newScannedCustomer.customerType = unwrappedType
        arrayOfCustomersFoundInDatabase.append(newScannedCustomer)
      }
    }
    displayPopUpWithMultipleCustomers(arrayOfCustomersFoundInDatabase)
    spinnerActivate(false)
  }
  
  func customerWasSucessfullyFound(mongoID:String?, medId:String?, phone:String?, medExpirationDate:String?, type:String?) {
    guard let unwrappedType = type else {
      MeteorNetworking.throwErrorToMeteor("Customer sucessfullly found, but has no type - iOS", additionalInfo: "")
        return
    }
    let newScannedCustomer:Customer = setupNewCustomer()
    mongoIDFromMeteor = mongoID
    if(unwrappedType == "medCustomer") {
      if let unwrappedMedID = medId {
        let medCustomer = MedCustomer(inputMedID: unwrappedMedID, inputMedLicenseExpirationDate: "07/29/2020", inputCustomer: newScannedCustomer)
        medCustomer.id = mongoID
        displayPopUpWithMedCustomer(medCustomer)
      } else {
        //this is a temp customer
        let medCustomer = MedCustomer(inputMedID: "", inputMedLicenseExpirationDate: "07/29/2020", inputCustomer: newScannedCustomer)
        medCustomer.id = mongoID
        displayPopUpWithMedCustomer(medCustomer)
      }
    } else {
      newScannedCustomer.id = mongoID
      newScannedCustomer.phoneNumber = phone
      newScannedCustomer.customerType = type
      displayPopUpWithRecLoyaltyCustomer(newScannedCustomer)
    }
    spinnerActivate(false)
  }
  
    // MARK: PointerMethods
  private func allocPointersToCustomerInfo() {
    recievedNamePointer = UnsafeMutablePointer<String>.alloc(1)
    recievedBirthDatePointer = UnsafeMutablePointer<String>.alloc(1)
    recievedUSStatePointer = UnsafeMutablePointer<String>.alloc(1)
    scannedLicenseExpirationDate = UnsafeMutablePointer<String>.alloc(1)
    scannedLicenseAddressOne = UnsafeMutablePointer<String>.alloc(1)
    scannedLicenseAddressTwo = UnsafeMutablePointer<String>.alloc(1)
    scannedLicenseCity = UnsafeMutablePointer<String>.alloc(1)
    scannedLicenseNumber = UnsafeMutablePointer<String>.alloc(1)
    scannedZipcode = UnsafeMutablePointer<String>.alloc(1)
  }
  
  private func initializePointersToCustomerInfoAndAddToArray() {
    allocPointersToCustomerInfo()
    arrayOfRecievedData = [recievedUSStatePointer,recievedNamePointer,recievedBirthDatePointer,scannedLicenseExpirationDate,scannedLicenseAddressOne,scannedLicenseAddressTwo, scannedLicenseCity, scannedLicenseNumber, scannedZipcode]
    for i in 0..<arrayOfRecievedData.count {
      arrayOfRecievedData[i].initialize("")
    }
  }
  
  private func deallocPointersToCustomerInfo() {
    for i in 0..<arrayOfRecievedData.count {
      arrayOfRecievedData[i].destroy()
      arrayOfRecievedData[i].dealloc(1);
    }
  }
  
  // MARK: Setup new customer
  // TODO: Think of solution for adding expiration date
  private func setupNewCustomer() -> Customer {
    //Initialize pointers for future variables
    initializePointersToCustomerInfoAndAddToArray()
    //loop through the data we recieved and set our pointers
    for i in 0..<customerDataArray.count {
      arrayOfRecievedData[i].memory = customerDataArray[i] as String
    }

    //FIX THIS LATER
    if(scannedLicenseExpirationDate.memory == "") {
      scannedLicenseExpirationDate.memory = "10292050"
    }
    
    newCustomer = Customer(convInputName: recievedNamePointer.memory, convInputCheckInTime: "", convInputBirthDate: recievedBirthDatePointer.memory, convInputUSState: recievedUSStatePointer.memory, convInputType: "", convId: "", inputLicenseExpirationDate: scannedLicenseExpirationDate.memory, inputAddressOne: scannedLicenseAddressOne.memory, inputAddressTwo: scannedLicenseAddressTwo.memory, inputAddressCity: scannedLicenseCity.memory, inputDriversLicenseNumber: scannedLicenseNumber.memory, inputZipCode: scannedZipcode.memory)
    
    recievedName = recievedNamePointer.memory
    recievedUSState = recievedUSStatePointer.memory
    recievedBirthDate = recievedBirthDatePointer.memory
    
    deallocPointersToCustomerInfo()
    return newCustomer!
  }
  
  func scannedBarcodeComesFromLicense() -> Bool {
    let stateString : String = self.customerDataArray[0]
    if let _ = StateConstants.statesDictionary.objectForKey(stateString) {
      return true
    } else {
      return false
    }
  }

  // MARK: Display Customer(s) Methods
  private func displayScanPopoverWithPlainCustomer(customer: Customer, popOverState:CustomerState) {
    showManualCustomerAddButton(false)
    
    let newCustomerPopover:NewScanPopoverView = NewScanPopoverView(frame: CGRect(x: 0, y: 0, width: 270, height: 476))
    newCustomerPopover.center = CGPointMake(super.view.center.x, super.view.center.y + 20)
    newCustomerPopover.configureWithCustomerData(customer)
    newCustomerPopover.delegate = self
    self.view.addSubview(newCustomerPopover)
    newCustomerPopover.alpha = 0.0
    if(popOverState == .NotInDatabase || popOverState == .Under21CustomerNotInDatabase || popOverState == .Under18CustomerNotInDatabase) {
      if(CurrentLocation.sharedInstance.hasRecLicense == false) {
        newCustomerPopover.setButtonStates(.DispensaryIsOnlyMedAndCustomerIsNotInDatabase)
        newCustomerPopover.fadeIn()
      } else if(CurrentLocation.sharedInstance.hasMedLicense == false) {
        if(CustomerChecker.isUserIs21(customer) == false) {
          newCustomerPopover.setButtonStates(.DispensaryIsOnlyRecAndCustomerIsUnder21)
          newCustomerPopover.fadeIn()
        } else {
          newCustomerPopover.setButtonStates(.DispensaryIsOnlyRecAndCustomerIsNotInDatabase)
          newCustomerPopover.fadeIn()
        }
      } else {
        newCustomerPopover.setButtonStates(popOverState)
        newCustomerPopover.fadeIn()
      }
    } else {
      newCustomerPopover.setButtonStates(popOverState)
      newCustomerPopover.fadeIn()
    }
  }
    // TODO: Make everything below this cleaner or abstract to a seperate class
  private func displayPopUpWithMultipleCustomers(arrayOfCustomers:Array<Customer>) {
    showManualCustomerAddButton(false)
    let alertView = SCLAlertView()
    for i in 0..<arrayOfCustomers.count {
      let customerOfUnknownType = arrayOfCustomers[i]
      //if the customer is a med customer
      if (customerOfUnknownType.customerType == "medCustomer") {
        let medCustomer = customerOfUnknownType as! MedCustomer
        alertView.addButton(medCustomer.medId!) {
          self.mongoIDFromMeteor = medCustomer.id
          if(CurrentLocation.sharedInstance.hasRecLicense == false) {
            self.displayScanPopoverWithPlainCustomer(medCustomer, popOverState: .DispensaryIsOnlyMedAndCustomerIsInDatabase)
          } else {
            self.displayScanPopoverWithPlainCustomer(medCustomer, popOverState: .MedCustomerInDatabase)
          }
        }
      } else {
        alertView.addButton(customerOfUnknownType.phoneNumber!) {
          self.mongoIDFromMeteor = customerOfUnknownType.id
          if(CurrentLocation.sharedInstance.hasMedLicense == false) {
            self.displayScanPopoverWithPlainCustomer(customerOfUnknownType, popOverState: .DispensaryIsOnlyRecAndCustomerIsInDatabase)
          } else {
            self.displayScanPopoverWithPlainCustomer(customerOfUnknownType, popOverState: .RecCustomerInDatabase)
          }
        }
      }
    }

    alertView.addButton("Cancel") { 
      self.showManualCustomerAddButton(true)
    }
    alertView.showCloseButton = false
    let subWarningTitle:String =  "Please select the Med ID or phone number of the customer you are checking in"
    alertView.showWarning("Duplicate Customers", subTitle:subWarningTitle, closeButtonTitle: "Cancel", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
  }
  
  private func displayPopUpWithMedCustomer(scannedCustomer:Customer) {
    if(DateHelper.checkIfUnder21(scannedCustomer.birthDate!) == true) {
      //very rare edge case if customer is a med customer at an only rec store
      if(CurrentLocation.sharedInstance.hasMedLicense == false) {
        displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .DispensaryIsOnlyRecAndCustomerIsUnder21)
      } else {
        displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .MedCustomerInDatabaseAndUnder21)
      }
    } else {
      if(CurrentLocation.sharedInstance.hasRecLicense == false) {
        displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .DispensaryIsOnlyMedAndCustomerIsInDatabase)
      } else if(CurrentLocation.sharedInstance.hasMedLicense == false) {
        displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .DispensaryIsOnlyRecAndCustomerIsNotInDatabase)
      } else {
        displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .MedCustomerInDatabase)
      }
    }
  }
  
 private func displayPopUpWithRecLoyaltyCustomer(scannedCustomer:Customer) {
    if(CurrentLocation.sharedInstance.hasMedLicense == false) {
      displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .DispensaryIsOnlyRecAndCustomerIsInDatabase)
    } else {
      displayScanPopoverWithPlainCustomer(scannedCustomer, popOverState: .RecCustomerInDatabase)
    }
  }
  
  // MARK: NewScanPopoverViewDelegate Methods
  func topButtonPressed(controller: NewScanPopoverView, topButton: NewScanPopoverCustomButton) {
    showManualCustomerAddButton(true)
    // New Rec Custom will be checked in here.
    guard let unwrappedRecievedName = recievedName else {
      MeteorNetworking.throwErrorToMeteor("Top Button Pressed and Customer has no name - iOS", additionalInfo: "")
      return
    }
    guard let unwrappedRecievedUSState = recievedUSState else {
      MeteorNetworking.throwErrorToMeteor("Top Button Pressed and Customer has no state - iOS", additionalInfo: "")
      return
    }
    guard let unwrappedRecievedBirthdate = recievedBirthDate else {
      MeteorNetworking.throwErrorToMeteor("Top Button Pressed and Customer has no birthdate - iOS", additionalInfo: "")
      return
    }
    guard let unwrappedPopoverViewCustomerState = controller.customerState else {
      MeteorNetworking.throwErrorToMeteor("Top Button Pressed and Popup View has no customer state - iOS", additionalInfo: "")
      return
    }
    
    for view in self.view.subviews {
      if view.isKindOfClass(NewScanPopoverView) {
        switch unwrappedPopoverViewCustomerState {
        case .NotInDatabase:
          view.fadeOut()
          MeteorNetworking.addAndCheckInCustomerToQueue("rec", name: unwrappedRecievedName, state: unwrappedRecievedUSState, birthDate: addSlashesToDateString(unwrappedRecievedBirthdate) as String)
        break
        case .RecCustomerInDatabase:
          view.fadeOut()
          MeteorNetworking.checkInExistingMedOrRecLoyaltyCustomer(mongoIDFromMeteor)
          break
        case .MedCustomerInDatabase:
          view.fadeOut()
          //will be added as rec customer but won't have loyalty points etc
          MeteorNetworking.addAndCheckInCustomerToQueue("rec", name: unwrappedRecievedName, state: unwrappedRecievedUSState, birthDate: addSlashesToDateString(unwrappedRecievedBirthdate) as String)
        break
        case .MedCustomerInDatabaseAndUnder21:
          view.fadeOut()
          MeteorNetworking.checkInExistingMedOrRecLoyaltyCustomer(mongoIDFromMeteor)
        break
        case .Under21CustomerNotInDatabase:
          view.removeFromSuperview()
          self.performSegueWithIdentifier("segueFromLandingToNewMedPatient", sender: self)
        break
        case .Under18CustomerNotInDatabase:
          view.removeFromSuperview()
          self.performSegueWithIdentifier("segueFromLandingToNewMedPatient", sender: self)
        break
        case .DispensaryIsOnlyRecAndCustomerIsNotInDatabase:
          view.fadeOut()
          MeteorNetworking.addAndCheckInCustomerToQueue("rec", name: unwrappedRecievedName, state: unwrappedRecievedUSState, birthDate: addSlashesToDateString(unwrappedRecievedBirthdate) as String)
        break
        case .DispensaryIsOnlyRecAndCustomerIsInDatabase:
          view.fadeOut()
          MeteorNetworking.checkInExistingMedOrRecLoyaltyCustomer(mongoIDFromMeteor)
        break
        case .DispensaryIsOnlyRecAndCustomerIsUnder21:
          view.removeFromSuperview()
        break
        case .DispensaryIsOnlyMedAndCustomerIsNotInDatabase:
          view.removeFromSuperview()
          self.performSegueWithIdentifier("segueFromLandingToNewMedPatient", sender: self)
        break
        case .DispensaryIsOnlyMedAndCustomerIsInDatabase:
          view.fadeOut()
          MeteorNetworking.checkInExistingMedOrRecLoyaltyCustomer(mongoIDFromMeteor)
        break
        }
      }
    }
  }

  func middleButtonPressed(controller: NewScanPopoverView, middleButton: NewScanPopoverCustomButton) {
    showManualCustomerAddButton(true)
    
    guard let unwrappedPopoverViewCustomerState = controller.customerState else {
      MeteorNetworking.throwErrorToMeteor("Middle Button Pressed and Popup View has no customer state - iOS", additionalInfo: "")
      return
    }

    for view in self.view.subviews {
      if view.isKindOfClass(NewScanPopoverView) {
        switch unwrappedPopoverViewCustomerState {
          case .NotInDatabase:
            view.removeFromSuperview()
            self.performSegueWithIdentifier("segueFromLandingToNewMedPatient", sender: self)
            break
          case .RecCustomerInDatabase:
            view.removeFromSuperview()
              self.performSegueWithIdentifier("segueFromLandingToNewMedPatient", sender: self)
          break
          case .MedCustomerInDatabase:
            view.fadeOut()
            MeteorNetworking.checkInExistingMedOrRecLoyaltyCustomer(mongoIDFromMeteor)
            break
          case .MedCustomerInDatabaseAndUnder21:
            view.removeFromSuperview()
            break
          case .Under21CustomerNotInDatabase:
            view.removeFromSuperview()
            break
          case .Under18CustomerNotInDatabase:
            view.removeFromSuperview()
            break
          case .DispensaryIsOnlyRecAndCustomerIsNotInDatabase:
            view.removeFromSuperview()
            break
          case .DispensaryIsOnlyRecAndCustomerIsInDatabase:
            view.removeFromSuperview()
            break
          case .DispensaryIsOnlyRecAndCustomerIsUnder21:
            view.removeFromSuperview()
            break
          case .DispensaryIsOnlyMedAndCustomerIsInDatabase:
            view.removeFromSuperview()
            break
          case .DispensaryIsOnlyMedAndCustomerIsNotInDatabase:
            view.removeFromSuperview()
            break
        }
      }
    }
  }

  func bottomButtonPressed(controller: NewScanPopoverView, bottomButton: NewScanPopoverCustomButton) {
    showManualCustomerAddButton(true)
    for view in self.view.subviews {
      if view.isKindOfClass(NewScanPopoverView) {
        //This button is always cancel. Fade out
        view.fadeOut()
      }
    }
  }
  
  func queueViewControllerHasLoadedCustomers() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name:"customers_added", object: nil)
  }

  
  // MARK: ManualCustomerAddView Delegate Methods
  func manualCustomerViewAcceptButtonPressed(customerName:String, customerBirthday:String,customerState:String) {
    showManualCustomerAddButton(true)

    if ScanValidator.isNameBirthDateAndStateAreSet(customerName, birthday: customerBirthday, state: customerState) {
      if(ScanValidator.isNameValid(customerName)) {
        manualAddCustomerButton.hidden = false
        manualAddCustomerButton.enabled = true
        let customerBirthdayWithoutSlashes:String = customerBirthday.stringByReplacingOccurrencesOfString("/", withString: "")
        let concatentenatedDataString:String = customerState + "," + customerName + "," + customerBirthdayWithoutSlashes
        
        for view in self.view.subviews {
          if view.isKindOfClass(ManualCustomerAddView) {
            view.removeFromSuperview()
            decoderDataReceived(concatentenatedDataString)
          }
        }
        //Customer name failed Regex check
      } else {
         let _ : SCLAlertViewResponder = SCLAlertView().showError("Error", subTitle: "Customer Name is Invalid. Please enter a correct name", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
      }
    //some field is missing
    } else {
      view.endEditing(true)
      let _ : SCLAlertViewResponder = SCLAlertView().showError("Error", subTitle: "All fields required", closeButtonTitle: "Okay", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
    }
  }

  func manualCustomerViewCancelButtonPressed() {
    showManualCustomerAddButton(true)
    for view in self.view.subviews {
      if view.isKindOfClass(ManualCustomerAddView) {
        view.removeFromSuperview()
      }
    }
  }

  func showManualCustomerAddButton(showManualAddButton: Bool) {
    if showManualAddButton {
      manualAddCustomerButton.hidden = false
      manualAddCustomerButton.enabled = true
    } else {
      manualAddCustomerButton.hidden = true
      manualAddCustomerButton.enabled = false
    }
  }

  // MARK: Unwind Segue
  @IBAction func unwindToLandingScreenVC(segue: UIStoryboardSegue) {
    
  }

  // MARK: Prepare for Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "segueFromLandingToNewMedPatient" {
      let addNewMedPatientVC = segue.destinationViewController as! AddNewMedPatientViewController
      addNewMedPatientVC.passedRecCustomer = self.newCustomer
    }
  }

  // MARK: Resetting the CurrentCustomer singleton so we start fresh from this screen at all times.
  func resetCurrentCustomerSingleton() {
    let currentCustomer = CurrentMedCustomerThroughWorkflow.sharedInstance
    currentCustomer.resetValues()
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return UIStatusBarAnimation.Slide
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return false
  }

  func spinnerActivate(activate: Bool) {
    if activate {
        self.instructionLabel.text = "searching for customer"
        self.spinner.startAnimating()
    } else {
        self.instructionLabel.text = "scan an ID to check-in"
        self.spinner.stopAnimating()
    }
  }
}
