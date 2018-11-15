//
//  InsertViewController.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 09/11/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


protocol InsertViewControllerDelegate: class {
    func insertNewCity(cityName: String)
}

class InsertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate{
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    weak var delegate: InsertViewControllerDelegate!
    
    var data : [String] = []
    
    var actualLocation : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
    }
    
    @IBAction func searchCities(_ sender: Any) {
        if(searchText.text != "" && searchText.text != nil){
            getData(name : searchText.text as! String)
        }
    }
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let city = self.data[indexPath.row]
        cell.textLabel?.text = city
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.insertNewCity(cityName: self.data[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func getData(name : String) {
        let url : NSString = "https://www.metaweather.com/api/location/search/?query=" + name as NSString
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        URLSession.shared.dataTask(with: searchURL as URL) { (dataSearch, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let dataSearched = dataSearch else { return }
            
            let json = try? JSONSerialization.jsonObject(with: dataSearched, options: [])
            
            self.data = []
            
            if let dictionary = json as? [[String:Any]]{
                for location in dictionary{
        
                    self.data.append(location["title"] as! String )
                    
                }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            }
            
            }.resume()
        
    }
    
    @IBAction func useActualLocation(_ sender: Any) {
        if(actualLocation != ""){
            getData(name: actualLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        setCityAndCountry(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    func setCityAndCountry(latitude : Double, longitude : Double){
        let longi :CLLocationDegrees = longitude
        let lati :CLLocationDegrees = latitude
        
        let location = CLLocation(latitude: lati, longitude: longi) //changed!!!
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
        
        if error != nil {
            return
        }
        
        if placemarks?.count ?? 0 > 0 {
            let pm = placemarks?[0] as! CLPlacemark
            DispatchQueue.main.async{
                self.locationLabel.text = "Aktualnie znajdujesz się w: " + (pm.locality ?? "") + ", " + (pm.country ?? "")
                if let city = pm.locality {
                    self.actualLocation = city
                }
            }
        }
        else {
            return
        }
        })
    }
    
    
    
}
