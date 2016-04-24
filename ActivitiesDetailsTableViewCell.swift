//
//  ActivitiesDetailsTableViewCell.swift
//  ranger
//
//  Created by Takashi Wickes on 4/24/16.
//  Copyright © 2016 TrailHacks_Ranger. All rights reserved.
//

import UIKit

class ActivitiesDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var imageBack: UIView!
    @IBOutlet weak var imageDetail: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
