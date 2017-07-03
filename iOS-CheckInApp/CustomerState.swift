//
//  CustomerState.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 5/24/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

enum CustomerState {
  case NotInDatabase
  case MedCustomerInDatabase
  case RecCustomerInDatabase
  case MedCustomerInDatabaseAndUnder21
  case Under21CustomerNotInDatabase
  case Under18CustomerNotInDatabase
  case DispensaryIsOnlyRecAndCustomerIsNotInDatabase
  case DispensaryIsOnlyRecAndCustomerIsInDatabase
  case DispensaryIsOnlyRecAndCustomerIsUnder21
  case DispensaryIsOnlyMedAndCustomerIsNotInDatabase
  case DispensaryIsOnlyMedAndCustomerIsInDatabase
}