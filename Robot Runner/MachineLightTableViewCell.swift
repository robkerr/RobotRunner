//
//  MachineLightTableViewCell.swift
//  BLETest
//
//  Created by Rob Kerr on 3/28/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit

class MachineLightTableViewCell: UITableViewCell {

    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var statLabel: UILabel!
    
    var history : [Double] = []
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statLabel.text = ""
        
    }

    func setStat(stat: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            self.statLabel.text = "\(stat)%"
        })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
