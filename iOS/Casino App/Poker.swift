//
//  Poker.swift
//  Casino App
//
//  Created by Edmund Wong on 04/10/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import Foundation

// MARK: - Payout Details

class Payout{
    var jackpot: String
    var payout: Double
    var card1: String
    var card2: String
    var card3: String
    var card4: String
    var card5: String
    
    init(data: JSON) {
        jackpot = data["jackpot"].stringValue
        payout = data["payout"].doubleValue
        card1 = data["card1"].stringValue
        card2 = data["card2"].stringValue
        card3 = data["card3"].stringValue
        card4 = data["card4"].stringValue
        card5 = data["card5"].stringValue
    }
}

// MARK: - Results

class Results{
    var datetime: Int
    var jackpot: String
    var jackpotAmount: Double
    var score: Double
    var play: Bool

    init(datetime: Int, jackpot: String, jackpotAmount: Double, score: Double, play: Bool){
        self.datetime = datetime
        self.jackpot = jackpot
        self.jackpotAmount = jackpotAmount
        self.score = score
        self.play = play
    }
}

// MARK: - Stat Results

class StatResults{
    var jackpot: String
    var results: Int
    var jackpotAmount: Double
    var detailStats: [DetailStats]

    init(jackpot:String, results:Int, jackpotAmount:Double, detailStats: [DetailStats]){
        self.jackpot = jackpot
        self.results = results
        self.jackpotAmount = jackpotAmount
        self.detailStats = detailStats
    }
}


class DetailStats{
    var datetime: Int
    var jackpotAmount: Double
    
    init(datetime: Int, jackpotAmount: Double){
        self.datetime = datetime
        self.jackpotAmount = jackpotAmount
    }
}

//MARK: - Card Calculation

func cardCalculate(cardHand:[Int]) -> Int{
    
    var cardValue:[Int] = [0,0,0,0,0]
    var cardSymbol:[Int] = [0,0,0,0,0]
    var aceCard:[Int] = [0,0,0,0,0]
    var compareCard:[Bool] = [false,false,false,false,false]
    var aceCompareCard:[Bool] = [false,false,false,false,false]
    
    
    //Define Cards
    for i in 0..<cardHand.count{
        //Card Numbers
        cardValue[i] = ((cardHand[i] - 1) % 13) + 1
        
        //Card Symbols
        cardSymbol[i] = ((cardHand[i] - 1) / 13)
    }

    
    //Sort and Set Cards
    let sortCardValue = cardValue.sorted()
    let setCardValue = Set(cardValue).count
    let setCardSymbol = Set(cardSymbol).count
    
    
    
    //Sort Ace Cards
    if sortCardValue[0] == 1{
        for i in 1..<sortCardValue.count{
            aceCard[i-1] = sortCardValue[i]
        }
        aceCard[4] = 14
    }
    
    
    //Compare Cards for Straight
    for i in 0..<5{
        compareCard[i] = sortCardValue[i] == sortCardValue.min()! + i
        aceCompareCard[i] = aceCard[i] == aceCard.min()! + i
    }
    
    
    //Run Calculation
    switch setCardValue{
    case 2:
        //2 Sets of Numbers
        var count:[Int] = [0,0]
        for i in 0..<setCardValue{
            count[i] = cardValue.filter{$0 == cardValue[i]}.count
        }
        
        if count.max() == 4{
            //Four of a Kind
            return 2
        }else{
            //Full House
            return 3
        }
    
    case 3:
        //3 Sets of Numbers
        var count:[Int] = [0,0,0]
        for i in 0..<setCardValue{
            count[i] = cardValue.filter{$0 == cardValue[i]}.count
        }
        
        if count.max() == 3{
            //Three of a Kind
            return 6
        }else{
            //Two Pairs
            return 7
        }
    
    case 4:
        //4 Sets of Numbers (aka One Pair)
        return 8
        
    default:
        //5 Sets of Numbers - all different numbers
        if aceCompareCard.contains(false){
            //No Royal
            if compareCard.contains(false){
                //No Straight
                if setCardSymbol == 1{
                    //Flush
                    return 4
                }else{
                    //No Flush
                    for i in cardHand{
                        if i == 27{
                            //High Ace
                            return 9
                        }
                    }
                    return 10
                }
            }else{
                //Straight
                if setCardSymbol == 1{
                    //Flush
                    return 2
                }else{
                    //No Flush
                    return 5
                }
            }
        }else{
            //Royal
            if setCardSymbol == 1{
                //Flush
                return 0
            }else{
                //No Flush
                return 5
            }
        }
    }
}


