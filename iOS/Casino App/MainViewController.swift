//
//  MainViewController.swift
//  Casino App
//
//  Created by Edmund Wong on 04/11/2020.
//  Copyright © 2020 Edmund Wong. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class MainViewController: UIViewController {

    @IBOutlet weak var pokerImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeOrientation()
        self.setBackgroundColor()
    }
    
 
    //MARK: - Button Behavior
    @IBAction func touchDownButton(sender:UIButton){
        sender.setGradient(colors: blueRButton(), widthSize: sender.frame.size.width, cornerRadius: 20)
        AudioServicesPlaySystemSound(SystemSoundID(1104))
    }
    
    @IBAction func touchUpButton(sender:UIButton){
        sender.setGradient(colors: blueButton(), widthSize: sender.frame.size.width, cornerRadius: 20)
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
            let height = [Double(self.view.frame.size.height) * 0.50, 187.5].min()
            self.pokerImage.constraints.first(where: {$0.identifier == "pokerHeight"})?.constant = CGFloat(height!)
            self.pokerImage.constraints.first(where: {$0.identifier == "pokerWidth"})?.constant = CGFloat(height! / 0.6)
            self.view.constraints.first(where: {$0.identifier == "pokerY"})?.constant = CGFloat(-25)
            self.view.constraints.first(where: {$0.identifier == "startX"})?.constant = CGFloat(-80)
            self.view.constraints.first(where: {$0.identifier == "startY"})?.constant = CGFloat(125)
            self.view.constraints.first(where: {$0.identifier == "accountX"})?.constant = CGFloat(80)
            self.view.constraints.first(where: {$0.identifier == "accountY"})?.constant = CGFloat(125)
        } else {
            let width = [Double(self.view.frame.size.width) * 0.75,281.25].min()
            self.pokerImage.constraints.first(where: {$0.identifier == "pokerWidth"})?.constant = CGFloat(width!)
            self.pokerImage.constraints.first(where: {$0.identifier == "pokerHeight"})?.constant = CGFloat(width! * 0.6)
            self.view.constraints.first(where: {$0.identifier == "pokerY"})?.constant = CGFloat(-80)
            self.view.constraints.first(where: {$0.identifier == "startX"})?.constant = CGFloat(0)
            self.view.constraints.first(where: {$0.identifier == "startY"})?.constant = CGFloat(70)
            self.view.constraints.first(where: {$0.identifier == "accountX"})?.constant = CGFloat(0)
            self.view.constraints.first(where: {$0.identifier == "accountY"})?.constant = CGFloat(150)
        }
        
        self.pokerImage.setLayer(offset: 2)
        self.startButton.setGradient(colors: self.blueButton(), widthSize: startButton.frame.size.width, cornerRadius: 20)
        self.accountButton.setGradient(colors: self.blueButton(), widthSize: accountButton.frame.size.width, cornerRadius: 20)
    }
}



