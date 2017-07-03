//
//  CustomerChecker.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 3/30/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

class CustomerChecker:NSObject {
  
  class func isLicenseExpired(inputCustomer:Customer) -> Bool {
    print(inputCustomer.licenseExpiration!)
    let currentDate : NSDate = NSDate()
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    let expirationDate: NSDate = dateFormatter.dateFromString(inputCustomer.licenseExpiration!)!
    if currentDate.isGreaterThanDate(expirationDate) {
      return true
    } else {
      return false
    }
  }
  
  class func isUserIs21(inputCustomer:Customer) -> Bool {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    let date: NSDate = dateFormatter.dateFromString(inputCustomer.birthDate!)!
    let yearsOld : Int = calculateAge(date)
    if yearsOld >= 21 {
      return true
    } else {
      return false
    }
  }
  
  class func isUserOver18(inputCustomer:Customer) -> Bool {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMddyyyy"
    let date: NSDate = dateFormatter.dateFromString(inputCustomer.birthDate!)!
    let yearsOld : Int = calculateAge(date)
    if yearsOld >= 18 {
      return true
    } else {
      return false
    }
  }
  
  class func isFromColorado(inputCustomer:Customer) -> Bool  {
    if(inputCustomer.usState! == "CO" || inputCustomer.usState! == "Colorado") {
      return true;
    } else {
      return false;
    }
  }
}