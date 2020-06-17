//
//  PokerViewController.swift
//  Casino App
//
//  Created by Edmund Wong on 04/09/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class PokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{


    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var addCreditButton: UIButton!
    
    @IBOutlet weak var cardImage1: UIImageView!
    @IBOutlet weak var cardImage2: UIImageView!
    @IBOutlet weak var cardImage3: UIImageView!
    @IBOutlet weak var cardImage4: UIImageView!
    @IBOutlet weak var cardImage5: UIImageView!
    
    @IBOutlet weak var bet1Button: UIButton!
    @IBOutlet weak var bet5Button: UIButton!
    @IBOutlet weak var bet10Button: UIButton!
    @IBOutlet weak var bet50Button: UIButton!
    @IBOutlet weak var betLabel: UILabel!
    
    @IBOutlet weak var rulesLabel: UILabel!
    @IBOutlet weak var payoutButton: UIButton!
    
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var jackpotLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var audioPlayer = AVAudioPlayer()
    
    var payout:[Payout]?
    var results:[Results]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.results = self.loadData()
        self.payout = self.loadJSON()
        
        self.changeOrientation()
        self.setBackgroundColor()
        
        self.winLabel?.isHidden = true
        self.jackpotLabel?.isHidden = true

        self.scoreLabel?.text = String(format: "Credit: $%.2f",getBalance())
        self.setButton()
    }
    

    
    @IBAction func playTapped(sender:UIButton){
        let timeNow = Date().timeIntervalSince1970
        
        let betMultiply = sender.titleLabel?.text?.split(separator: "x")
        let betAmount = Double(betMultiply![1])! * 0.30
        betLabel.text = String(format: "Bet: $%.2f", betAmount)
        
        let scoreAmount = scoreLabel?.text?.split(separator: "$")
        let newScoreAmount = Double(scoreAmount![1])! - betAmount
        scoreLabel.text = String(format: "Credit: $%.2f",newScoreAmount)
        
        winLabel?.isHidden = true
        jackpotLabel?.isHidden = true
        
        
        for i in 0..<4{
            let buttonEnable = self.view.viewWithTag(i+1) as! UIButton
            buttonEnable.isEnabled = false
            buttonEnable.alpha = 0.5
            
            let cardReset = view.viewWithTag(i+10) as! UIImageView
            cardReset.image = UIImage(named: "card0.jpg")
        }
        
        
        //MARK: - Get Random Cards
        var cardHand:[Int] = [0,0,0,0,0]
        
        for i in 0..<cardHand.count{
            var randomCard:Int = 0
            var cardString:String = ""
            
            while(cardHand.contains(randomCard)){
                randomCard = Int(arc4random_uniform(52))+1
                cardString = String(format: "card%i.jpg",randomCard)
            }

            let cardFlip = view.viewWithTag(i+10) as! UIImageView
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i)+1)*0.1) {
                cardFlip.image = UIImage(named: cardString)
            }

            cardHand[i] = randomCard
        }
        
        
        //MARK: - Calculate Jackpot
        let payoutAmount = cardCalculate(cardHand: cardHand)
        var jackpotAmount:Double
        
        if payoutAmount != 10 {
            let jackpotName = self.payout?[payoutAmount].jackpot
            let jackpotMultiply = self.payout?[payoutAmount].payout
            jackpotAmount = betAmount * jackpotMultiply!
            self.jackpotLabel?.text = jackpotName
            var scoreIncrease = newScoreAmount
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                AudioServicesPlaySystemSound(SystemSoundID(1025))
                self.winLabel?.isHidden = false
                self.jackpotLabel?.isHidden = false
                
                var counter = jackpotAmount * 100
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){ timer in
                    counter += -1
                    scoreIncrease += 0.01
                    self.scoreLabel.text = String(format: "Credit: $%.2f",scoreIncrease)
                    if counter == 0 {
                        timer.invalidate()
                    }
                }
            }
        }else{
            jackpotAmount = 0
            self.jackpotLabel?.text = "No Win"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                AudioServicesPlaySystemSound(SystemSoundID(1024))
            }
        }
        
        
        //MARK: - Save Result
        let saveScore = newScoreAmount + jackpotAmount
        let result = Results(datetime: Int(timeNow), jackpot: self.jackpotLabel!.text!,jackpotAmount: jackpotAmount, score: Double(String(format:"%.2f",saveScore))!, play: true)
        self.results?.append(result)
        self.saveData(self.results!)

        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(Int(jackpotAmount*1000)) + 0.9){
            self.setButton()
        }
    }
    
    
    //MARK: - Add Credit Button
    @IBAction func addCredit(sender: UIButton){
        self.addCredit()
    }
    
    
    //MARK: - Payout TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payout?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutPortrait") as? PayoutTableViewCell, let payoutData = self.payout?[indexPath.row]{
            cell.setPayout(rulesName: payoutData)

            return cell
        }
        return UITableViewCell()
    }
    
    
    //MARK: - Enable/Disable Buttons
    func setButton(){
        let scoreNumber = scoreLabel.text?.split(separator: "$")
        
        for i in 0..<4{
            let buttonEnable = self.view.viewWithTag(i+1) as! UIButton
            let betMultiply = buttonEnable.titleLabel?.text?.split(separator: "x")
            
            if (Double(scoreNumber![1])! < Double(betMultiply![1])! * 0.30){
                buttonEnable.isEnabled = false
                buttonEnable.alpha = 0.5
            }else{
                buttonEnable.isEnabled = true
                buttonEnable.alpha = 1
            }
        }
    }
    
    
    //MARK: - Button Behavior
    @IBAction func tappedDown(sender:UIButton){
        sender.setGradient(colors:blackRButton(), widthSize: widthSize(), cornerRadius: 15)
    }
    
    
    @IBAction func tappedup(sender: UIButton){
        sender.setGradient(colors: blackButton(), widthSize: widthSize(), cornerRadius: 15)
    }
    
    
    @IBAction func tappedSound(sender: UIButton){
        AudioServicesPlaySystemSound(SystemSoundID(1021))
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
            self.view.constraints.first(where: {$0.identifier == "bet50payout"})?.constant = 10
            self.payoutButton.isHidden = false
            self.rulesLabel.isHidden = true
            self.tableView.isHidden = true
            self.jackpotLabel.font = self.jackpotLabel.font.withSize(25)
            self.jackpotLabel.constraints.first(where: {$0.identifier == "height50"})?.constant = 50
            
        } else {
            self.view.constraints.first(where: {$0.identifier == "bet50payout"})?.constant = -(self.view.frame.size.width - 80)/4
            self.payoutButton.isHidden = true
            self.rulesLabel.isHidden = false
            self.tableView.isHidden = false
            self.jackpotLabel.font = self.jackpotLabel.font.withSize(17)
            self.jackpotLabel.constraints.first(where: {$0.identifier == "height50"})?.constant = 20
        }

        
        for i in 0..<5{
            let button = self.view.viewWithTag(i+1) as! UIButton
            let card = view.viewWithTag(i+10) as! UIImageView
            
            button.setGradient(colors:blackButton(), widthSize: widthSize(), cornerRadius: 15)
            card.setLayer(offset: 5)
        }
    }
    
    
    func widthSize() -> CGFloat{
        var widthSize: CGFloat
        let screen = view.frame.size.width - (UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.safeAreaInsets.left)! - (UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.safeAreaInsets.right)!
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            widthSize = (screen - 90)/5
        }else{
            widthSize = (screen - 80)/4
        }
        return widthSize
    }

    
}


