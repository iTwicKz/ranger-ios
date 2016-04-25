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


class RangerViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trailNameLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UIButton!
//    @IBOutlet weak var sensorDataLabel: UILabel!
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
        [TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there", choice: 0),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Dang what a dope tree there", choice: 0),
         TrailMarker(name: "Lafayette Heritage Trail", loop:"East Shared-Use", number: 3, difficulty: "", summaryText: "Lafayette Heritage Trail Park, along with adjacent Tom Brown Park, is bounded on the north by the Lake Lafayette system, stretching from Weems Road to Chaires Cross Road. The park offers visitors a place to fish, exercise, recreate, bicycle, run, walk or just sit and reflect. There are many scenic views and opportunities to view the wildlife. The park entrance is found at the east end of Heritage Park Blvd. in the Piney Z Plantation subdivision. There you will find a small parking lot with 3 picnic shelters, a trailhead and bike wash, a small playground, and restroom. Drinking water is provided at the trailhead and at the playground.", choice: 1),
         TrailMarker(name: "St Marks Trail", loop:"", number: 4, difficulty: "", summaryText: "St. Marks trail is one of the longest trails in Tallahassee, totaling in about 20 miles! It is a paved surface that is often used by cyclists as an option for long rides, since it is paved but away from cars. The trail, if carried on leads to the St. Marks lighthouse down by the south bay in Wakulla county. The most popular place is the main trailhead, which has bathrooms, water fountains, and benches. The route passes by many cool places such as a used goods emporium and a few parks.", choice: 0)]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        activitiesCollectionView.delegate = self
        activitiesCollectionView.dataSource = self
        
        mapView.delegate = self
        
        phoneLabel.backgroundColor = UIColor(red:0.54, green:0.64, blue:0.33, alpha:1.0)

        phoneLabel.layer.cornerRadius = phoneLabel.frame.height / 4
        
        self.activitiesCollectionView.pagingEnabled = true
        self.activitiesCollectionView.showsHorizontalScrollIndicator = false
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "98230120-9182-0971-2497-102947102974")!, identifier: "Gimbal")
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        conditionView.layer.cornerRadius = conditionView.frame.width / 5
        conditionIcon.tintColor = UIColor.whiteColor()
        
        
        locationManager.startRangingBeaconsInRegion(region)
        
        navigationController!.navigationBar.barTintColor = UIColor(red:0.71, green:0.79, blue:0.51, alpha:1.0)


        //        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 17)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        let imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: 50, height: 50))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "face")
        imageView.image = image
        navigationItem.titleView = imageView


        // Do any additional setup after loading the view.
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
                    
                    if loopName == "Main Path"{
                        print("GEARLIAENILNTIANT")
                        loopName = ""
                    }
                    let loopString: String
                    let postEndpoint: NSURL
                    
                    let trailString = trailName.stringByReplacingOccurrencesOfString(" ", withString: "+")
                    
                    if loopName != "" {
                        print("Loooopname \(loopName)")
                        loopString = loopName!.stringByReplacingOccurrencesOfString(" ", withString: "+")
                        postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Loopname%3D%27\(loopString)%27%3B+Trailname+%3D+%27\(trailString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=%7B'wkid'%3A+4326%7D&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
                            
                            
                        
                    } else {
                        trailMarkers[markerIdentifier].loopName = "Main Path"
                        print("JIJISJd")
                        loopString = "Main Path"
                        postEndpoint = NSURL(string:"http://tlcdomi.leoncountyfl.gov/arcgis/rest/services/MapServices/TLCDOMI_FeatureAccess_Trailahassee_D_WM/MapServer/3/query?where=Trailname%3D%27\(trailString)%27&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=%7B'wkid'%3A+4326%7D&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=pjson")!
                    }
                    
                    
                    
                    print(postEndpoint)
                    
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
                            //get attributes of the trail
                                    var trailID = self.trailMarkers[markerIdentifier].trailChoice
                                    
                                    self.trailAttributes = trails[trailID!]["attributes"] as? NSDictionary
                                    //                        print(trailAttributes["TRAILNAME"]!)
                                    self.trailMarkers[markerIdentifier].trailDifficulty = self.trailAttributes!["DIFFICULTY"] as! String
                                    self.trailMarkers[markerIdentifier].parkName = self.trailAttributes!["PARKNAME"] as! String
                                    self.trailMarkers[markerIdentifier].conditionColor = self.trailAttributes!["TRAILSURFACE"] as! String
                                    self.trailMarkers[markerIdentifier].phoneNumber = self.trailAttributes!["CONTACTPHNUM"] as! String
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
                                    
                                //get trail points
                                    var paths = trails[trailID!]["geometry"]!["paths"] as! [[NSMutableArray]]
                                    self.trailMarkers[markerIdentifier].trailCoordinates = paths
//                                    print(pointSet[0]
                                    var latitude = (paths[paths.count/2][0][1]).doubleValue
                                    var longitude = (paths[paths.count/2][0][0]).doubleValue
                                    
                                    let span = MKCoordinateSpanMake(0.07, 0.07)
                                    let region1 = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: span)
                                    self.mapView.setRegion(region1, animated: true)
                                    
                                    
                                    
                                    
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
                
