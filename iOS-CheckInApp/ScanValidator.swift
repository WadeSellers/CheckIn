//
//  ScanValidator.swift
//  iOS-CheckInApp
//
//  Created by Alexander Moller on 5/23/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//


class ScanValidator: NSObject {
  class func isNameValid(inputName:String) -> Bool {
    //must put double forward slash so that swift recognizes it as a string and not an escape character to the string
    let regexString:String = "^[\\w-']+(?:\\s[\\w-']+)+$"
    if inputName.rangeOfString(regexString, options: .RegularExpressionSearch) != nil {
      return true
    }
    return false
  }
  
  class func isNameBirthDateAndStateAreSet(name:String, birthday:String, state:String) -> Bool {
    if name != "" && birthday != "" && state != "" {
      return true
    }
    return false
  }
}
