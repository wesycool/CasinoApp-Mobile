//
//  PayoutTableViewController.swift
//  Casino App
//
//  Created by Edmund Wong on 04/10/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class PayoutTableViewController: UITableViewController {
    
    var payout:[Payout]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundColor()
        self.payout = self.loadJSON()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payout?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutLanscape") as? PayoutTableViewCell, let payoutData = self.payout?[indexPath.row]{
            cell.setPayout(rulesName: payoutData)

            return cell
        }
            return UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
    
    
}
