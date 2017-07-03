//
//  NamePhotoViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 2/18/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class NamePhotoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var photoImageview: UIImageView!
  @IBOutlet weak var customNameTextField: UITextField!

  var optionsPickerView : UIPickerView?
  var imageToName : UIImage!
  var imageName : String?
  var listOfNames = ["MMR Card", "Liability Waiver", "Drivers License", "Transfer Notice", "State ID", "Medical Documentation", "Other"]
  var textFieldActivated : Bool?
  var customTitleRow: Int!

  override func viewDidLoad() {
    super.viewDidLoad()
    customTitleRow = listOfNames.count - 1
    customNameTextField.delegate = self
    textFieldActivated = false

    let testForNextBarButtonActivation = #selector(NamePhotoViewController.testForNextBarButtonActivation)
    customNameTextField.addTarget(self, action: testForNextBarButtonActivation, forControlEvents: UIControlEvents.EditingChanged)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    optionsPickerView = createPickerView()
    self.view.addSubview(optionsPickerView!)

    //Setup code for each time view appears
    setupNavControllerAndBar()

    photoImageview.image = self.imageToName
    customNameTextField.alpha = 0.0
    testForNextBarButtonActivation()

  }

  // MARK: NavController Helper Method
  func setupNavControllerAndBar() {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationController?.navigationBar.barTintColor = ColorPalette.getFlowhubGrey()
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.navigationItem.title = "Now Name It"
    let nextButtonTapped = #selector(NamePhotoViewController.nextButtonTapped)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: nextButtonTapped)
  }

  // MARK: PickerView Delegate Methods
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func createPickerView() -> UIPickerView {
    let optionsPickerView : UIPickerView = UIPickerView(frame: CGRect(x: 0.0, y: 0.0, width: super.view.frame.size.width, height: 216))
    optionsPickerView.center = super.view.center
    optionsPickerView.delegate = self
    optionsPickerView.dataSource = self

    return optionsPickerView
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return listOfNames.count
  }

  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    let titleData: String = listOfNames[row]
    let shownTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])

    return shownTitle
  }

  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    testForNextBarButtonActivation()
    //list of names count starts at 1 but row starts at 0 so we subtract 1 of listOfNamesCount here
    self.customTitleRow = listOfNames.count - 1

    if row == customTitleRow {
      activateTextField(customNameTextField, activate: true)
    } else if row != customTitleRow {
      activateTextField(customNameTextField, activate: false)
    }
  }

  // MARK: TextField Helper Methods
  func activateTextField(textfield: UITextField, activate: Bool) {
    if activate == true && textFieldActivated == false {
      textfield.enabled = true
      textfield.becomeFirstResponder()
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        textfield.alpha = 1.0
        self.optionsPickerView!.center = CGPoint(x: self.optionsPickerView!.center.x, y: self.optionsPickerView!.center.y - 100)
      })
      textFieldActivated = true
    } else if activate == false && textFieldActivated == true {
      textfield.enabled = false
      textfield.resignFirstResponder()
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.optionsPickerView!.center = CGPoint(x: self.optionsPickerView!.center.x, y: self.optionsPickerView!.center.y + 100)
        textfield.alpha = 0.0
      })
      textFieldActivated = false
    }
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    nextButtonTapped()

    return true
  }

  func testForNextBarButtonActivation() {
    let selectedComponentRow : Int = (optionsPickerView?.selectedRowInComponent(0))!
    if selectedComponentRow < listOfNames.count - 1 {
      self.navigationItem.rightBarButtonItem?.enabled = true
    } else {
      if customNameTextField.text == "" {
        self.navigationItem.rightBarButtonItem?.enabled = false
      } else {
        self.navigationItem.rightBarButtonItem?.enabled = true
      }
    }
  }

  // MARK: Next UIBarButtonItem and Keyboard Next functionality
  func nextButtonTapped() {
    setImageName()
    addPhotoTupleToMedCustomerPhotoArray()
    self.performSegueWithIdentifier("unwindToTakePhotosViewController", sender: self)
  }

  // MARK: Helper to add Photo Tuple to MedCustomers Photo Array
  func addPhotoTupleToMedCustomerPhotoArray() {
    let photoTuple = (name: self.imageName!, photo: self.imageToName!)
    if CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray == nil {
      CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray = [photoTuple]
    } else {
        CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.append(photoTuple)
    }
  }

  // MARK: helper for choosing imageName
  // TODO:Rename method substitute dashes in strings for spaces
  func setImageName() {
    if self.optionsPickerView?.selectedRowInComponent(0) == nil {
      self.imageName = self.listOfNames[0].substituteDashesInForSpacesAndMakeAllLowercase()
    } else if self.optionsPickerView?.selectedRowInComponent(0) == self.customTitleRow {
      var tempImageName = self.customNameTextField.text?.removeTrailingSpaces()
      tempImageName?.substituteDashesInForSpacesAndMakeAllLowercase()
      self.imageName = tempImageName
    } else {
      self.imageName = self.listOfNames[(self.optionsPickerView?.selectedRowInComponent(0))!].substituteDashesInForSpacesAndMakeAllLowercase()
    }

    self.imageName = checkForDuplicateImageNameAndUpdateIfNecessary(self.imageName!)
  }

  func checkForDuplicateImageNameAndUpdateIfNecessary(imageName:String) -> String {
    var numberOfOccurencesOfImageName:Int = 0

    if let photoTupleArray = CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray {
      dump(photoTupleArray)
      for photoItem in photoTupleArray {
        if (photoItem.name.containsString(imageName)) {
          numberOfOccurencesOfImageName = numberOfOccurencesOfImageName + 1
        }
      }
    }

    if numberOfOccurencesOfImageName == 0 {
      return imageName
    } else {
      print("The Updated ImageName is: \(imageName + "-" + String(numberOfOccurencesOfImageName))")
      return imageName + "-" + String(numberOfOccurencesOfImageName)
    }
  }

}
