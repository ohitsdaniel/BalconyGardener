//
//  DetailsViewController.swift
//  BalconyGardener
//
//  Created by Daniel Peter on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController:UIViewController, UITableViewDataSource {

    var sensorIdentifier = ""
    var sensorData = [SensorData]()
    
    @IBOutlet weak var tableView: UITableView!
    private var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "http://146.0.40.96/balconygardener/service.php?action=getSensorData&sensorName=\(sensorIdentifier)&count=20"
        var session = NSURLSession.sharedSession()
        let url:NSURL?  = NSURL(string: urlString)
        session.dataTaskWithURL(url!, completionHandler:didReceiveSensorData).resume()
    }
    
    func didReceiveSensorData(data : NSData!, response: NSURLResponse!, error: NSError!){
        var error: NSErrorPointer = nil
        
        //   println( "data is \(data)" )
        var json : AnyObject? = NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions.MutableContainers, error:error )
        
         if let d = json as Dictionary<String, AnyObject>? {
        var dict = Dictionary<String, AnyObject>()
            dict = d
        
        for d in dict{
            var arr:NSArray = d.1 as NSArray
            
            var time:String = ""
            var val:Double = 3
            
            for i in arr{
                val = i.valueForKey("value") as Double
                time = i.valueForKey("time") as NSString
                var dataToAdd = SensorData(sensorName: d.0, timeStamp: time, value: val)
                            sensorData.append(dataToAdd)
            }

            
        }
        }
        println(json)
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sensorData.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeasurementCell", forIndexPath:indexPath ) as UITableViewCell
        cell.textLabel?.text = "\(sensorData[indexPath.row].value)"
        cell.detailTextLabel?.text = "\(sensorData[indexPath.row].timeStamp)"
        cell.backgroundColor = UIColor.yellowColor()
        return cell
    }

}