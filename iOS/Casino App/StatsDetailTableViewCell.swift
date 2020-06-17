//
//  StatsDetailTableViewCell.swift
//  Casino App
//
//  Created by Edmund Wong on 04/15/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class StatsDetailTableViewCell: UITableViewCell {

    func setDetailStats(detailStats: DetailStats){
        
        let setDate = Date.init(timeIntervalSince1970: TimeInterval(detailStats.datetime))
        let formatDate = DateFormatter()
        formatDate.dateStyle = .medium
        formatDate.timeStyle = .medium
        
        self.textLabel?.text = formatDate.string(from: setDate)
        self.detailTextLabel?.text = String(format:"$%.2f",detailStats.jackpotAmount)
    }

}
