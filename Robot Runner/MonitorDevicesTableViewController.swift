//
//  MonitorDevicesTableViewController.swift
//  Robot Runner
//
//  Created by Rob Kerr on 3/21/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import UIKit
import CoreBluetooth
import RobotRunnerKit

class MonitorDevicesTableViewController: UITableViewController, BTLEDiscoveryDelegate {

    // property that holds the peripherals that have been found by scanning
    var devicesFound : [PeripheralDevice] = [PeripheralDevice]()
    var selectedDevice : PeripheralDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: ServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        sharedBTLEDiscoveryService
        sharedBTLEDiscoveryService.delegate = self
        
        self.view.backgroundColor = UIColor.lightGrayColor()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func sendWebServiceCall(robotName: String) {
        
        let url = NSURL(string: "http://mobiletoolworks.com/testemail5822.php?robot=\(robotName)")
        let request = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if let d = data {
                print(NSString(data: d, encoding: NSUTF8StringEncoding))
            }
        }
    }
    
    func foundPeripheral(peripheral: CBPeripheral, RSSI: NSNumber!) {
        print("@@@@@@@@@@@@  FOUND PERIPHERAL  @@@@@@@@@@@@@@@@@@@@@@")
        
        // Send local notification
        /*
        println("Schedule local notification...")
        
        let app = UIApplication.sharedApplication()
        let notificationSettings = UIUserNotificationSettings(
            forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
            categories: nil)
        app.registerUserNotificationSettings(notificationSettings)
        let alertTime = NSDate().dateByAddingTimeInterval(5)
        let notifyAlarm = UILocalNotification()
        notifyAlarm.fireDate = alertTime
        notifyAlarm.timeZone = NSTimeZone.defaultTimeZone()
        notifyAlarm.soundName = "bell_tree.mp3" //UILocalNotificationDefaultSoundName
        notifyAlarm.alertBody = "Robot named \(peripheral.name) is now in range"
        app.scheduleLocalNotification(notifyAlarm)
        */
        // Send web service call
        sendWebServiceCall(peripheral.name)
        
        // Add to local data structures if necessary
        var bFound : Bool = false
        for b in self.devicesFound {
            if b.peripheral.name == peripheral.name {
                bFound = true
                break
            }
        }
        
        if !bFound {
            self.devicesFound.append(PeripheralDevice(peripheral: peripheral, signalStrength: RSSI.floatValue))
            print(peripheral.name)
            
            if let rssi = RSSI {
                print("\(rssi.floatValue)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
        }
    }
    
    deinit {
        print(__FUNCTION__)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ServiceChangedStatusNotification, object: nil)
    }
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        /*
        let userInfo = notification.userInfo as [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    //               self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
                    println("Bluetooth Connected")
                    
                    // Send current slider position
                    //                    self.sendPosition(UInt8( self.positionSlider.value))
                } else {
                    //                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
                    println("Bluetooth Disconnected")
                    
                }
            }
        });
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesFound.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Peripheral Cell", forIndexPath: indexPath) 

        let robot = self.devicesFound[indexPath.row]
        
        let labelName = cell.viewWithTag(10) as! UILabel
        labelName.text = robot.peripheral.name
        
        let labelModel = cell.viewWithTag(11) as! UILabel
        labelModel.text = "UX-1403"
        
        let labelAssignment = cell.viewWithTag(12) as! UILabel
        labelAssignment.text = "Test Pilot"
        
        let labelSignal = cell.viewWithTag(13) as! UILabel
        labelSignal.text = "\(robot.signalStrength)"

        return cell
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("***********  DID select row ************")

        
        if let row = tableView.indexPathForSelectedRow?.row {
            print("***********  have row ************")
            
            self.selectedDevice = self.devicesFound[row]
            
            print("***********  sending connection request ************")
            
            sharedBTLEDiscoveryService.connectPeripheral(self.selectedDevice?.peripheral)
        }

    }
    
    func peripheralConnected(peripheral: CBPeripheral) {
        print("***********  CALLBACK: peripheralConnected************")
        /*
        self.selectedDevice = nil
        
        for p in devicesFound {
            if p.peripheral == peripheral {
                self.selectedDevice = p
            }
        }
        */
        
        
        if self.selectedDevice != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("ShowDetails", sender: self)
            })
            
        } else {
            print("***********  FATAL: segue not triggered because self.selectedDevice is nil after connection callback fired ************")
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("***********  Preparing for segue ************")
  
        if segue.identifier == "ShowDetails" {
            print("Triggering 'ShowDetails' Segue")
            let nc = segue.destinationViewController as! UINavigationController      // target is a Nav Controler
            let vc = nc.topViewController as! MachineTableViewController           // it's top is the view that will display next
            vc.connectedDevice = self.selectedDevice

            // Set the new view controller as the direct delegate for the peripheral service so it gets data notificaitons
            if let service = sharedBTLEDiscoveryService.peripheralService {
                service.delegate = vc
            }

        }
    }
}
