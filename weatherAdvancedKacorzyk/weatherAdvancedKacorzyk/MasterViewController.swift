//
//  MasterViewController.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 18.10.2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import UIKit

class CityCell : UITableViewCell{
    @IBOutlet weak var weather_img: UIImageView!
    @IBOutlet weak var city_name: UITextField!
    @IBOutlet weak var temp_actual: UITextField!
}


class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = Storage.shared.objects
    let doubleFormat = ".2"
    var dayData : [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let locationData = getLocationData(name: "san francisco")
        let newItem = Location(name:  "san francisco", locationData : locationData )
        performSegue(withIdentifier: "showInsert", sender: nil)
        objects.insert(newItem, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            as! CityCell
        
        let city = objects[indexPath.row]
        cell.city_name?.text = city.name
        cell.temp_actual?.text = city.locationData.actualTemp
        cell.weather_img?.image = downloadImage(imgName: city.locationData.imageSign)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func getDayData(location : String) {
        let urlString = "https://www.metaweather.com/api/location/" + location + "/"
        guard let url = URL(string: urlString) else { return }
        var dayData : [[String:Any]] = []
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String:Any]{
                if let weather_data = dictionary["consolidated_weather"] as? [[String:Any]]{
                    dayData = weather_data
                    self.dayData = dayData[0]
                }
            }
            
            }.resume()
    }

    func getLocationNumber(name : String){
        let url : NSString = "https://www.metaweather.com/api/location/search/?query=" + name as NSString
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        URLSession.shared.dataTask(with: searchURL as URL) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [[String:Any]]{
                var location = dictionary[0]
                let locationNumber = location["woeid"] as! Int
                self.getDayData(location: String(locationNumber))
            }
            
            }.resume()
        
    }
    
    func getLocationData(name : String) -> LocationData{
            getLocationNumber(name: name)
            if(self.dayData != nil){
                let locationData = LocationData(actualTemp: ((((dayData["the_temp"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " °C"), imageSign: dayData["weather_state_abbr"] as? String ?? "c")
                return locationData
            }
        return LocationData(actualTemp: "", imageSign: "")
    }
    
    func downloadImage(imgName : String) -> UIImage{
        let urlString = "https://www.metaweather.com/static/img/weather/png/64/" + imgName + ".png"
        guard let url = URL(string: urlString) else { return UIImage()}
        var uimage = UIImage()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            
            uimage = UIImage(data : data) ?? UIImage()
            
            
            }.resume()
        
        return uimage
    }
}
