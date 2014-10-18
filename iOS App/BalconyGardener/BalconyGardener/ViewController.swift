//
//  ViewController.swift
//  BalconyGardener
//
//  Created by Daniel Peter on 18.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

import UIKit
class MeasurementCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var valueLabel : UILabel?
}

class ViewController: UIViewController, UITableViewDataSource {
    var measureCell: MeasurementCell!
    var sensorValues = Dictionary<String, AnyObject>()
    @IBOutlet weak var tableView: UITableView!
    
    func loadSensorData() {
        var session = NSURLSession.sharedSession()
        // "http://146.0.40.96/balconygardener/service.php?action=sensors"
        let url = NSURL(string: "http://146.0.40.96/balconygardener/service.php?action=getSensorData&count=1")
        session.dataTaskWithURL(url!, completionHandler:didReceiveSensorData).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSensorData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveSensorData( data : NSData!, response: NSURLResponse!, error: NSError! ) {
        var error: NSErrorPointer = nil
        
        println( "data is \(data)" )
        var json : AnyObject? = NSJSONSerialization.JSONObjectWithData( data, options: NSJSONReadingOptions.MutableContainers, error:error )
        if let jsonUnboxed = json as Dictionary<String, AnyObject>? {
            
  ///          sensorValues = jsonUnboxed
            tableView.reloadData()
            
            println( "JSON is \(json)" )
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sensorValues.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeasurementCell", forIndexPath:indexPath ) as UITableViewCell
        cell.textLabel?.text = "Foo"
        cell.detailTextLabel?.text = "Bar"
        cell.backgroundColor = UIColor.yellowColor()
        return cell
    }
    


}

