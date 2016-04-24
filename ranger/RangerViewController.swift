//
//  RangerViewController.swift
//  ranger
//
//  Created by Takashi Wickes on 4/23/16.
//  Copyright © 2016 TrailHacks_Ranger. All rights reserved.
//

import MapKit
import UIKit
import CoreLocation
import CoreBluetooth
import Foundation
import SystemConfiguration


class RangerViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trailNameLabel: UILabel!
    
    @IBOutlet weak var sensorDataLabel: UILabel!
    @IBOutlet weak var markerNumberLabel: UILabel!
    @IBOutlet weak var trailDifficulty: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var conditionView: UIView!
    @IBOutlet weak var conditionIcon: UIImageView!
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    
    
    var trailAttributes: NSDictionary?
    
    let locationManager = CLLocationManager()
    
    var closestBeacon: CLBeacon?
    var activities: [String]?
    var marker: Int = 0
    
    var trailMarkers: [TrailMarker] =
        [TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "St Marks Trail", loop:"", number: 4, difficulty: "", summaryText: "Wow how cool is that thing")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        activitiesCollectionView.delegate = self
        activitiesCollectionView.dataSource = self
        
        self.activitiesCollectionView.pagingEnabled = true
        self.activitiesCollectionView.showsHorizontalScrollIndicator = false
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "98230120-9182-0971-2497-102947102974")!, identifier: "Gimbal")
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        conditionView.layer.cornerRadius = conditionView.frame.width / 5
        conditionIcon.tintColor = UIColor.whiteColor()
        
        
        locationManager.startRangingBeaconsInRegion(region)


        // Do any additional setup after loading the view.
    }
    
    func updateIP(trailName: String, loopName: String) -> NSDictionary {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let loopString: String
        let postEndpoint: NSURL
        
        let trailString = trailName.stringByReplacingOccurrencesOfString(" ", withString: "+")

        if loopName != "" {
            loopString = loopName.stringByReplacingOccurrencesOfString(" ", withString: "+")
            postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Trailname%3D%27\(trailString)%27%3B++Loopname%3D%\(loopString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
        } else {
            loopString = ""
            postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Trailname%3D%27\(trailString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
        }
        
        var trailAttributes: NSDictionary = ["DIFFICULTY" : "A+MESS", "Dictionary": "Collection"]
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: postEndpoint)
        let session = NSURLSession.sharedSession()

        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)

                    if let trails = json["features"] as? [NSDictionary] {
                        trailAttributes = trails[0]["attributes"] as! NSDictionary
//                        print(trailAttributes["TRAILNAME"]!)
                        
                    } else {
                        print("Failed")
                    }

                } catch {
                    print("Error with the JSON")
                }
                print("Everyone is fine, file downloaded successfully.")
            }
        
        
        })
    
        task.resume()
        print("FINISHED")
        print(trailAttributes)
        
        return trailAttributes
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
//        print(beacons)
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {
            var first = false
            if closestBeacon == nil {
                closestBeacon = knownBeacons[0] as CLBeacon
                first = true
                print("Done")
            }
            var markerIdentifier = closestBeacon!.minor.integerValue - 1
            marker = markerIdentifier

            var newBeacon = knownBeacons[0] as CLBeacon
//            print(newBeacon.minor.integerValue-1)
//            print(markerIdentifier)
            if(newBeacon.minor.integerValue-1 != markerIdentifier || first) {

                closestBeacon = knownBeacons[0] as CLBeacon
                markerIdentifier = closestBeacon!.minor.integerValue - 1
                marker = markerIdentifier
                
                if isConnectedToNetwork() {
                
                    var trailName = trailMarkers[markerIdentifier].trailName!
                    var loopName = trailMarkers[markerIdentifier].loopName
                    
                    
                    let loopString: String
                    let postEndpoint: NSURL
                    
                    let trailString = trailName.stringByReplacingOccurrencesOfString(" ", withString: "+")
                    
                    if loopName != "" {
                        loopString = loopName!.stringByReplacingOccurrencesOfString(" ", withString: "+")
                        postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Trailname%3D%27\(trailString)%27%3B++Loopname%3D%\(loopString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
                    } else {
                        loopString = ""
                        postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Trailname%3D%27\(trailString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
                    }
                    
                    let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: postEndpoint)
                    let session = NSURLSession.sharedSession()
                    
                    
                    let task = session.dataTaskWithRequest(urlRequest) {
                        (data, response, error) -> Void in
                        
                        let httpResponse = response as! NSHTTPURLResponse
                        let statusCode = httpResponse.statusCode
                        
                        if (statusCode >= 200 && statusCode < 400) {
                            do {
                                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                                
                                if let trails = json["features"] as? [NSDictionary] {
                                    self.trailAttributes = trails[0]["attributes"] as? NSDictionary
                                    //                        print(trailAttributes["TRAILNAME"]!)
                                    self.trailMarkers[markerIdentifier].trailDifficulty = self.trailAttributes!["DIFFICULTY"] as! String
                                    self.trailMarkers[markerIdentifier].parkName = self.trailAttributes!["PARKNAME"] as! String
                                    self.trailMarkers[markerIdentifier].conditionColor = self.trailAttributes!["TRAILSURFACE"] as! String
                                    print("LKNASD \(self.trailAttributes!["TRAILSURFACE"])")
                                    print(self.trailAttributes!["DIFFICULTY"])
                                    print(self.trailAttributes)
                                    self.activities = nil
                                    for (attribute, data) in self.trailAttributes! {

                                        if String(data) == "Yes" {
                                            if self.activities != nil && String(attribute) != "TRAILHEADS" {
                                                self.activities?.append(
                                                String(attribute))
                                            } else if String(attribute) != "TRAILHEADS" {
                                                self.activities = [String(attribute)]
                                            }

                                        }
                                    }
                                    self.trailMarkers[markerIdentifier].trailActivities = self.activities
                                    
                                    self.activitiesCollectionView.reloadData()
                                    
                                    
                                    
                                } else {
                                    print("Failed")
                                }
                                
                            } catch {
                                print("Error with the JSON")
                            }
                            print("Everyone is fine, file downloaded successfully.")
                            self.activitiesCollectionView.reloadData()
                        }
                    }
                    task.resume()
                    print("FINISHED")
                }
                
                trailNameLabel.text =  trailMarkers[markerIdentifier].trailName
                markerNumberLabel.text = String(trailMarkers[markerIdentifier].markerNumber!)
                summaryLabel.text = trailMarkers[markerIdentifier].summary
                
                sensorDataLabel.text = "Minor value \(closestBeacon!.minor.integerValue)"
                self.activitiesCollectionView.reloadData()

            }
            
            //trailAttributes Updates
            trailDifficulty.text = String(trailMarkers[markerIdentifier].trailDifficulty!)
            loopLabel.text = String(trailMarkers[markerIdentifier].loopName!)
            parkLabel.text = String(trailMarkers[markerIdentifier].parkName!)
            switch trailMarkers[markerIdentifier].conditionColor! {
            case "Water":
                conditionView.backgroundColor = UIColor(red:0.23, green:0.43, blue:0.73, alpha:1.0)
                conditionIcon.image = UIImage(named: "anchor")
                conditionIcon.image = conditionIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                conditionIcon.tintColor = UIColor.whiteColor()
            case "Unpaved":
                conditionView.backgroundColor = UIColor(red:0.09, green:0.7, blue:0.43, alpha:1.0)
                conditionIcon.image = UIImage(named: "leaf")
                conditionIcon.image = conditionIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                conditionIcon.tintColor = UIColor.whiteColor()
            case "Paved":
                conditionView.backgroundColor = UIColor.lightGrayColor()
                conditionIcon.image = UIImage(named: "road")
                conditionIcon.image = conditionIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                conditionIcon.tintColor = UIColor.whiteColor()

            default:
                print("ya")
            }
            self.activitiesCollectionView.reloadData()


        }
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        print("LNASIFNLISANFLINASF \(activities!)")
        if trailMarkers[marker].trailActivities == nil {
            return 0
        } else {
            return trailMarkers[marker].trailActivities!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityIcon", forIndexPath: indexPath) as! ActivitiesCollectionViewCell
        
//        cell.activityIcon.image = UIImage(named: String(UTF8String: activities![indexPath.row])!)
        cell.activityIcon.image = UIImage(named: String(UTF8String: trailMarkers[marker].trailActivities![indexPath.row])!)

        
        cell.activityBack.layer.cornerRadius = cell.activityBack.frame.width / 4
        
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class TrailMarker {
    var trailName: String?
    var loopName: String?
    var parkName: String?
    var markerNumber: Int?
    var trailDifficulty: String?
    var trailColor: UIColor?
    var conditionColor: String?
    var summary: String?
    var markerLocation: CLLocation?
    var trailActivities: [String]?
    
    init(name: String, loop: String, number: Int, difficulty: String, summaryText: String) {


        trailName = name
        loopName = loop
        parkName = ""
        markerNumber = number
        trailDifficulty = difficulty
        summary = summaryText
        trailColor = UIColor(red:0.09, green:0.7, blue:0.43, alpha:1.0)
        conditionColor = "None"
        markerLocation = CLLocation(latitude: 30.434137, longitude: -84.290607)
    }
}
