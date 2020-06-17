//
//  StatsTableViewCell.swift
//  Casino App
//
//  Created by Edmund Wong on 04/14/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var jackpotLabel: UILabel!
    @IBOutlet weak var jackpotAmountLabel: UILabel!
    @IBOutlet weak var winRatioLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    
    func setResults(results: StatResults, total: Int){
        
        let percent = Double(results.results) / Double(total) * 100
        self.jackpotLabel?.text = results.jackpot
        self.jackpotAmountLabel?.text = String(format: "Total Amount: $%.2f",results.jackpotAmount)
        self.winRatioLabel?.text = "Win Ratio: \(results.results) : \(total)"
        self.percentLabel?.text = String(format: "Percent Ratio: %0.1f%%", percent)
    }
}
