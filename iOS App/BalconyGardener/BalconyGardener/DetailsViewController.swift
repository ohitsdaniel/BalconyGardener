//
//  DetailsViewController.swift
//  BalconyGardener
//
//  Created by Daniel Peter on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController:UIViewController{

    var sensorIdentifier = ""
    var sensorData = [SensorData]()
    
    private var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url = "http://146.0.40.96/balconygardener/service.php?action=getSensorData&sensorName=\(sensorIdentifier)&count=10"
        var session = NSURLSession.sharedSession()
        let urlNS = NSURL(string: url)
        session.dataTaskWithURL(urlNS, completionHandler:didReceiveSensorData).resume()
    }
    
    func didReceiveSensorData(data : NSData!, response: NSURLResponse!, error: NSError!){
        var error: NSErrorPointer = nil
        
        //   println( "data is \(data)" )
        var json : AnyObject? = NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions.MutableContainers, error:error )
        
        var dict = json as Dictionary<String,AnyObject>
        
        for d in dict{
            var arr:NSArray = d.1 as NSArray
            
            var time:String = ""
            var val:Double = 3
            
            for i in arr{
                val = i.valueForKey("value") as Double
                time = i.valueForKey("time") as NSString
            }
            
            var dataToAdd = SensorData(sensorName: d.0, timeStamp: time, value: val)
            
            println(dataToAdd)
        }
        
    }

}