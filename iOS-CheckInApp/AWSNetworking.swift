//
//  AWSNetworking.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 1/29/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation
import AmazonS3RequestManager
import NSLogger

class AWSNetworking: NSObject {
  
  
  #if DEVELOPMENT
  static let amazonEmployeeBucket = "flowhub-demo-pos-employee-docs-2"
  static let amazonMedCustomerBucket = "flowhub-demo-pos-med-customer-docs"
//  static let amazonEmployeeBucket = "flowhub-testing-pos-employee-docs"
//  static let amazonMedCustomerBucket = "flowhub-testing-pos-med-customer-docs"
  #else
  static let amazonEmployeeBucket = "flowhub-pos-employee-docs"
  static let amazonMedCustomerBucket = "flowhub-pos-med-customer-docs"
  #endif

  static let amazonS3EmployeeManager = AmazonS3RequestManager(bucket:amazonEmployeeBucket,
  region: .USStandard,
  accessKey: AWSInfo.medCustomerAWSAccessKey ,
  secret: AWSInfo.medCustomerAWSSecretKey)

  static let amazonS3MedCustomerManager = AmazonS3RequestManager(bucket:amazonMedCustomerBucket,
      region: .USStandard,
      accessKey: AWSInfo.medCustomerAWSAccessKey,
      secret: AWSInfo.medCustomerAWSSecretKey)

  static var downloadAWSProfPicString:String = "/"
  static var uploadAWSMedString:String = "/"
  static var delegate:AWSNetworkingDelegate?
  
  class func downloadImageFromAWS() {
    amazonS3EmployeeManager.getObject(getAWSProfPicString())
      .responseS3Data { (response) -> Void in
        // Handle Response Data or Error
        if(response.result.isSuccess) {
          //unwrapping two optionals lol
          let imageData:NSData = response.result.value!!
          let image:UIImage = UIImage(data: imageData)!
          CurrentUser.sharedInstance.profPic = image
          NSNotificationCenter.defaultCenter().postNotificationName("employeeImageRecieved:", object: nil)
        } else {
          print(response.result.error)
        }
    }
  }

  // MARK: Upload Photos To AWS
  class func sendMedCardInfoToAwsWithPhotoArrayTuple(inputPhotoArrayTuple:[(name: String, photo: UIImage)], mongoId:String, addMongoIdToPhotoName:Bool)    {
    
    let index:Int = inputPhotoArrayTuple.count - 1
    var photoArrayTuple:[(name: String, photo: UIImage)] = inputPhotoArrayTuple

    if(index < 0) {
      delegate?.medPhotosUploadedSucessfully()
    } else {
      let medInfoImageAndNameTuple = inputPhotoArrayTuple[index]
      let medInfoImage:UIImage = medInfoImageAndNameTuple.photo
      var medInfoImageName:String = medInfoImageAndNameTuple.name
      medInfoImageName = medInfoImageName.substituteDashesInForSpacesAndMakeAllLowercase()
      if addMongoIdToPhotoName == true {
        medInfoImageName = mongoId.stringByAppendingString("-\(medInfoImageName)")
      }
      print(medInfoImageName)
      let imageData:NSData = UIImageJPEGRepresentation(medInfoImage, 0.5)!
      amazonS3MedCustomerManager.putObject(imageData, destinationPath: getCustomerMedAWSInfo(mongoId, fileName: medInfoImageName))
        .responseS3Data { (response) -> Void in
          //this is the aws reponse of a "200"
          if(response.result.isSuccess) {
            print(response)
            photoArrayTuple.removeAtIndex(index)
            sendMedCardInfoToAwsWithPhotoArrayTuple(photoArrayTuple, mongoId: mongoId, addMongoIdToPhotoName: true)
          } else {
            LogMessageRaw(response.result.error?.description)
            print(response.result.error)
            delegate?.medPhotosErroredOrTimedout(photoArrayTuple)
          }
      }
    }
  }

  // MARK: test 1 photo upload
  class func testOnePhoto() {
    let medInfoImage:UIImage = UIImage(imageLiteral: "Dali")
    let imageData:NSData = UIImageJPEGRepresentation(medInfoImage, 0.5)!
    amazonS3MedCustomerManager.putObject(imageData, destinationPath: "7177207")
      .responseS3Data { (response) -> Void in
        //this is the aws reponse of a "200"
        if(response.result.isSuccess) {
        } else {
          //have some timeout here
        }
    }

  }
  
  // MARK: AWS String/URL helper methods
  class func getAWSProfPicString() -> String {
    // clientID/Username
    downloadAWSProfPicString = downloadAWSProfPicString + CurrentUser.sharedInstance.clientID! + "/" + CurrentUser.sharedInstance.username!
    // /Username-profPicUploaded
    downloadAWSProfPicString = downloadAWSProfPicString + "/" + CurrentUser.sharedInstance.username! + "-" + CurrentUser.sharedInstance.profPicName!
    print("the download aws string is", downloadAWSProfPicString)
    return downloadAWSProfPicString
  }
  
  //[bucket]/[mongoId]/[mongoId]-[fileName]
  //CAN BE 0 SPACES IN AWS File Name ADD (spaces are cleaned up back in additionalInfoTwoVC)
  class func getCustomerMedAWSInfo(inputMongoId:String, fileName:String) -> String  {
    uploadAWSMedString = "/"
    let mongoId:String = inputMongoId
    //mongoId/mongoId-fileName
    uploadAWSMedString = uploadAWSMedString + mongoId + "/" + fileName
    //mongoId/mongoId-fileName (second mongoId was added to fileName back in addionalInfoTwoVC)
    print("the uploaded AWS med string is ",uploadAWSMedString)
    return uploadAWSMedString
  }

}
