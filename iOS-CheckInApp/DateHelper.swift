//
//  DateHelper.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 1/4/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class DateHelper: NSObject {
  
  
  static let dateFormatter = NSDateFormatter()
  static let slashedDateFormatter = NSDateFormatter()
  static let utcDateFormatter = NSDateFormatter()
  static let utcDateFormatterNoTimeZone = NSDateFormatter() 
  
  class func setupDateFormatters() {
    dateFormatter.dateStyle = .MediumStyle
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "MMddyyyy"
    
    utcDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    utcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
    
    slashedDateFormatter.timeZone = NSTimeZone.defaultTimeZone()
    slashedDateFormatter.dateFormat = "MM/dd/yyyy"
  }
  
  class func convertTimeFrom1970DateToBirthDateString(birthDateInSeconds: Double) -> String {
    let doubleBirthdayString:String = String(format:"%f", birthDateInSeconds)
    //In case we get the dreaded birthday of 01/01/1970
    if(Double(doubleBirthdayString) == 0) {
      return "01011970"
    } else {
      let rangeToCutOffExcessTimePrecision:Range<String.Index> = doubleBirthdayString.startIndex..<doubleBirthdayString.endIndex.advancedBy(-10)
      let newBirthDayDoubleCattedString:String = doubleBirthdayString.substringWithRange(rangeToCutOffExcessTimePrecision)
      let birthDayDate:NSDate = NSDate(timeIntervalSince1970:Double(newBirthDayDoubleCattedString)!)
      //dateFormatter for date style
      let resultBirthDayString:String = dateFormatter.stringFromDate(birthDayDate)
      
      return resultBirthDayString
    }
  }
  
  // MARK: getCheckInTime
  // Returns tuple of string and time
 class func convertTimeFrom1970DateToCheckInTimeString(checkInTimeInSeconds: Double) -> (timeString:String, intTime:Int) {
  let doubleCheckInTimeString:String = String(format:"%f", checkInTimeInSeconds)

  let rangeToCutOffExcessTimePrecision:Range<String.Index> = doubleCheckInTimeString.startIndex..<doubleCheckInTimeString.endIndex.advancedBy(-10)
  let newCheckIntimeDoubleCattedString:String = doubleCheckInTimeString.substringWithRange(rangeToCutOffExcessTimePrecision)

  let checkInTimeDate:NSDate = NSDate(timeIntervalSince1970:Double(newCheckIntimeDoubleCattedString)!)
  let currentTimeDate:NSDate = NSDate(timeIntervalSinceNow:0.0)
  let waitTimeSinceCheckIn:NSTimeInterval = currentTimeDate.timeIntervalSinceDate(checkInTimeDate)
  let minutesInAnHour:Double = 60.0
  let minsWaited:Int
  let minsBetweenDates:Double = waitTimeSinceCheckIn / minutesInAnHour
  minsWaited = Int(round(minsBetweenDates))

  //This is setup in case a design change dictates the look to change when the minutes are greater than 1
  var resultCheckInTimeString:String = String(minsWaited)
  if(minsWaited == 1) {
    resultCheckInTimeString = resultCheckInTimeString + "min"
  } else {
    resultCheckInTimeString = resultCheckInTimeString + "min"
  }
  
  return (resultCheckInTimeString, minsWaited)
}
  
  class func checkIfUnder21(inputDate:String) -> Bool {
    let currentTimeDate:NSDate = NSDate(timeIntervalSinceNow:0.0)
    let birthDate:NSDate = dateFormatter.dateFromString(inputDate)!
    let age:Int = NSCalendar.currentCalendar().components(.Year, fromDate: birthDate, toDate: currentTimeDate, options: []).year
    if(age < 21) {
      return true
    } else {
      return false
    }
  }

  class func convertDateFormatFromMMddyyyyStringToUTCString(inputMMddyyyyString: String) -> String {
    let dateString = inputMMddyyyyString
    let date = dateFormatter.dateFromString(dateString)
    let localUTCDateString = utcDateFormatter.stringFromDate(date!)

    return localUTCDateString
  }
  
  class func convertDateFromMMddyyyyToIncludeSlashes(inputMMddyyyyString: String) -> String {
    let dateString = inputMMddyyyyString
    let date = dateFormatter.dateFromString(dateString)
    let slashedDateString = slashedDateFormatter.stringFromDate(date!)

    return slashedDateString
  }
}
