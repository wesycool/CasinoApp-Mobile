//
//  AccountViewController.swift
//  Casino App
//
//  Created by Edmund Wong on 04/14/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addCreditButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creditLabel: UILabel!
    
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var winRatioLabel: UILabel!
    @IBOutlet weak var winAmountLabel: UILabel!
    @IBOutlet weak var percentRatioLabel: UILabel!
    
    
    var results: [Results]?
    var payout: [Payout]?
    var statResults: [StatResults]?
    var detailStats: [DetailStats]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeOrientation()
        self.setBackgroundColor()
        self.results = self.loadData()
        self.payout = self.loadJSON()

        
        //MARK: - Define Stat Results Detail
        statResults = [StatResults]()
        detailStats = [DetailStats]()
        
        for a in 0..<self.payout!.count{
            let statResult = StatResults(jackpot: self.payout![a].jackpot, results: 0, jackpotAmount: 0, detailStats: [])
            self.statResults?.append(statResult)
        }
        
        
        var countResult: Double? = 0

        for i in 0..<self.results!.count{
            for a in 0..<self.payout!.count{
                switch self.results![i].jackpot{
                case self.payout![a].jackpot:
                    statResults![a].results += 1
                    statResults![a].jackpotAmount += results![i].jackpotAmount
                    
                    let detailStat = DetailStats(datetime: results![i].datetime, jackpotAmount: results![i].jackpotAmount)
                    statResults![a].detailStats.append(detailStat)
                    countResult! += 1
                default:
                    break
                }
            }
        }
        
        
        //MARK: - Define Summary Account
        let totalGame = results!.filter({(stat:Results) -> Bool in return stat.play})
        let percent = Double(countResult!) / Double(totalGame.count) * 100
        
        var winAmount: Double? = 0
        for i in 0..<totalGame.count{
            winAmount! += totalGame[i].jackpotAmount
        }
        
        
        self.creditLabel?.text = String(format: "Current Credit: $%.2f",getBalance())

        self.gameLabel?.text = String(format:"Total Game: %.0f", Double(totalGame.count))
        self.winAmountLabel?.text = String(format:"Win Amount: $%.2f",winAmount!)

        self.winRatioLabel?.text = String(format: "Win Ratio: %.0f : %.0f",Double(countResult!),Double(totalGame.count))
        self.percentRatioLabel?.text = String(format: "Percent Ratio: %.1f%%", percent)
        
    }
    

    //MARK: - Add Credit Button
    @IBAction func addCredit(sender: UIButton){
        self.addCredit()
    }
    

    //MARK: - Data into Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statResults?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell2") as? StatsTableViewCell, let statResultsData = self.statResults?[indexPath.row]{
            
            cell.setResults(results: statResultsData, total: self.results!.filter({ (stat:Results) -> Bool in
                return stat.play
            }).count)
            
            return cell
        }
        return UITableViewCell()
    }
    


    //MARK: - Pass Data using Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsDetailTableView = segue.destination as? StatsDetailTableViewController, let cell = sender as? UITableViewCell, let jackpotIndexPath = self.tableView.indexPath(for: cell), let statResult = statResults?[jackpotIndexPath.row]{
            
            statsDetailTableView.setJackpot(statResult: statResult)
        }
    }

    
    //MARK: - Orientation
    override func viewWillAppear(_ animated: Bool) {
        self.changeOrientation()
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            self.changeOrientation()
        })
    }
    
    
    func changeOrientation(){
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.view.constraints.first(where: {$0.identifier == "tabletop"})?.constant = self.view.frame.size.height * 0.25
            self.view.constraints.first(where: {$0.identifier == "credittop"})?.constant = [self.view.frame.size.height * 0.05,CGFloat(15)].min()!
            
            self.view.constraints.first(where: {$0.identifier == "wintable"})?.constant = 10
            self.view.constraints.first(where: {$0.identifier == "percenttable"})?.constant = 10
            
            self.view.constraints.first(where: {$0.identifier == "wingame"})?.constant = 0
            self.view.constraints.first(where: {$0.identifier == "winpercent"})?.constant = 0
            
        }else{
            self.view.constraints.first(where: {$0.identifier == "tabletop"})?.constant = self.view.frame.size.height * 0.25
            self.view.constraints.first(where: {$0.identifier == "credittop"})?.constant = [self.view.frame.size.height * 0.05,CGFloat(20)].max()!
            
            self.view.constraints.first(where: {$0.identifier == "wintable"})?.constant = self.view.frame.size.height * 0.06
            self.view.constraints.first(where: {$0.identifier == "percenttable"})?.constant = self.view.frame.size.height * 0.06
            
            self.view.constraints.first(where: {$0.identifier == "wingame"})?.constant = self.view.frame.size.height * 0.02
            self.view.constraints.first(where: {$0.identifier == "winpercent"})?.constant = self.view.frame.size.height * 0.02
            
        }
    }
}
