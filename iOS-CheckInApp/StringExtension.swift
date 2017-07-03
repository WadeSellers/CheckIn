//
//  StringExtension.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 3/8/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

extension String {

  //To check text field or String is blank or not
  var isBlank: Bool {
    get {
      let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      return trimmed.isEmpty
    }
  }

  //Validate Email
  var isEmail: Bool {
    do {
      let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)

      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
    } catch {
      return false
    }
  }

  //validate PhoneNumber
  var isPhoneNumber: Bool {

    let character  = NSCharacterSet(charactersInString: " ()-0123456789").invertedSet
    var filtered: NSString!
    let inputString: NSArray = self.componentsSeparatedByCharactersInSet(character)
    filtered = inputString.componentsJoinedByString("")

    return  self == filtered
  }

  mutating func substituteDashesInForSpacesAndMakeAllLowercase() -> String {
    var dashedString = self.stringByReplacingOccurrencesOfString(" ", withString: "-")
    dashedString = dashedString.lowercaseString
    // We set self here because this is how we want the string to stay moving forward
    self = dashedString
    
    return self
  }

  func substituteSpacesInForStringDashes() -> String {
    let dashedString = self.stringByReplacingOccurrencesOfString("-", withString: " ")
    // We do not set "self =" here because we use this method simply for UI presentation purposes

    return dashedString
  }

  var isMoreThanOneWord: Bool {
    let words = self.componentsSeparatedByString(" ")
    if words.count > 1 {
      return true
    }else {
      return false
    }
  }

  /**
   Removes any spaces at the beginning or end of a string

   :returns: the original string without extra spaces
  */
  func removeTrailingSpaces() -> String {
    let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

    return trimmedString
  }

}
