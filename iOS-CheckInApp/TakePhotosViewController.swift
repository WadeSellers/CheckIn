//
//  TakePhotosViewController.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 2/15/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class TakePhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var captureSession : AVCaptureSession?
  var stillImageOutput : AVCaptureStillImageOutput?
  var previewLayer : AVCaptureVideoPreviewLayer?
  //var tempImageView : UIImageView?
  var imageTakenByCamera : UIImage?
  var reviewImageView : UIImageView?
  var photoReviewBlurView : UIVisualEffectView?

  var preloadBlurView : UIVisualEffectView?

  @IBOutlet weak var viewForPhotoCapture: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    setupCameraSession()

  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    self.navigationController?.setNavigationBarHidden(true, animated: true)

    previewLayer?.frame = viewForPhotoCapture.bounds

    self.viewForPhotoCapture.hidden = false
  }

  override func viewDidDisappear(animated: Bool) {
    self.reviewImageView?.removeFromSuperview()
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: Setup Camera Session
  func setupCameraSession() {
    captureSession = AVCaptureSession()
    captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080

    let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    do {
      let input = try AVCaptureDeviceInput(device: backCamera)
      captureSession?.addInput(input)
      stillImageOutput = AVCaptureStillImageOutput()
      stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]

      if ((captureSession?.canAddOutput(stillImageOutput)) != nil) {
        captureSession?.addOutput(stillImageOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        viewForPhotoCapture.layer.addSublayer(previewLayer!)

        viewForPhotoCapture.addSubview(createBottomBlurView())

        captureSession?.startRunning()
        //preloadBlurView?.removeFromSuperview()
      }

    } catch let error as NSError {
      print(error)
    }
  }

  // MARK: Create bottom blur View
  func createBottomBlurView() -> UIView {
    let darkBlur = UIBlurEffect(style: .Dark)
    let bottomBlurView = UIVisualEffectView(effect: darkBlur)
    bottomBlurView.frame = CGRect(x: 0.0, y: super.view.frame.height - 112.5, width: super.view.bounds.width + 20, height: 112.5)
    bottomBlurView.alpha = 0.8

    //Setup backToPhotosButton
    let backToPhotosButton = UIButton(type: .System) as UIButton
    backToPhotosButton.frame = CGRect(x: 0.0, y: 0.0, width: bottomBlurView.bounds.width * 0.45, height: bottomBlurView.bounds.height)
    backToPhotosButton.imageView?.contentMode = .ScaleAspectFit
    backToPhotosButton.backgroundColor = UIColor.clearColor()
    backToPhotosButton.setImage(UIImage(named: "backToPhotosIcon") , forState: .Normal)
    backToPhotosButton.tintColor = UIColor.whiteColor()
    let dismissCameraView = #selector(TakePhotosViewController.dismissCameraView)
    backToPhotosButton.addTarget(self, action: dismissCameraView, forControlEvents: UIControlEvents.TouchUpInside)
    bottomBlurView.addSubview(backToPhotosButton)

    //Setup white ring around phototaking button
    let whiteCircle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 63, height: 63))
    whiteCircle.center = CGPoint(x: bottomBlurView.bounds.width/2, y: bottomBlurView.bounds.height/2)
    whiteCircle.layer.cornerRadius = 0.5 * whiteCircle.bounds.size.width
    whiteCircle.layer.borderColor = UIColor.whiteColor().CGColor
    whiteCircle.layer.borderWidth = 3.0
    whiteCircle.backgroundColor = UIColor.clearColor()
    bottomBlurView.addSubview(whiteCircle)

    // Setup the photoTakingButton
    let takePhotoButton = UIButton(type: .Custom) as UIButton
    takePhotoButton.frame = CGRect(x: 0.0, y: 0.0, width: 53, height: 53)
    takePhotoButton.center = CGPoint(x: bottomBlurView.bounds.width/2, y: bottomBlurView.bounds.height/2)
    takePhotoButton.layer.cornerRadius = 0.5 * takePhotoButton.bounds.size.width
    takePhotoButton.backgroundColor = UIColor(red: 104.0/255, green: 113.0/255.0, blue: 130.0/255.0, alpha: 0.8)
    let didPressTakePhoto = #selector(TakePhotosViewController.didPressTakePhoto)
    takePhotoButton.addTarget(self, action: didPressTakePhoto, forControlEvents: UIControlEvents.TouchUpInside)
    bottomBlurView.addSubview(takePhotoButton)
    
    return bottomBlurView
  }

  // Actions
  func didPressTakePhoto() {
    if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
      videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
      stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) in
        if sampleBuffer != nil {
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
          let dataProvider = CGDataProviderCreateWithCFData(imageData)
          let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)

          self.imageTakenByCamera = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)

          self.viewForPhotoCapture.hidden = true

          self.setupPhotoReviewView(self.imageTakenByCamera!)
        }
      })
    }
  }

  func dismissCameraView() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: PhotoReview View
  func setupPhotoReviewView(imageToReview: UIImage) {
    reviewImageView = UIImageView(frame: super.view.frame)
    reviewImageView?.userInteractionEnabled = true
    reviewImageView!.image = imageToReview

    // Setup BlurViewArea
    let darkBlur = UIBlurEffect(style: .Dark)
    photoReviewBlurView = UIVisualEffectView(effect: darkBlur)
    photoReviewBlurView!.frame = CGRect(x: 0.0, y: super.view.frame.height - 112.5, width: super.view.frame.width, height: 112.5)
    photoReviewBlurView!.alpha = 1.0
    reviewImageView!.addSubview(photoReviewBlurView!)

    photoReviewBlurView!.addSubview(createCancelButton())
    photoReviewBlurView!.addSubview(createCancelLabel())
    photoReviewBlurView!.addSubview(createRetakeButton())
    photoReviewBlurView!.addSubview(createRetakeLabel())
    photoReviewBlurView!.addSubview(createAcceptButton())
    photoReviewBlurView!.addSubview(createAcceptLabel())

    self.view.addSubview(reviewImageView!)
  }

  func createCancelButton() -> UIButton {
    let cancelButton = UIButton(type: .Custom) as UIButton
    cancelButton.frame = CGRect(x: 0.0, y: 0.0, width: (photoReviewBlurView?.frame.size.width)!/3, height: (photoReviewBlurView?.frame.size.height)!)
    cancelButton.backgroundColor = UIColor.clearColor()
    cancelButton.setImage(UIImage(named: "iconX") , forState: .Normal)
    cancelButton.tintColor = UIColor.whiteColor()
    cancelButton.userInteractionEnabled = true
    let onCancelTapped = #selector(TakePhotosViewController.onCancelTapped)
    cancelButton.addTarget(self, action: onCancelTapped, forControlEvents: UIControlEvents.TouchUpInside)

    return cancelButton
  }

  func createCancelLabel() -> UILabel {
    let cancelLabel = UILabel(frame: CGRect(x: 18.0, y: 70, width: 69.5, height: 17.9))
    cancelLabel.font = UIFont(name: "helveticaNeue", size: 15.0)
    cancelLabel.textColor = UIColor.whiteColor()
    cancelLabel.textAlignment = .Center
    cancelLabel.text = "Exit"

    return cancelLabel
  }

  func createRetakeButton() -> UIButton {
    let retakeButton = UIButton(type: .System) as UIButton
    retakeButton.frame = CGRect(x: ((photoReviewBlurView?.frame.size.width)!/3), y: 0.0, width: (photoReviewBlurView?.frame.size.width)!/3, height: (photoReviewBlurView?.frame.size.height)!)
    retakeButton.backgroundColor = UIColor.clearColor()
    retakeButton.setImage(UIImage(named: "iconRefresh") , forState: .Normal)
    retakeButton.tintColor = UIColor.whiteColor()
    let onRetakeTapped = #selector(TakePhotosViewController.onRetakeTapped)
    retakeButton.addTarget(self, action: onRetakeTapped, forControlEvents: UIControlEvents.TouchUpInside)

    return retakeButton
  }

  func createRetakeLabel() -> UILabel {
    let retakeLabel = UILabel(frame: CGRect(x: 122.5, y: 70, width: 75.0, height: 17.9))
    retakeLabel.font = UIFont(name: "helveticaNeue", size: 15.0)
    retakeLabel.textColor = UIColor.whiteColor()
    retakeLabel.textAlignment = .Center
    retakeLabel.text = "Retake"

    return retakeLabel
  }

  func createAcceptButton() -> UIButton {
    let acceptButton = UIButton(type: .System) as UIButton
    acceptButton.frame = CGRect(x: (((photoReviewBlurView?.frame.size.width)!/3)*2), y: 0.0, width: (photoReviewBlurView?.frame.size.width)!/3, height: (photoReviewBlurView?.frame.size.height)!)
    acceptButton.backgroundColor = UIColor.clearColor()
    acceptButton.setImage(UIImage(named: "iconCheckMark") , forState: .Normal)
    acceptButton.tintColor = UIColor.whiteColor()
    acceptButton.enabled = true
    let onAcceptTapped = #selector(TakePhotosViewController.onAcceptTapped)
    acceptButton.addTarget(self, action: onAcceptTapped, forControlEvents: UIControlEvents.TouchUpInside)

    return acceptButton
  }

  func createAcceptLabel() -> UILabel {
    let acceptLabel = UILabel(frame: CGRect(x: 229.5, y: 70, width: 69.5, height: 17.9))
    acceptLabel.font = UIFont(name: "helveticaNeue", size: 15.0)
    acceptLabel.textColor = UIColor.whiteColor()
    acceptLabel.textAlignment = .Center
    acceptLabel.text = "Accept"

    return acceptLabel
  }

  // MARK: PhotoReviewView ACTIONS
  func onCancelTapped() {
    dismissCameraView()
  }

  func onRetakeTapped() {
    self.viewForPhotoCapture.hidden = false
    reviewImageView?.removeFromSuperview()
  }

  func onAcceptTapped() {
    self.performSegueWithIdentifier("segueFromTakePhotoToNamePhoto", sender: self)
  }

  // MARK: Prepare for Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "segueFromTakePhotoToNamePhoto" {
      let namePhotoVC : NamePhotoViewController = segue.destinationViewController as! NamePhotoViewController
      namePhotoVC.imageToName = self.imageTakenByCamera!
    }
  }

    // MARK: Unwind to this VC method
  @IBAction func unwindToTakePhotosViewController(segue: UIStoryboardSegue) {
  }

}
