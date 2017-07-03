//
//  MedPhotosViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 2/11/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class MedPhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var skipDoneButton: UIButton!

  var photoPreviewSubview : UIView?
  var blurSpinnerView : BlurWithSpinnerView?
  //var photosArray: [(name: String, photo: UIImage)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.delegate = self
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationItem.leftBarButtonItem?.title = ""
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

  }

  override func viewWillAppear(animated: Bool) {
    self.tableView.reloadData()
    setDoneSkipButtonText()

  }

  override func viewDidDisappear(animated: Bool) {
    blurSpinnerView?.removeFromSuperview()
  }

  // MARK: TableView Methods
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 110
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let photoArray = CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray {
      return photoArray.count + 1
    } else {
      return 1
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.count == 0 {
      tableView.separatorStyle = .None
    } else {
      tableView.separatorStyle = .SingleLine
    }

    let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PhotoTableViewCell

    if indexPath.row == CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray!.count {
      cell.photo.image = UIImage(named: "iconAddAnotherImage")
      if indexPath.row == 0 {
        cell.title.text = "Add an image"
      }else {
        cell.title.text = "Add another image"
      }
      cell.title.font = UIFont(name: "HelveticaNeue-ThinItalic", size: 18.0)
      cell.title.alpha = 0.5
      cell.subtitle.text = ""
    } else {
      cell.photo.image = CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray![indexPath.row].photo
      cell.title.text = CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray![indexPath.row].name.substituteSpacesInForStringDashes()
      cell.title.font = UIFont(name: "HelveticaNeue", size: 18.0)
      cell.title.alpha = 1.0
      cell.subtitle.text = "tap to zoom // swipe for options"
    }

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray!.count {
      showBlurSpinner()
      performSegueWithIdentifier("segueFromGalleryToTakePhoto", sender: nil)
    } else {
      showPhotoPreview(CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray![0].photo)
    }
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //If there's no photos, don't let the add image photo be swiped
    //If there are photos, don't let the last cell which is the add another image cell be swiped
    if CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.count == 0 {
      return false
    } else if indexPath.row == CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.count {
      return false
    } else {
      return true
    }
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }

  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .Normal, title: "Trash") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
      CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.removeAtIndex(indexPath.row)
      tableView.beginUpdates()
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
      tableView.endUpdates()
      self.setDoneSkipButtonText()
    }
    deleteAction.backgroundColor = UIColor(colorLiteralRed: 151.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.75)

    let retakeAction = UITableViewRowAction(style: .Normal, title: "Retake") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
      CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray?.removeAtIndex(indexPath.row)
      tableView.beginUpdates()
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
      tableView.endUpdates()
      self.setDoneSkipButtonText()
      self.performSegueWithIdentifier("segueFromGalleryToTakePhoto", sender: nil)
    }
    retakeAction.backgroundColor = UIColor(colorLiteralRed: 52.0/255.0, green: 60.0/255.0, blue: 72.0/255.0, alpha: 0.75)

    return [deleteAction, retakeAction]
  }

  // MARK: BlurView Methods
  func showBlurSpinner() {
    blurSpinnerView = BlurWithSpinnerView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height + 40))
    blurSpinnerView?.alpha = 0.0
    self.view.addSubview(blurSpinnerView!)
    blurSpinnerView?.fadeInWithoutDelay()
  }

  // MARK: Done Button Methods
  @IBAction func onDoneButtonPressed(sender: UIButton) {
  }

  func setDoneSkipButtonText() {
    if CurrentMedCustomerThroughWorkflow.sharedInstance.photoArray!.count == 0 {
      self.skipDoneButton.setTitle("Skip", forState: .Normal)
    } else {
      self.skipDoneButton.setTitle("Done", forState: .Normal)
    }
  }

  // MARK: Photo Preview Methods
  func showPhotoPreview(photo: UIImage) {
    photoPreviewSubview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: super.view.frame.size.width, height: super.view.frame.size.height + 88))

    let darkBlur = UIBlurEffect(style: .Dark)
    let photoReviewBlurView = UIVisualEffectView(effect: darkBlur)
    photoReviewBlurView.frame = CGRect(x: 0.0, y: 0.0, width: (photoPreviewSubview?.bounds.size.width)!, height: (photoPreviewSubview?.bounds.size.height)!)
    photoReviewBlurView.alpha = 1.0
    photoPreviewSubview!.addSubview(photoReviewBlurView)

    let photoImageView : UIImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: photoPreviewSubview!.frame.size.width * 0.8, height: photoPreviewSubview!.frame.size.height * 0.8))
    photoImageView.center = photoPreviewSubview!.center
    photoImageView.contentMode = .ScaleAspectFit
    photoImageView.image = photo
    photoPreviewSubview!.addSubview(photoImageView)

    let hidePhotoPreview = #selector(MedPhotosViewController.hidePhotoPreview)
    let photoPreviewTapGesture = UITapGestureRecognizer(target: self, action: hidePhotoPreview)
    photoPreviewSubview?.userInteractionEnabled = true
    photoPreviewSubview?.addGestureRecognizer(photoPreviewTapGesture)

    photoPreviewSubview!.alpha = 0.0
    self.view.addSubview(photoPreviewSubview!)

    self.navigationController?.setNavigationBarHidden(true, animated: true)

    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.photoPreviewSubview!.alpha = 1.0
      })
  }

  func hidePhotoPreview() {
    self.navigationController?.setNavigationBarHidden(false, animated: true)

    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.photoPreviewSubview!.alpha = 0.0
      }) { Void in
        self.photoPreviewSubview!.removeFromSuperview()
    }
  }
    
  
  // MARK: Unwind to this VC method
  @IBAction func unwindToMedPhotosViewController(segue: UIStoryboardSegue) {
  }

}
