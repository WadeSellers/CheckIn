//
//  MeteorNetworkingUploadDelegate.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 5/17/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

protocol MeteorNetworkingUploadDelegate {
  func customerWasSuccessfullyUploaded(mongoId:String)
  func customerUploadFailed()
}