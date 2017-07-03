//
//  Customer.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/16/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class Customer: GenericCustomer {
  // name might have to be concealed later due to anonymity
//  var name: String?
  var checkinTime : String?
  var id:String?

  var customerTypePicture:UIImage?
  var timeWaitingInQueue:Int?
  
  var customerType:String?
  // defined by database schema
  let recCustomerString:String = "recCustomer"
  let medCustomerString:String = "medCustomer"
  
  var licenseExpiration:String?
  var addressOne:String?
  var addressTwo:String?
  var city:String?
  var zipCode:String?
  var driversLicenseNumber:String?
  
  var phoneNumber:String?

  init(inputName:String, inputCheckInTime:String, inputBirthDate: String, inputUSState:String, inputType:String, id:String) {
    super.init()
    super.name = inputName.removeTrailingSpaces()
    checkinTime = inputCheckInTime.removeTrailingSpaces()
    super.birthDate = inputBirthDate.removeTrailingSpaces()
    super.usState = inputUSState.removeTrailingSpaces()
    self.id = id.removeTrailingSpaces()
    
    if(inputType == recCustomerString) {
      customerTypePicture = UIImage(imageLiteral:"rec-customer")
      self.customerType = "rec-customer"
    } else if (inputType == medCustomerString) {
        customerTypePicture = UIImage(imageLiteral:"med-customer" )
      self.customerType = "med-customer"
    } else {
        customerTypePicture = UIImage(imageLiteral:"med-primary")
      self.customerType = "med-customer"
    }
    
  }
  

  convenience init(convInputName:String, convInputCheckInTime:String, convInputBirthDate: String, convInputUSState:String, convInputType:String, convId:String, inputLicenseExpirationDate:String, inputAddressOne:String, inputAddressTwo:String, inputAddressCity:String, inputDriversLicenseNumber:String, inputZipCode:String) {
    
    self.init(inputName: convInputName.removeTrailingSpaces(), inputCheckInTime: convInputCheckInTime.removeTrailingSpaces(), inputBirthDate: convInputBirthDate.removeTrailingSpaces(), inputUSState: convInputUSState.removeTrailingSpaces(), inputType: convInputType.removeTrailingSpaces(), id: convId.removeTrailingSpaces())
    licenseExpiration = inputLicenseExpirationDate
    addressOne = inputAddressOne
    addressTwo = inputAddressTwo
    city = inputAddressCity
    driversLicenseNumber = inputDriversLicenseNumber
    zipCode = inputZipCode
    
  }
  
  class func createCustomerFromDictionary(customerDictionary:NSMutableDictionary) -> Customer {
    let dateAsDouble:Double = (customerDictionary.objectForKey("birthDate") as! NSMutableDictionary).objectForKey("$date") as! Double
    let checkinTimeAsDouble:Double? = (customerDictionary.objectForKey("checkinTime") as? NSMutableDictionary)?.objectForKey("$date") as? Double
    let birthDate:String = DateHelper.convertTimeFrom1970DateToBirthDateString(dateAsDouble)
    var customerCheckInTime:String?
    var checkInTimeInt:Int?
    
    if let _ = checkinTimeAsDouble {
      let checkInTime:String = DateHelper.convertTimeFrom1970DateToCheckInTimeString(checkinTimeAsDouble!).timeString
      checkInTimeInt = DateHelper.convertTimeFrom1970DateToCheckInTimeString(checkinTimeAsDouble!).intTime
      customerCheckInTime = checkInTime
    } else {
      checkInTimeInt = nil
      customerCheckInTime = " "
    }
    
    //not showing seconds currently only the date
    //to prevent software failure incase we asset nil value
    let customerName:String? = customerDictionary.objectForKey("name") as? String
    let customerBirthDate:String? = birthDate
    let customerState:String? = customerDictionary.objectForKey("state") as? String
    let customerType:String? = customerDictionary.objectForKey("type") as? String
    let customerID:String? = customerDictionary.objectForKey("_id") as? String
    
    let dispensaryCustomer : Customer = Customer.init(inputName: customerName! , inputCheckInTime: customerCheckInTime!, inputBirthDate: customerBirthDate!, inputUSState: customerState!, inputType: customerType!, id: customerID!)
    dispensaryCustomer.timeWaitingInQueue = checkInTimeInt
    
    return dispensaryCustomer
  }
  
//  class func createCustomerFromRealmCustomer(inputRealmCustomer:RealmCustomer) -> Customer {
//    let customerCreatedFromRealmCustomer:Customer = Customer(inputName: inputRealmCustomer.name!, inputCheckInTime: "", inputBirthDate: inputRealmCustomer.birthDate!, inputUSState: inputRealmCustomer.usState!, inputType: "recCustomer", id: inputRealmCustomer.id!)
//    return customerCreatedFromRealmCustomer
//  }
}
