//
//  MachinePowerTableViewCell.swift
//  BLETest
//
//  Created by Rob Kerr on 3/28/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit

// Delegate methods that notify the controller of user commands
protocol PowerChangeDelegate {
    func startMachineCommand()
    func stopMachineCommand()
}


class MachinePowerTableViewCell: UITableViewCell {

    var delegate : PowerChangeDelegate?
    
    @IBOutlet weak var animiation: UIImageView!
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var runningStatus: UILabel!

    var startingImages : [UIImage] = []
    var runningImages : [UIImage] = []
    var stoppingImages : [UIImage] = []

    var currentState : Int = 0      // 0 = stopped, 1 = running
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animiation.image = UIImage(named: "RobotAnimation/Starting/StartingRobot1.png")
    }
    

    func initImages() {
        
        startingImages.removeAll(keepCapacity: false)
        runningImages.removeAll(keepCapacity: false)
        stoppingImages.removeAll(keepCapacity: false)
        
        for i in 1...6 {
            let s : String = NSString(format: "RobotAnimation/Starting/StartingRobot%d.png", i) as String
            startingImages.append(UIImage(named: s)!)
        }
        
        for i in 1...35 {
            let s : String = NSString(format: "RobotAnimation/Running/RunningRobot%d.png", i) as String
            runningImages.append(UIImage(named: s)!)
        }

        for i in 1...7 {
            let s : String = NSString(format: "RobotAnimation/Stopping/StoppingRobot%d.png", i) as String
            stoppingImages.append(UIImage(named: s)!)
        }
    }

    
    @IBAction func powerButtonPressed(sender: AnyObject) {
        print(__FUNCTION__)

        if startingImages.count == 0 {
            initImages()
        }

        if currentState == 0 {
            startRobot()
        }
        else {
            stopRobot()
        }
    }
    
    func startRobot() {
        print(__FUNCTION__)
        
        runningStatus.text = "Robot Starting"
        powerButton.imageView?.image = UIImage(named: "PowerGray")

        animiation.image = UIImage(named: "RobotAnimation/Starting/StartingRobot7.png")
        animiation.animationImages = startingImages
        animiation.animationRepeatCount = 1
        animiation.animationDuration = 0.5
        animiation.startAnimating()
        
        // use GCD to set stopped status after animation is over
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animiation.animationDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            
            self.setRobotRunning()

            if let d = self.delegate {
                d.startMachineCommand()
            }
        })
    }
    
    func stopRobot() {
        print(__FUNCTION__)

        runningStatus.text = "Robot Stopping"
        powerButton.imageView?.image = UIImage(named: "PowerGray")
        
        animiation.image = UIImage(named: "RobotAnimation/Stopping/StoppingRobot7.png")
        animiation.animationImages = stoppingImages
        animiation.animationRepeatCount = 1
        animiation.animationDuration = 0.5
        animiation.startAnimating()

        // use GCD to set stopped status after animation is over
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animiation.animationDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            
            self.setRobotStopped()
            
            if let d = self.delegate {
                d.stopMachineCommand()
            }
        })
        

    }

    func setRobotRunning() {
        print(__FUNCTION__)
        currentState = 1
        
        dispatch_async(dispatch_get_main_queue(), {
            self.runningStatus.text = "Robot Running"
            self.powerButton.imageView?.image = UIImage(named: "PowerRed")

            if !self.animiation.isAnimating() {
                self.animiation.animationImages = self.runningImages
                self.animiation.animationRepeatCount = 0
                self.animiation.animationDuration = 4.0
                self.animiation.startAnimating()
            }
        })
    }

    func setRobotStopped() {
        print(__FUNCTION__)
        currentState = 0
        
        dispatch_async(dispatch_get_main_queue(), {
            self.runningStatus.text = "Robot Resting"
            self.powerButton.imageView?.image = UIImage(named: "PowerGreen")
            
            if !self.animiation.isAnimating() {
                self.animiation.image = UIImage(named: "RobotAnimation/Starting/StartingRobot1.png")
            }
        })
    }
    
}
