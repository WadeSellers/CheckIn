//
//  QueueTableViewCell.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/10/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit

class QueueTableViewCell: UITableViewCell {

  @IBOutlet weak var typeOfCustomerImageView: UIImageView!
  
  @IBOutlet weak var customerName: UILabel!
  @IBOutlet weak var waitTimeLabel: UILabel!
  @IBOutlet weak var birthdayInfoLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = ColorPalette.getFlowhubGrey()
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyle.None
    self.backgroundColor = ColorPalette.getFlowhubGrey()

    setupCustomerNameLabel()
    setupBirthdayLabel()
    setupWaitTimeLabel()

  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  private func setupBirthdayLabel() {
    birthdayInfoLabel.textColor = UIColor.whiteColor()

  }

  private func setupCustomerNameLabel() {
    customerName.textColor = UIColor.whiteColor()

  }

  private func setupWaitTimeLabel() {
    self.waitTimeLabel.textColor = UIColor.whiteColor()
  }

  internal func configureWaitTimeLabelColorBasedOnMinutes(minutesWaiting: Int) {
    if minutesWaiting > 15 {
      waitTimeLabel.textColor = UIColor.init(red: 151.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    } else {
      waitTimeLabel.textColor = UIColor.whiteColor()
    }
  }



}
