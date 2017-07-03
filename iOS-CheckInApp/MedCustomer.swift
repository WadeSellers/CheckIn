//
//  MedCustomer.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/16/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class MedCustomer: Customer {
  var medId:String?
  var primaryLicenseNumber:String?
  var medLicenseExpirationDate:String?
  var photoArray:[(name: String, photo: UIImage)]?
  
   init(inputMedID:String, inputMedLicenseExpirationDate:String, inputCustomer:Customer) {
      super.init(inputName: inputCustomer.name!, inputCheckInTime: inputCustomer.checkinTime!, inputBirthDate: inputCustomer.birthDate!, inputUSState: inputCustomer.usState!, inputType: inputCustomer.customerType!, id: inputCustomer.id!)
    
      self.medId = inputMedID
      self.medLicenseExpirationDate = inputMedLicenseExpirationDate
  }
  
//  class func createMedCustomerFromRealmMedCustomer(inputRealmMedCustomer:RealmMedCustomer) -> MedCustomer {
//    let customerCreatedFromRealmMedCustomer:Customer = Customer(inputName: inputRealmMedCustomer.name!, inputCheckInTime: "", inputBirthDate: inputRealmMedCustomer.birthDate!, inputUSState: inputRealmMedCustomer.usState!, inputType: "medCustomer", id: inputRealmMedCustomer.id!)
//    
//    let medCustomerCreatedFromRealmMedCustomer = MedCustomer(inputMedID: inputRealmMedCustomer.medId!, inputMedLicenseExpirationDate: inputRealmMedCustomer.medLicenseExpirationDate!, inputCustomer: customerCreatedFromRealmMedCustomer)
//    
//    return medCustomerCreatedFromRealmMedCustomer
//  }
}
