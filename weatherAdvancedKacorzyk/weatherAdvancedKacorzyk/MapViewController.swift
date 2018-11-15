//
//  MapViewController.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 15/11/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var position : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager()
    }
    
    func locationManager() {
        var positionArray = position.components(separatedBy: ",")
        let lat : NSString = positionArray[0] as NSString
        let lng : NSString = positionArray[1] as NSString
        
        let latitude:CLLocationDegrees =  lat.doubleValue
        let longitude:CLLocationDegrees =  lng.doubleValue
        let regionDistance:CLLocationDistance = 10000
        let center = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        //let region = MKCoordinateRegionMakeWithDistance(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01), regionDistance)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        self.mapView.setRegion(region, animated: true)
    }
    
}
