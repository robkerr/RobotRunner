//
//  RobotStatusStore.swift
//  Robot Runner
//
//  Created by Rob Kerr on 4/25/15.
//  Copyright (c) 2015 Mobile Toolworks LLC. All rights reserved.
//

import Foundation

private let kFileName = "Robots"
private let kFileExtension = "json"
private let kAppGroupIdentifier = "group.com.mobiletoolworks.robotrunner.documents"

public class RobotStatusStore {

    public init() {
        
    }
    
    public func getRobotStatus() -> (running: Bool?, temp: Double?, lightLevel: Double?) {
        
        var running : Bool = false
        var temp : Double = 0.0
        var lightLevel : Double = 0.0
        
        // Get the robot current status from shared user default store
        if let sharedUserDefaults = NSUserDefaults(suiteName: kAppGroupIdentifier) {

            running = sharedUserDefaults.boolForKey("RobotIsRunning")
            temp = sharedUserDefaults.doubleForKey("RobotTemp")
            lightLevel = sharedUserDefaults.doubleForKey("RobotLightLevel")
            
        }
        
        // Return the defaults
        return (running, temp, lightLevel)
    }
    
    public func setRobotStatus(running: Bool, temp: Double, lightLevel: Double) {
        
        // Get the robot current status from shared user default store
        if let sharedUserDefaults = NSUserDefaults(suiteName: kAppGroupIdentifier) {

            sharedUserDefaults.setBool(running, forKey: "RobotIsRunning")
            sharedUserDefaults.setDouble(temp, forKey: "RobotTemp")
            sharedUserDefaults.setDouble(lightLevel, forKey: "RobotLightLevel")
        }
    }
}