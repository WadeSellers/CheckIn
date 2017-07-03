//
//  NSDateExtension.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 1/14/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

extension NSDate {
  var age: Int {
    return NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
  }
  
  func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
    return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
  }
}

  //these are class methods
  func calculateAge (birthday: NSDate) -> Int {
    return NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: NSDate(), options: []).year
  }

func addSlashesToDateString(dateString: NSString) -> NSString {
    
  if(dateString != "") {
    let monthString = dateString.substringWithRange(NSRange(location: 0, length: 2))
    let dayString = dateString.substringWithRange(NSRange(location: 2, length: 2))
    let yearString = dateString.substringWithRange(NSRange(location: 4, length: 4))
    let slashedDateString = "\(monthString)/\(dayString)/\(yearString)"
    return slashedDateString
  } else {
    return ""
  }
 
}


