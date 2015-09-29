//*************************************************************************************************
//
//          File:           MachineViewController.swift
//          Project:        BTLEDemo
//          Description:    View controller for screen that shows status of a machine
//
//          Date:           Created by Rob Kerr on 3/28/15.
//          Copyright:      Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//
//**************************************************************************************************
import UIKit
import CoreBluetooth
import RobotRunnerKit

class MachineViewController: UIViewController {
    
    var curPos : UInt8 = 0
    var curTemp : Int = -1
    var timerTXDelay: NSTimer?
    var allowTX = true
    
    var connectedDevice : PeripheralDevice?
    
//    @IBOutlet weak var tempLabel: UILabel!
    
    //*******************************************************************
    //
    //    Function: togglePower
    // Description: User has pressed button to toggle power of the machine
    //
    //*******************************************************************
    /*
    @IBAction func switchChanged(sender: UISwitch) {
        println(__FUNCTION__)
        curTemp = -1
        
        if sender.on {
            setPosition(76)  // 'L' (Lock)
        } else {
            setPosition(85)  // 'U' (Unlock)
        }
        
        
    }
*/

    //*******************************************************************
    //
    //    Function: sendByte
    // Description: Send a byte to the connected machine via BlueTooth LE
    //
    //*******************************************************************
    func setPosition(newPos : UInt8) {
        print(__FUNCTION__)
        if !self.allowTX {
            return
        }
        
        if newPos == curPos {
            return
        }
        
        curPos = newPos
        
        print("Setting servo to \(curPos) degrees")
        
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = sharedBTLEDiscoveryService.peripheralService {
            
            print("Got the service")
            
            bleService.writeByte(newPos)
            
            // Start delay timer
            self.allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerTXDelayElapsed"), userInfo: nil, repeats: false)
            }
        } else {
            print("Oops, we don't have a good service to write to")
        }
    }
    
    //*******************************************************************
    //
    //    Function: timerTXDelayElapsed
    // Description: The timer between data sends has expired
    //
    //*******************************************************************
    func timerTXDelayElapsed() {
        print(__FUNCTION__)
        self.allowTX = true
        self.stopTimerTXDelay()

        // If temp is not available, get it now
        
        if self.curTemp < 0 {
            curTemp = -1; // TODO: this is just a workaround. This temp needs to be send here by the BTService sending bytes to us
            setPosition(84) // 'T' (Temperature)
        }

    }
    
    //*******************************************************************
    //
    //    Function: stopTimerTXDelay
    // Description: Stop the timer that runs between data sends
    //
    //*******************************************************************
    func stopTimerTXDelay() {
        print(__FUNCTION__)
        if self.timerTXDelay == nil {
            return
        }
        
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }

    //*******************************************************************
    //
    //    Function: viewDidLoad
    // Description: called when the view is loaded into memory
    //
    //*******************************************************************
    override func viewDidLoad() {
        print(__FUNCTION__)
        super.viewDidLoad()
    }
    
    //*******************************************************************
    //
    //    Function: viewWillAppear
    // Description: called just before the view is brought onto screen
    //
    //*******************************************************************
    override func viewWillAppear(animated: Bool) {
        print(__FUNCTION__)
        /*
        if let p = connectedDevice?.peripheral {
            sharedBTLEDiscoveryService.connectPeripheral(connectedDevice?.peripheral)
        }
        */
    }
    
    //*******************************************************************
    //
    //    Function: viewWillDisappear
    // Description: called just before the view removed from view
    //              Let's disconnect from the machine now
    //
    //*******************************************************************
    override func viewWillDisappear(animated: Bool) {
        print(__FUNCTION__)

        if let p = connectedDevice?.peripheral {
            sharedBTLEDiscoveryService.disconnectPeripheral(connectedDevice?.peripheral)
        }

    }

    //*******************************************************************
    //
    //    Function: didReceiveMemoryWarning
    // Description: OS is running short on RAM and wants some help
    //
    //*******************************************************************
    override func didReceiveMemoryWarning() {
        print(__FUNCTION__)
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

