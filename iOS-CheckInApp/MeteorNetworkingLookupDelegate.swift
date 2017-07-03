//
//  MeteorNetworkingLookupDelegate.swift
//  iOS-CheckInApp
//
//  Created by Alexander Moller on 5/16/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

protocol MeteorNetworkingLookupDelegate {
  func customerWasSucessfullyFound(mongoID:String?, medId:String?, phone:String?, medExpirationDate:String?, type:String?)
  func customerWasNotFound()
  func multipleCustomersFoundInDatabase(arrayOfCustomerDictionaries:NSMutableArray)
}