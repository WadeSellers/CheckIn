//
//  AWSNetworkingDelegate.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 3/28/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import Foundation

protocol AWSNetworkingDelegate {
  func medPhotosUploadedSucessfully()
  func medPhotosErroredOrTimedout(photoArrayTuple:[(name: String, photo: UIImage)])
}