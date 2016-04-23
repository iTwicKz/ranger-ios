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


class RangerViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var sensorDataLabel: UILabel!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        
//        let region = CLBeaconRegion(proximityUUID: NSU, identifier: <#T##String#>)
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "98230120-9182-0971-2497-102947102974")!, identifier: "Gimbal")
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startRangingBeaconsInRegion(region)


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
            let closestBeacon = knownBeacons[0] as CLBeacon
//            print("Beacons \(knownBeacons)")
            print("Major value \(closestBeacon.major.integerValue)")
            print("Minor value \(closestBeacon.minor.integerValue)")
            sensorDataLabel.text = "Minor value \(closestBeacon.minor.integerValue)"

        }
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