//                sensorDataLabel.text = "Minor value \(closestBeacon!.minor.integerValue)"
                self.activitiesCollectionView.reloadData()

            }
            
            //trailAttributes Updates
            trailDifficulty.text = String(trailMarkers[markerIdentifier].trailDifficulty!)
            loopLabel.text = String(trailMarkers[markerIdentifier].loopName!)
            parkLabel.text = String(trailMarkers[markerIdentifier].parkName!)
            
            
            
//            var paths = trails[0]["geometry"]!["paths"] as! [[NSMutableArray]]
//            self.trailMarkers[markerIdentifier].trailCoordinates = paths
            //                                    print(pointSet[0]
            if self.trailMarkers[markerIdentifier].trailCoordinates != nil {
                var pathsNew = self.trailMarkers[markerIdentifier].trailCoordinates
                var latitude = (pathsNew![pathsNew!.count/2][0][1]).doubleValue
                var longitude = (pathsNew![pathsNew!.count/2][0][0]).doubleValue
                
                let span = MKCoordinateSpanMake(0.07, 0.07)
                let region1 = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: span)
                self.mapView.setRegion(region1, animated: true)
            }
            
            
//            phoneLabel. = "Call Manager \(String(trailMarkers[markerIdentifier].phoneNumber!))"
            
            
            
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
                conditionView.backgroundColor = UIColor(red:0.57, green:0.69, blue:1.0, alpha:1.0)
                conditionIcon.image = UIImage(named: "road")
                conditionIcon.image = conditionIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                conditionIcon.tintColor = UIColor.whiteColor()

            default:
                print("ya")
            }
            self.activitiesCollectionView.reloadData()
            
            if trailMarkers[marker].trailCoordinates != nil {
                var paths = trailMarkers[marker].trailCoordinates
                var latitude = (paths![0][0][1]).doubleValue
                var longitude = (paths![0][0][0]).doubleValue
                
                
                
                //inasifnasinfinaslifnasionfoiZNC
                var pointArray: [CLLocationCoordinate2D] = []
                for index in 0...(paths!.count-1) {
                    for point in paths![index] {
                        var latitude = point[1].doubleValue
                        var longitude = point[0].doubleValue
                        
                        pointArray.append(CLLocationCoordinate2DMake(latitude, longitude))
                    }
                    //                                    var point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
                    //                                    var point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
                    //                                    var point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
                    //                                    var point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
                    //                                    var point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
                    
                    //                                    var points: [CLLocationCoordinate2D]
                    //                                    points = [point1, point2, point3, point4, point5]
                    
//                    print(pointArray)
                    var geodesic = MKPolyline(coordinates: &pointArray[0], count: pointArray.count)
                    self.mapView.addOverlay(geodesic)
                }
                
                
                //                                    UIView.animateWithDuration(1.5, animations: { () -> Void in
                
                //                                    })
                

            }
            
        }
    }
    
    func addingPaths(){
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red:0.35, green:0.76, blue:1.0, alpha:1.0)

            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
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
        cell.activityBack.backgroundColor = UIColor(red:0.71, green:0.79, blue:0.51, alpha:1.0)
        
        
        return cell
    }
    



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        var vc = segue.destinationViewController as! ActivitiesDetailsViewController
        let passList = trailMarkers[marker].trailActivities
        
        vc.passedList = passList
//        vc.userAnswer = chosenOption[sender!.tag].chosen!
        
    }

    @IBAction func callingManager(sender: AnyObject) {
        var phoneNumber = trailMarkers[marker].phoneNumber
        let phoneString = phoneNumber!.stringByReplacingOccurrencesOfString("-", withString: "")

        print(phoneString)
        var url:NSURL = NSURL(string: "tel://\(phoneString)")!
        UIApplication.sharedApplication().openURL(url)
    }
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
    var trailCoordinates: [[NSMutableArray]]?
    var trailChoice: Int?
    var phoneNumber: String?
    
    init(name: String, loop: String, number: Int, difficulty: String, summaryText: String, choice: Int) {
        trailName = name
        loopName = loop
        parkName = ""
        markerNumber = number
        trailDifficulty = difficulty
        summary = summaryText
        trailColor = UIColor(red:0.09, green:0.7, blue:0.43, alpha:1.0)
        conditionColor = "None"
        markerLocation = CLLocation(latitude: 30.434137, longitude: -84.290607)
        trailChoice = choice
    }
}
