//
//  Date.swift
//  Robot Runner
//
//  Created by Rob Kerr on 3/15/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import Foundation

class Date {
    
    class func from(year year:Int, month:Int, day:Int) -> NSDate? {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        
        if let gregorian = NSCalendar(identifier:NSCalendarIdentifierGregorian) {
            let date = gregorian.dateFromComponents(c)
            return date
        } else {
            return nil
        }
    }
    
    class func parse(dateStr:String, format:String="yyyy-MM-dd") -> NSDate? {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)
    }
}