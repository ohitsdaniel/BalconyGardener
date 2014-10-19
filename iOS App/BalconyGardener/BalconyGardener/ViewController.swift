//
//  ViewController.swift
//  BalconyGardener
//
//  Created by Daniel Peter on 18.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

import UIKit
import SpriteKit

class MeasurementCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var valueLabel : UILabel?
}

class ViewController: UIViewController, UITableViewDataSource {
    var measureCell: MeasurementCell!
    var sensorValues = Dictionary<String, AnyObject>()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var waterSignalSentText: UILabel!

    private var sensorValueArr = [SensorData]()
    
    func loadSensorData() {
        var session = NSURLSession.sharedSession()
        // "http://146.0.40.96/balconygardener/service.php?action=sensors"
        let url:NSURL? = NSURL(string: "http://146.0.40.96/balconygardener/service.php?action=getSensorData&count=1")
        session.dataTaskWithURL(url!, completionHandler:didReceiveSensorData).resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSensorData()
        
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "loadSensorData", userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func waterButtonPushed(sender: AnyObject) {
        var session = NSURLSession.sharedSession()
        let url:NSURL? = NSURL(string: "http://146.0.40.96/balconygardener/service.php?action=waterPlant&duration=10")
        session.dataTaskWithURL(url!).resume()
        
        waterSignalSentText.hidden = false
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "hideWaterText", userInfo: nil, repeats: false)
        
    }
    
    func hideWaterText(){
        waterSignalSentText.hidden = true
    }
    
    
    func didReceiveSensorData( data : NSData!, response: NSURLResponse!, error: NSError! ) {
        var error: NSErrorPointer = NSErrorPointer()
        
        // println( "data is \(data)" )
        var json : AnyObject? = NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions.MutableContainers, error:error )
        
        if let jsonUnboxed = json as Dictionary<String, AnyObject>? {
            
            sensorValues = jsonUnboxed
            
            for x in sensorValues{
                var arr:NSArray = x.1 as NSArray
                
                var time:String = ""
                var val:Double = 3
                
                for i in arr{
                    val = i.valueForKey("value") as Double
                    time = i.valueForKey("time") as NSString
                }
                
                var dataToAdd = SensorData(sensorName: x.0, timeStamp: time, value: val)
                
                sensorValueArr.append(dataToAdd)
            }
            
            tableView.reloadData()
            
         //   println( "JSON is \(json)" )
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sensorValues.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeasurementCell", forIndexPath:indexPath ) as UITableViewCell
        cell.textLabel?.text = "\(sensorValueArr[indexPath.row].value)"
        cell.detailTextLabel?.text = "\(sensorValueArr[indexPath.row].sensorName)"
        cell.backgroundColor = UIColor.yellowColor()
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "details" {
            (segue.destinationViewController as DetailsViewController).sensorIdentifier = "\(tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow()!)!.detailTextLabel!.text!)"
        }
        
        if segue.identifier == "detail" {
            (segue.destinationViewController as BCPlotViewController).sensorIdentifier = "\(tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow()!)!.detailTextLabel!.text!)"
        }
    }

}

struct SensorData{
    let sensorName:String
    let timeStamp:String
    let value:Double
}
    