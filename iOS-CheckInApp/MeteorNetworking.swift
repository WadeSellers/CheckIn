//
//  MeteorNetworking.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/16/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit
import ObjectiveDDP
import Foundation

class MeteorNetworking: NSObject {
  
  static let preSocketURL = "pre2"
  #if DEVELOPMENT
  static let meteorSocketURL = "wss://pos-staging.flowhub.co/websocket"
//  static let meteorSocketURL = "wss://pos-testing.flowhub.co/websocket"

  #else
  static let meteorSocketURL = "wss://pos.flowhub.co/websocket"
  #endif
  
  static let meteor:MeteorClient = initialiseMeteor(preSocketURL, meteorSocketURL)
  static var meteorNetworkingLookupDelegate:MeteorNetworkingLookupDelegate?
  static var meteorNetworkingUploadDelegate:MeteorNetworkingUploadDelegate?
  
  static var customerCount:Int = 0
  // MARK: Get Customer QueueArray
  class func getCustomerQueueArray(completion: (result: NSArray) -> Void){
    let rawCustomerQueueData: M13MutableOrderedDictionary? = meteor.collections["customers"] as? M13MutableOrderedDictionary
    //if the whole dispensary chain has any sort of customers
    if let _  = rawCustomerQueueData {
      var queueCustomerDictionaryQueueArray = rawCustomerQueueData?.allObjects
      var resultQueueCustomerArray: Array<Customer> = Array<Customer>()

      for index in 0..<queueCustomerDictionaryQueueArray!.count {
        let customerDictionary: NSMutableDictionary = queueCustomerDictionaryQueueArray![index] as! NSMutableDictionary
        let checkinTimeDictionary: NSMutableDictionary? = customerDictionary.objectForKey("checkinTime") as? NSMutableDictionary
    
           //only add the customers checked in and at that store
        let customerLocation:String? = customerDictionary.objectForKey("currentLocation") as? String
        if(customerLocation == CurrentLocation.sharedInstance.currentLocationName) {
          if let _ = checkinTimeDictionary {
            let checkedInDispensaryCustomer:Customer = Customer.createCustomerFromDictionary(customerDictionary)
//            print("the checked in dispensary customer is", checkedInDispensaryCustomer.name)
            resultQueueCustomerArray.append(checkedInDispensaryCustomer)
          } else {
            //no check in time so do nothing
          }
        }
      }
      //sorts in place by timeWaitingInQueue
      resultQueueCustomerArray.sortInPlace({$0.timeWaitingInQueue > $1.timeWaitingInQueue})
      MeteorNetworking.customerCount = resultQueueCustomerArray.count
      NSNotificationCenter.defaultCenter().postNotificationName("updateCountLabel", object: nil)
      completion(result: resultQueueCustomerArray)
    } else {
      //no customers in queue so return an empty array
      let emptyCustomerQueueArray: Array<Customer> = Array<Customer>()
      completion(result: emptyCustomerQueueArray)
    }
  }
  
  // MARK: setup user
  class func setCurrentUser(name:String, address:String, position:String, currentLoc:String, clientId:String, profPicName:String) {
    CurrentUser.sharedInstance.fullName = name
    CurrentUser.sharedInstance.currentDispensaryAddress = address
    CurrentUser.sharedInstance.currentDispensary = currentLoc
    CurrentUser.sharedInstance.position = position
    //set it to a default image just in case, then attempt to download from AWS
    CurrentUser.sharedInstance.profPic = UIImage(imageLiteral: "rec-customer")
    CurrentUser.sharedInstance.clientID = clientId
    CurrentUser.sharedInstance.profPicName = profPicName
    AWSNetworking.downloadImageFromAWS()
  }
  
  // MARK: setup current user and customers
  class func setupCurrentUserAndCustomers() {
    let userIDString:String = meteor.userId
    let parametersForFindingCurrentUserInfo:NSMutableDictionary = NSMutableDictionary(objects:[userIDString], forKeys:["_id"])
    let currentUserParametersArray:NSArray = NSArray(object: parametersForFindingCurrentUserInfo)
    
