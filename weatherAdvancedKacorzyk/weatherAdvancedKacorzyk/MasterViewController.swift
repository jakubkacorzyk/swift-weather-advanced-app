//
//  MasterViewController.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 18.10.2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import UIKit

class CityCell : UITableViewCell {
    
    @IBOutlet weak var weather_img: UIImageView!
    @IBOutlet weak var city_name: UILabel!
    @IBOutlet weak var temp_actual: UILabel!
}


class MasterViewController: UITableViewController,InsertViewControllerDelegate{
    
    var detailViewController: DetailViewController? = nil
    var objects = Storage.shared.objects
    let doubleFormat = ".2"
    var dayData : [String:Any] = [:]
    var citiesAtStart = ["San Francisco","London","Warsaw"]
    
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
        
        for city in citiesAtStart{
            getLocationNumber(name: city)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "showInsert", sender: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.title = object.name
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "showInsert" {
            let controller = segue.destination as! InsertViewController
            controller.delegate = self
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
        cell.weather_img?.image = city.locationData.img
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
    
    func getDayData(location : String, name : String) {
        let url : NSString = "https://www.metaweather.com/api/location/" + location + "/"  as NSString
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        var dayData : [[String:Any]] = []
        URLSession.shared.dataTask(with: searchURL as URL) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String:Any]{
                if let weather_data = dictionary["consolidated_weather"] as? [[String:Any]]{
                    dayData = weather_data
                    self.downloadImage(dayData: dayData[0], name : name)
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
                self.getDayData(location: String(locationNumber), name : name)
            }
            
            }.resume()
        
    }
    
    func downloadImage(dayData : [String:Any], name : String){
        let imgSign = dayData["weather_state_abbr"] as? String ?? "c"
        let url : NSString = "https://www.metaweather.com/static/img/weather/png/64/" + imgSign + ".png" as NSString
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        var uimage = UIImage()
        URLSession.shared.dataTask(with: searchURL as URL) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            
            uimage = UIImage(data : data) ?? UIImage()
            
            let locationData = LocationData(actualTemp: ((((dayData["the_temp"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " °C"), imageSign: dayData["weather_state_abbr"] as? String ?? "c", img : uimage)
            
            self.objects.append(Location(name: name,locationData: locationData))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            }.resume()
        
    }
    func insertNewCity(cityName: String) {
        getLocationNumber(name: cityName)
    }
}
