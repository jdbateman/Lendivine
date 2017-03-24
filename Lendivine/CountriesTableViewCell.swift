//
//  CountriesTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 3/12/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This custom table view cell is used in the CountriesTableViewController to display information about a country.

import Foundation
import UIKit

class CountriesTableViewCell: UITableViewCell {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var languages: UILabel!
    @IBOutlet weak var population: UILabel!
    @IBOutlet weak var giniCoefficient: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
