//
//  PhotoTableViewCell.swift
//  iOS-CheckInApp
//
//  Created by Wade Sellers on 2/25/16.
//  Copyright © 2016 Flowhub. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

  @IBOutlet weak var photo: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
