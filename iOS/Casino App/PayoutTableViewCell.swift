//
//  PayoutTableViewCell.swift
//  Casino App
//
//  Created by Edmund Wong on 04/10/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit

class PayoutTableViewCell: UITableViewCell {


    @IBOutlet weak var multiplyLabel: UILabel!
    @IBOutlet weak var card1Image: UIImageView!
    @IBOutlet weak var card2Image: UIImageView!
    @IBOutlet weak var card3Image: UIImageView!
    @IBOutlet weak var card4Image: UIImageView!
    @IBOutlet weak var card5Image: UIImageView!
    
    
    func setPayout(rulesName: Payout){
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        self.textLabel?.text = rulesName.jackpot
        self.detailTextLabel?.text = "x" + numberFormatter.string(from: NSNumber(value: rulesName.payout))!
        self.multiplyLabel?.text = "x" + numberFormatter.string(from: NSNumber(value: rulesName.payout))!

        self.card1Image?.image = UIImage(named: rulesName.card1+".jpg")
        self.card2Image?.image = UIImage(named: rulesName.card2+".jpg")
        self.card3Image?.image = UIImage(named: rulesName.card3+".jpg")
        self.card4Image?.image = UIImage(named: rulesName.card4+".jpg")
        self.card5Image?.image = UIImage(named: rulesName.card5+".jpg")
    }
    
    
    func setImageHidden(bool: Bool){
        self.card1Image?.isHidden = bool
        self.card2Image?.isHidden = bool
        self.card3Image?.isHidden = bool
        self.card4Image?.isHidden = bool
        self.card5Image?.isHidden = bool
    }
    
}
