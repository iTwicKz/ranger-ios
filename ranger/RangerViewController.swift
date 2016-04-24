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


class RangerViewController: UIViewController, CLLocationManagerDelegate {

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
    
    var trailAttributes: NSDictionary?
    
    let locationManager = CLLocationManager()
    
    var closestBeacon: CLBeacon?
    
    var trailMarkers: [TrailMarker] =
        [TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there"),
         TrailMarker(name: "Aucilla River Paddling Trail", loop:"", number: 4, difficulty: "", summaryText: "Wow how cool is that thing")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
//        let region = CLBeaconRegion(proximityUUID: NSU, identifier: <#T##String#>)
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "98230120-9182-0971-2497-102947102974")!, identifier: "Gimbal")
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        conditionView.layer.cornerRadius = conditionView.frame.height / 2
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

            var newBeacon = knownBeacons[0] as CLBeacon
            print(newBeacon.minor.integerValue-1)
            print(markerIdentifier)
            if(newBeacon.minor.integerValue-1 != markerIdentifier || first) {

                closestBeacon = knownBeacons[0] as CLBeacon
                markerIdentifier = closestBeacon!.minor.integerValue - 1

    //            print("Beacons \(knownBeacons)")
    //            print("Major value \(closestBeacon.major.integerValue)")
    //            print("Minor value \(closestBeacon.minor.integerValue)")
                
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

                                    
                                } else {
                                    print("Failed")
                                }
                                
                            } catch {
                                print("Error with the JSON")
                            }
                            print("Everyone is fine, file downloaded successfully.")
                        }
                        
                        
                    }
                    
                    task.resume()
                    print("FINISHED")
                }
                
                trailNameLabel.text =  trailMarkers[markerIdentifier].trailName
                markerNumberLabel.text = String(trailMarkers[markerIdentifier].markerNumber!)
                summaryLabel.text = trailMarkers[markerIdentifier].summary
  
                
                sensorDataLabel.text = "Minor value \(closestBeacon!.minor.integerValue)"
            }
            
            //trailAttributes Updates
            trailDifficulty.text = String(trailMarkers[markerIdentifier].trailDifficulty!)
            loopLabel.text = String(trailMarkers[markerIdentifier].loopName!)
            parkLabel.text = String(trailMarkers[markerIdentifier].parkName!)
            print(trailMarkers[markerIdentifier].conditionColor!)
            switch trailMarkers[markerIdentifier].conditionColor! {
            case "Water":
                conditionView.backgroundColor = UIColor(red:0.09, green:0.7, blue:0.43, alpha:1.0)
                conditionIcon.image = UIImage(named: "anchor")
            case "Unpaved":
                conditionView.backgroundColor = UIColor.greenColor()
                conditionIcon.image = UIImage(named: "leaf")
            default:
                print("ya")
            }


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
