//
//  resultsTableViewCell.swift
//  HealthWatchExample
//
//  Created by Luis Castillo on 2/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

class resultsTableViewCell: UITableViewCell
{

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var heartRateLabel: UILabel!
    
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