    //add the subscription
    self.meteor.addSubscription("users", withParameters: currentUserParametersArray as [AnyObject])
    
    //wait for it to recieve values that aren't the default from login
    let didReceiveUsers = #selector(MeteorNetworking.didReceiveUsers(_:))
    NSNotificationCenter.defaultCenter().addObserver(self, selector: didReceiveUsers, name: "users_changed", object:nil)
  }
  
  // MARK: setupCurrentStore
  class func setupCurrentStoreCustomersSubscription(inputUserDictionary:NSMutableDictionary) {
    //add subscription by current location to get all customers for specified store
    let locationString:String = (inputUserDictionary.objectForKey("currentLocationName") as? String)!
    //if there current location matches their current location name
    let parametersForFindingCurrentStoreCustomers:NSMutableDictionary = NSMutableDictionary(object:locationString, forKey:"currentLocation")
    let parametersForGettingCurrentedCheckedInCustomerByStore:NSArray = NSArray(object: parametersForFindingCurrentStoreCustomers)
    //add the customer subscription with these parameters
    meteor.addSubscription("customers", withParameters: parametersForGettingCurrentedCheckedInCustomerByStore as [AnyObject])
    
    let currentLocation:String = (inputUserDictionary.objectForKey("currentLocationName") as? String)!
    CurrentLocation.sharedInstance.currentLocationName = currentLocation
    let locationLicenses:NSArray = (inputUserDictionary.objectForKey("currentLocationLicenses") as? NSArray)!
    CurrentLocation.sharedInstance.arrayOfStoreLicenses = locationLicenses
    CurrentLocation.sharedInstance.setLicenseOnCurrentLocation()
    
    //add an observer to see when customers object is ready
    let didReceiveCustomers = #selector(MeteorNetworking.didReceiveCustomers(_:))
    NSNotificationCenter.defaultCenter().addObserver(self, selector:didReceiveCustomers, name:"customers_added", object:nil)
    //after 5 seconds assume there are no customers and segue
    let notifyLoginClassCustomerHaveBeenRecieved = #selector(MeteorNetworking.notifyLoginClassCustomerHaveBeenRecieved)
    self.performSelector(notifyLoginClassCustomerHaveBeenRecieved, withObject: self, afterDelay: NSTimeInterval(3.0))
  }
  
