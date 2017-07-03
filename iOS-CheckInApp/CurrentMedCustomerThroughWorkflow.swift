//
//  CurrentMedCustomerThroughWorkflow.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 3/2/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class CurrentMedCustomerThroughWorkflow: NSObject {

  static let sharedInstance = CurrentMedCustomerThroughWorkflow()

  // Vars we will acquire while going through the newMedCustomer workflow
  var medId: String?
  var medLicenseExpirationDate: String?
  var medLicenseExpirationDateUTC: String?
  var photoArray:[(name: String, photo: UIImage)]?
  var emailAddress: String?
  var loyaltyMember: Bool?
  var taxExempt: Bool?
  var isPrimary: Bool?

  // Vars we acquired from initial RecCustomer
  var name: String?
  var birthdate: String? // format: MM/dd/yyyy
  var birthdateUTC: String? // UTC strings are the long strings the database expects to receive
  var usState: String?
  var driversLicenseExpiration: String? // format: MM/dd/yyyy
  var driversLicenseExpirationUTC: String?
  var addressOne: String?
  var addressTwo: String?
  var city: String?
  var zipCode: String?
  var driversLicenseNumber: String?

  //Items added down the road
  var checkInTime: String?
  var customerType: String?
  var phoneNumber: String?
  var plantCount: String?
  var gramLimit: String?

  private override init() {
    // photoArray must be initialized so the photoGallery table won't break
    photoArray = []
    customerType = "med-customer"
    loyaltyMember = false
    taxExempt = false
    plantCount = "6"
    gramLimit = "56"
    medId = ""
    medLicenseExpirationDate = ""
    medLicenseExpirationDateUTC = ""
  }

  func resetValues() {
    medId = ""
    medLicenseExpirationDate = ""
    medLicenseExpirationDateUTC = ""
    photoArray = []
    emailAddress = ""
    loyaltyMember = false
    taxExempt = false
    isPrimary = false
    name = ""
    birthdate = ""
    birthdateUTC = ""
    usState = ""
    driversLicenseExpiration = ""
    driversLicenseExpirationUTC = ""
    addressOne = ""
    addressTwo = ""
    city = ""
    zipCode = ""
    driversLicenseNumber = ""
    checkInTime = ""
    customerType = "med-customer"
    phoneNumber = ""
    plantCount = "6"
    gramLimit = "56"
  }

}

