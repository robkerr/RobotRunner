//
//  MachineTableViewController.swift
//  BLETest
//
//  Created by Rob Kerr on 3/28/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit
import RobotRunnerKit

class MachineTableViewController: UITableViewController, PowerChangeDelegate, BTLERobotPeripheralDelegate {
    
    var curPos : UInt8 = 0
    var curTemp : Int = -1
    var timerTXDelay: NSTimer?
    var allowTX = true
    
    var connectedDevice : PeripheralDevice?
    
    var powerCell : MachinePowerTableViewCell?
    var temperatureCell : MachineTempTableViewCell?
    var lightCell : MachineLightTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(__FUNCTION__)
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Machine control logic
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
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func startMachineCommand() {
        sendByte(65)  // 'A'
    }
    
    func stopMachineCommand() {
        sendByte(66)  // 'B'
    }
    
    func temperatureUpdated(temperature: Int) {
        temperatureCell?.setStat(temperature)
    }
    func lightLevelUpdated(level: Int) {
        lightCell?.setStat(level)
    }
    func machineRunningUpdated(isRunning: Bool) {
        print(__FUNCTION__)
        
        if isRunning == true {
            print("^^^^ Setting robot to running state  ^^^^")
            powerCell?.setRobotRunning()
        }
        else {
            print("^^^^ Setting robot to resting state  ^^^^")
            powerCell?.setRobotStopped()
        }
    }
    func machineSentDataPackage(package: String) {
        print("****** DATA PACKAGE *******")
        print(package)
        print("***************************")
    }
    
    //*******************************************************************
    //
    //    Function: sendByte
    // Description: Send a byte to the connected machine via BlueTooth LE
    //
    //*******************************************************************
    func sendByte(newPos : UInt8) {
        print(__FUNCTION__)
        if !self.allowTX {
            return
        }
        
        if newPos == curPos {
            return
        }
        
        curPos = newPos
        
        print("sending \(curPos) message")
        
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
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell! = nil
        
        switch indexPath.row {
            case 0:
                powerCell = tableView.dequeueReusableCellWithIdentifier("PowerRow", forIndexPath: indexPath) as? MachinePowerTableViewCell
                cell = powerCell
                powerCell?.delegate = self
                break
                
            case 1:
                lightCell = tableView.dequeueReusableCellWithIdentifier("LightRow", forIndexPath: indexPath) as? MachineLightTableViewCell
                cell = lightCell
                break

            default:
                temperatureCell = tableView.dequeueReusableCellWithIdentifier("TemperatureRow", forIndexPath: indexPath) as? MachineTempTableViewCell
                cell = temperatureCell
                break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