  class func didReceiveUsers(notification:NSNotification) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name:"users_changed", object: nil)
    self.parseUserInfo()
  }
    
  class func parseUserInfo() {
    let rawEmployeeData:M13OrderedDictionary =  MeteorNetworking.meteor.collections["users"] as! M13OrderedDictionary
    
    //    Should be only one current user because uniqueID
    let currentUserDictionary:NSMutableDictionary = rawEmployeeData[0] as! NSMutableDictionary
    //only employeeName is required on the backend
    
    let employeeName:String? = currentUserDictionary.objectForKey("fullName") as? String
    var dispensaryAddress:String? = currentUserDictionary.objectForKey("streetAddress1") as? String
    var employeePosition:String? = currentUserDictionary.objectForKey("position") as? String
    var nameOfLocation:String? = currentUserDictionary.objectForKey("currentLocationName") as? String
    let clientID:String? = currentUserDictionary.objectForKey("clientId") as? String
    var profPicName:String? = currentUserDictionary.objectForKey("profPic") as? String
    
    //safety measures to prevent bad instruction program failures
    if let _ = dispensaryAddress {
    } else {
      dispensaryAddress = " "
    }
    
    if let _ = employeePosition {
    } else {
      employeePosition = " "
    }
    
    if let _ = nameOfLocation {
    } else {
      nameOfLocation = " "
    }
    
    if let _ = profPicName {
    } else {
      profPicName = " "
    }
    
    
    setCurrentUser(employeeName!, address: dispensaryAddress!, position: employeePosition!, currentLoc: nameOfLocation!, clientId: clientID!, profPicName: profPicName! )
    print("The name of the location is", nameOfLocation!)
    setupCurrentStoreCustomersSubscription(currentUserDictionary)
  }
  
  // MARK: Selector for recieving customers
  class func didReceiveCustomers(notification:NSNotification) {
    //cancels the timeout request if customers has been recieved
    let notifyLoginClassCustomerHaveBeenRecieved = #selector(MeteorNetworking.notifyLoginClassCustomerHaveBeenRecieved)
    self.cancelPreviousPerformRequestsWithTarget(self, selector: notifyLoginClassCustomerHaveBeenRecieved, object: self)
    self.notifyLoginClassCustomerHaveBeenRecieved()
  }
  
  class func notifyLoginClassCustomerHaveBeenRecieved() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name:"customers_added", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("customersRecieved:", object: nil)
  }
  
  // MARK: Add Customer
  /* formats for input are as follows...
  type: rec / med
  name: first lastInitial
  state: 2 letter abrev. ex: CO
  birthDate: mm/dd/yyyy
  */
  class func addAndCheckInCustomerToQueue(type:String, name:String, state:String, birthDate:String) {
    let parametersForFindingCurrentUserInfo:NSMutableDictionary = NSMutableDictionary(objects:[type, name, state, birthDate] , forKeys: ["type", "name", "state", "birthDate"])
    let parametersArray:NSArray = NSArray(object: parametersForFindingCurrentUserInfo)
    MeteorNetworking.meteor.callMethodName("saveCustomer", parameters: parametersArray as [AnyObject]) {(response, error) -> Void in
      if(error != nil ){
        print("The error is", error)
      } else {
        // TODO:Call alert that customer has been saved with delegate methods
      }
    }
  }
  
  // MARK: Check In Existing Med Or Rec Loyalty Customer 
  // This method adds a customer to the queue if they already in the database 
  // It takes the Mongo ID as the input and the web app handles the rest accordingly
  class func checkInExistingMedOrRecLoyaltyCustomer(mongoIDOfCustomerInDatabase:String?) {
    guard let unwrappedMongoIDOfCustomerInDatabase = mongoIDOfCustomerInDatabase
      else {
        print("the mongo id of the customer you are trying to add is nil")
        return 
    }
    MeteorNetworking.meteor.callMethodName("checkinCustomer", parameters: [unwrappedMongoIDOfCustomerInDatabase]) {(response, error) -> Void in
      if(error != nil ){
        print("The error is", error)
      } else {
        //successful add
      }
    }
  }

  // MARK: addAndCheckInMedCustomerToForFirstTIme 
  // This method should only be used when adding a med customer for the very firs time
  class func addAndCheckInMedCustomerToQueueForFirstTime
    (
    type:String,
    name:String,
    state:String,
    birthDateUTC:String,
    medId:String,
    medExpUTC:String,
    addressOne:String,
    addressTwo:String,
    city:String,
    zip:String,
    isLoyal:Bool,
    isTaxExempt:Bool,
    isPrimary:Bool,
    phone:String,
    email:String,
    driversLicenseNumber:String,
    uploadingImagesNames:Array<String>,
    plantCount:String,
    gramLimit:String
    )
  {

    var parametersForFindingCurrentUserInfo = NSMutableDictionary()
    if medId == "" {
      parametersForFindingCurrentUserInfo = NSMutableDictionary(objects:[type, name, state, birthDateUTC, addressOne, addressTwo, city, zip, isLoyal, isTaxExempt, isPrimary, phone, email, driversLicenseNumber, uploadingImagesNames, plantCount, gramLimit] , forKeys: ["type", "name", "state", "birthDate", "streetAddress1", "streetAddress2", "city", "zip", "isLoyal", "isTaxExempt", "isPrimary", "phone", "email", "stateId", "uploads", "plantCount", "gramLimit"])
    } else {
      parametersForFindingCurrentUserInfo = NSMutableDictionary(objects:[type, name, state, birthDateUTC, medId, medExpUTC, addressOne, addressTwo, city, zip, isLoyal, isTaxExempt, isPrimary, phone, email, driversLicenseNumber, uploadingImagesNames, plantCount, gramLimit] , forKeys: ["type", "name", "state", "birthDate", "medId", "medExp", "streetAddress1", "streetAddress2", "city", "zip", "isLoyal", "isTaxExempt", "isPrimary", "phone", "email", "stateId", "uploads", "plantCount", "gramLimit"])
    }
    
    let newCustomerInfoArray:NSArray = NSArray(object: parametersForFindingCurrentUserInfo)
    MeteorNetworking.meteor.callMethodName("saveCustomer", parameters: newCustomerInfoArray as [AnyObject]) {(response, error) -> Void in
      if(error != nil ){
        MeteorNetworking.throwErrorToMeteor("Failed to save new med customer. See Additional Info for failed customer data  - iOS", additionalInfo: newCustomerInfoArray)
        NSNotificationCenter.defaultCenter().postNotificationName("medInfoUploadResultedInError", object: nil, userInfo: ["errorMessage" : error])
        meteorNetworkingUploadDelegate?.customerUploadFailed()
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName("medInfoAcceptedIntoDatabase", object: nil)
        let responseDict = response as! [String:String]
        if let mongoId = responseDict["result"] {
          meteorNetworkingUploadDelegate?.customerWasSuccessfullyUploaded(mongoId)
        } else {
          meteorNetworkingUploadDelegate?.customerWasSuccessfullyUploaded("")
        }
      }
    }
  }

  // MARK: Look customer
  class func getCustomersForNameAndBirthdate(customerName:String, customerBirthdate:String, customerState:String) {
    let parametersToSearchForCustomerInDatabaseArray:NSArray = [customerName, customerBirthdate, customerState]
    print("the parameters array is", parametersToSearchForCustomerInDatabaseArray)
    MeteorNetworking.meteor.callMethodName("getCustomer", parameters: parametersToSearchForCustomerInDatabaseArray as [AnyObject]) {(response, error) -> Void in
      //Throws an error when there is no customer
      if(error != nil ){
        meteorNetworkingLookupDelegate?.customerWasNotFound()
      } else {
        print("the response is", response["result"])
        if let unwrappedResponseResult = response["result"] as? NSMutableArray {
          if(unwrappedResponseResult.count == 1) {
            let unwrappedDictionary = unwrappedResponseResult[0] as! NSMutableDictionary
            let mongoID = unwrappedDictionary.objectForKey("_id") as? String
            let medId = unwrappedDictionary.objectForKey("medId") as? String
            let phone = unwrappedDictionary.objectForKey("phone") as? String
            let type = unwrappedDictionary.objectForKey("type") as? String
            var expirationDateString:String? = nil
            let expirationDateDictionary = unwrappedDictionary.objectForKey("medExp") as? NSMutableDictionary
            if let unwrappedDateDictionary = expirationDateDictionary {
              let dateInSeconds = unwrappedDateDictionary.objectForKey("$date") as? Double
              if let unwrappedDateInSeconds = dateInSeconds {
                expirationDateString = DateHelper.convertTimeFrom1970DateToBirthDateString(unwrappedDateInSeconds)
              }
            }
            meteorNetworkingLookupDelegate?.customerWasSucessfullyFound(mongoID, medId:medId, phone:phone, medExpirationDate:expirationDateString, type:type)
          } else {
            meteorNetworkingLookupDelegate?.multipleCustomersFoundInDatabase(unwrappedResponseResult)
          }
        }
      }
    }
  }
  
  // MARK: removeCustomerFromQueue
  class func removeCustomerFromQueue(customerID:String) {
    let reason:String = "Unknown"
    let parametersArray:NSArray = [customerID,reason]
    MeteorNetworking.meteor.callMethodName("removeCustomerFromQueue", parameters: parametersArray as [AnyObject]) {(response, error) -> Void in
      if(error != nil ){
        print("The error is", error)
        
      } else {
        //successful add
      }
    }
  }
  
  class func throwErrorToMeteor(errorMessage:String, additionalInfo:AnyObject) {
    //Method signature is throwError(errorCode, reason, additionalInfo)
    let errorArguments:NSArray = ["", errorMessage, additionalInfo]
    MeteorNetworking.meteor.callMethodName("throwError", parameters: errorArguments as [AnyObject]) {(response, error) -> Void in
      if(error != nil ){
        print("The error is", error)
        
      } else {
        //successful add
      }
    }
  }
  //end of class
}
