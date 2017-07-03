//
//  QueueViewController.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
  
  @IBOutlet weak var queueTableView: UITableView!
  @IBOutlet weak var customerQueueSearchTextField: UITextField!
  
    var customerQueue: NSArray?
    var customerQueueCopy:NSArray?
  
  var array:Array<String>?
    static var delegate:QueueViewControllerDelegate?
  
    override func viewDidLoad() {
      super.viewDidLoad()
      setupQueueView()
      setupTableView()
      setupInitalCustomerQueueSubcription()
      setupTextField()
      continuallyUpDateQueueWaitingTime()
    }
  
  // MARK: Setup Methods
  func setupQueueView() {
    self.view.backgroundColor = ColorPalette.getFlowhubGrey()
  }
  
  // TODO: Simple Fix for now, but not sure the complexity is worth it
  func continuallyUpDateQueueWaitingTime() {
    _ = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(QueueViewController.updateTime), userInfo: nil, repeats: true)
  }
  
  func updateTime() {
    MeteorNetworking.getCustomerQueueArray {
      (result: NSArray) in
      print("time is being updated")
      self.customerQueue = result
      self.customerQueueCopy = result
      self.queueTableView.reloadData()
    }
  }

  func setupTextField() {
    customerQueueSearchTextField.layer.cornerRadius = 15
    setAndRefreshTextfieldPlaceholder()

    let customerQueueSearchTextFieldDidChange = #selector(QueueViewController.customerQueueSearchTextFieldDidChange(_:))
    customerQueueSearchTextField.addTarget(self, action:customerQueueSearchTextFieldDidChange, forControlEvents: UIControlEvents.EditingChanged)
    customerQueueSearchTextField.leftViewMode = UITextFieldViewMode.Always
    customerQueueSearchTextField.leftView = UIImageView(image: UIImage(named: "search-eyeglass"))
    customerQueueSearchTextField.leftView?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
  }
  
  // MARK: Setup Table View
  func setupTableView() {
    queueTableView.backgroundColor = ColorPalette.getFlowhubGrey()
    queueTableView.tableFooterView = UIView()
    let hasSwipedRightOrLeft = #selector(QueueViewController.hasSwipedRightOrLeft(_:))
    let swipeLeftToRightGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: hasSwipedRightOrLeft)
     let swipeRightToLeftGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: hasSwipedRightOrLeft)
    swipeLeftToRightGesture.direction = UISwipeGestureRecognizerDirection.Right
    swipeRightToLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
    queueTableView.addGestureRecognizer(swipeLeftToRightGesture)
    queueTableView.addGestureRecognizer(swipeRightToLeftGesture)
  }
  
  // MARK: Setup Intial customer subscription
  func setupInitalCustomerQueueSubcription() {
    let didReceiveUpdate = #selector(QueueViewController.didReceiveUpdate(_:))
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveUpdate, name: "customers_added", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveUpdate, name: "customers_removed", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveUpdate, name: "customers_changed", object: nil)
    
    MeteorNetworking.getCustomerQueueArray {
      (result: NSArray) in
      self.customerQueue = result
      self.customerQueueCopy = result
      QueueViewController.delegate?.queueViewControllerHasLoadedCustomers()
    }
  }
  
  // MARK: UITableView Delegate Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _ = customerQueue {
      return self.customerQueue!.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! QueueTableViewCell
    let customer:Customer = self.customerQueue![indexPath.row] as! Customer
    
    if let _ = StateConstants.statesDictionary.objectForKey(customer.usState!) {
      customer.usState = StateConstants.statesDictionary.objectForKey(customer.usState!) as? String
    }
    
    let stateAbbreviationArray:Array = StateConstants.statesDictionary.allKeysForObject(customer.usState!)
    let stateAbbreviationString:String = stateAbbreviationArray.first as! String

    cell.customerName.text = "\(customer.name!) - \(stateAbbreviationString)"
    cell.waitTimeLabel.text = customer.checkinTime
    cell.typeOfCustomerImageView.image = customer.customerTypePicture

    cell.configureWaitTimeLabelColorBasedOnMinutes(customer.timeWaitingInQueue!)

    let customerBirthdayString = customer.birthDate!
    
    // TODO: Needs to be refactored into helper method
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    let date: NSDate = dateFormatter.dateFromString(customerBirthdayString)!
    let yearsOld : Int = calculateAge(date)
    let yearsOldString = String(yearsOld)

    let slashedDateFormatter = NSDateFormatter()
    slashedDateFormatter.dateFormat = "MMddyyyy"
    let slashedDate: NSDate = slashedDateFormatter.dateFromString(customerBirthdayString)!
    slashedDateFormatter.dateFormat = "MM/dd/yyyy"
    let finalSlashedDateString = slashedDateFormatter.stringFromDate(slashedDate)
    let slashedBirthdayString = String(finalSlashedDateString)

    cell.birthdayInfoLabel.text = ("\(yearsOldString) years old (\(slashedBirthdayString))")
    return cell;
  }
  
  func didReceiveUpdate(notification:NSNotification) {
    MeteorNetworking.getCustomerQueueArray {
      (result: NSArray) in
      self.customerQueue = result
      self.customerQueueCopy = result
      self.queueTableView.reloadData()
      self.setAndRefreshTextfieldPlaceholder()
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
    
  func hasSwipedRightOrLeft(gesture:UISwipeGestureRecognizer) {
    let location:CGPoint = gesture.locationInView(self.queueTableView)
    let indexPath:NSIndexPath? = self.queueTableView.indexPathForRowAtPoint(location)
    if let _ = indexPath {
      let customer:Customer = self.customerQueue![indexPath!.row] as! Customer
      let alertView = SCLAlertView()
      alertView.addButton("Yes") {
        MeteorNetworking.removeCustomerFromQueue(customer.id!)
      }
        let customerNameString:String = customer.name!
        let subWarningTitle:String =  "Are you sure you want to remove" + " " + customerNameString + " " + "out of the queue?"
        alertView.showWarning("Warning", subTitle:subWarningTitle, closeButtonTitle: "No", duration: 0.0, colorStyle: UInt(ColorPalette.getFlowHubBlueRGBHex()), colorTextButton: 0xFFFFFF, circleIconImage: UIImage(imageLiteral: "flowhubEmblem"))
    }
  }

  // MARK: Search/Filter Methods
  func customerQueueSearchTextFieldDidChange(textField:UITextField) {
    var customerArray:Array<Customer> = Array()
    customerQueue = customerQueueCopy
    let currentTextFieldValue:String = textField.text!
    if(currentTextFieldValue.characters.count != 0) {
      for index in 0..<customerQueue!.count {
        let customerForIndex:Customer = customerQueue![index] as! Customer
        if customerForIndex.name?.lowercaseString.rangeOfString(currentTextFieldValue) != nil {
          customerArray.append(customerForIndex)
        } else if customerForIndex.name?.rangeOfString(currentTextFieldValue) != nil {
          customerArray.append(customerForIndex)
        } else {
          //if it isn't in range
        }
      }
      customerQueue = customerArray
    } else {
        customerQueue = customerQueueCopy
    }
    queueTableView.reloadData()
  }

  func setAndRefreshTextfieldPlaceholder() {
    let placeholderAttributes = [
      NSForegroundColorAttributeName : UIColor.init(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0),
      NSFontAttributeName: UIFont(name: "HelveticaNeue-thin", size: 14)!
    ]

    let queueCount = MeteorNetworking.customerCount
    if queueCount == 0 {
      customerQueueSearchTextField.attributedPlaceholder = NSAttributedString(string: "No patients in queue", attributes: placeholderAttributes)
    } else if queueCount == 1 {
      customerQueueSearchTextField.attributedPlaceholder = NSAttributedString(string: "Search 1 patient in queue", attributes: placeholderAttributes)
    } else {
      customerQueueSearchTextField.attributedPlaceholder = NSAttributedString(string: "Search \(queueCount) patients in queue", attributes: placeholderAttributes)
    }
  }
  
  // MARK: Status bar methods
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return UIStatusBarAnimation.Slide
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
}
