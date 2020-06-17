//
//  StatsDetailTableViewController.swift
//  Casino App
//
//  Created by Edmund Wong on 04/15/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class StatsDetailTableViewController: UITableViewController {
    
    var detailStats: [DetailStats]?
    
    
    func setJackpot(statResult: StatResults){
        self.setBackgroundColor()
        self.detailStats = statResult.detailStats
        self.navigationItem.title = statResult.jackpot
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailStats?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DetailStatsCell") as? StatsDetailTableViewCell, let detailStatsData = self.detailStats?[(self.detailStats!.count-1) - indexPath.row ]{
            cell.setDetailStats(detailStats: detailStatsData)
            return cell
        }
        return UITableViewCell()
    }

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }


}
