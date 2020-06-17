//
//  Extension.swift
//  Casino App
//
//  Created by Edmund Wong on 04/16/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    class var background: UIColor{
        return self.init(red: CGFloat(11.0/255.0), green: CGFloat(132.0/255.0), blue: CGFloat(25.0/255.0), alpha: 1)
    }
    
    class var blue1: UIColor{
        return self.init(red: CGFloat(102.0/255.0), green: CGFloat(153.0/255.0), blue: CGFloat(255.0/255.0), alpha: 1)
    }
    
    class var blue2: UIColor{
        return self.init(red: CGFloat(0.0/255.0), green: CGFloat(102.0/255.0), blue: CGFloat(255.0/255.0), alpha: 1)
    }
}


extension UIViewController{
    
    // MARK: - Set Background Color
    func setBackgroundColor(){
        view.backgroundColor = .background
    }
    
    
    // MARK: - Load and Save Results Data
    func getDataFilePath() -> String? {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let filePath = documentPath.appending("/pokerdata.txt")
        return filePath
    }
    
    
    func loadData() -> [Results]?{
        var results: [Results]?
        results = [Results]()
        guard let filePath = self.getDataFilePath() else{
            return results
        }
        print(filePath)
        
        do{
            let text = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines : [String] = text.components(separatedBy: "\n")
            for i in 0..<lines.count-1{
                let element = lines[i].components(separatedBy: ", ")
                let result = Results(datetime: Int(element[0])! , jackpot: element[1], jackpotAmount: Double(element[2])!, score: Double(element[3])!, play: Bool(element[4])!)
                results?.append(result)
            }
        }catch{
        }
        return results
    }
    
    
    func saveData(_ results: [Results]){
        guard let filePath = self.getDataFilePath() else{
            return
        }
        var saveString = ""
        
        for result in results {
            saveString = saveString + "\(result.datetime), \(result.jackpot), \(result.jackpotAmount), \(result.score), \(result.play)\n"
        }
        
        do {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
        }catch{
        }
    }
    
    
    //MARK: - Parse & Load JSON
    func loadJSON() -> [Payout]?{
        if let file = Bundle(for: AppDelegate.self).path(forResource: "poker", ofType: "json"), let data = NSData(contentsOfFile: file) as Data?{
            
            let jsonData = JSON(data: data)
            return self.parseJSON(json: jsonData)
        }
        return []
    }
    
    
    func parseJSON(json:JSON) -> [Payout]?{
        var payout:[Payout]?
        payout = [Payout]()
        let payoutDataArray = json["poker"].arrayValue
        
        for payoutData in payoutDataArray{
            payout?.append(Payout(data: payoutData))
        }
        return payout
    }
    
    
    //MARK: - Add Credit & Get Balance
    func getBalance() -> Double{
        let results = loadData()
        var balance: Double
        
        if results?.count != 0{
            balance = results![results!.count-1].score
        }else{
            balance = 0
        }
        return balance
    }
    
    
    func addCredit(){
        var results: [Results]?
        results = self.loadData()
        
        let title = "Purchasing Credit"
        let current = String(format:"Current balance: $%.2f",self.getBalance())
        
        let alert = UIAlertController(title: title, message: current, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in

            let credit = Double(alert.textFields![0].text!)!
            let newBalance = credit + self.getBalance()
            let creditMessage = String(format: "Confirm to add credit of $%.2f", credit)
            let newBalanceMessage = String(format:"New balance: $%.2f", newBalance)
            
            
            let alert2 = UIAlertController(title: title, message: "\(creditMessage)\n\(current)\n\(newBalanceMessage)", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                
                let result = Results(datetime: Int(Date().timeIntervalSince1970), jackpot: "Add Credit", jackpotAmount: Double(String(format:"%.2f",credit))!, score: Double(String(format:"%.2f",newBalance))!, play: false)
                results?.append(result)
                self.saveData(results!)
                self.viewDidLoad()
            })
            
            alert2.addAction(confirmAction)
            alert2.addAction(cancel)
            self.present(alert2, animated: true, completion: nil)
        })
        

        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
            textField.autocorrectionType = .no
            textField.placeholder = "How much credit to add?"
            textField.clearButtonMode = .whileEditing
        }
        
        
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Button Colors
    func blueButton() -> [UIColor]{
        return [.blue1,.blue2]
    }
    
    func blueRButton() -> [UIColor]{
        return [.blue2,.blue1]
    }
    
    func blackButton() -> [UIColor]{
        return [.lightGray,.black]
    }
    
    func blackRButton() -> [UIColor]{
        return [.black,.lightGray]
    }
}


extension UIView {
    
    // MARK: - Set Gradient and Round Corner
    func setGradient(colors: [UIColor], widthSize: CGFloat, cornerRadius: CGFloat) {
        
        if layer.sublayers != nil{
            layer.sublayers?.remove(at: 0)
        }
        
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 1
        layer.cornerRadius = cornerRadius
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: widthSize, height: bounds.size.height)
        gradientLayer.colors = [colors[0].cgColor, colors[1].cgColor]
        gradientLayer.borderColor = layer.borderColor
        gradientLayer.borderWidth = layer.borderWidth
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)

    }
    
    func setLayer(offset:CGFloat) {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: offset, height: offset)
        layer.shadowRadius = 1
        layer.shadowOpacity = 1
    }
}


