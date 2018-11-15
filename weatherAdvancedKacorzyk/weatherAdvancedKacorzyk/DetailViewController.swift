//
//  DetailViewController.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 18.10.2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var weatherState: UITextField!
    @IBOutlet weak var rain: UITextField!
    @IBOutlet weak var minTemp: UITextField!
    @IBOutlet weak var maxTemp: UITextField!
    @IBOutlet weak var pressure: UITextField!
    @IBOutlet weak var windSpeed: UITextField!
    @IBOutlet weak var windDirection: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    var weather : [[String : Any]] = []
    var currentIndex = 0
    
    let doubleFormat = ".2"
    
    var position = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.GetCityNumber()
    }
    
    var detailItem: Location? {
        didSet {
            // Update the view.
            self.GetCityNumber()
        }
    }
    
    
    func GetCityNumber(){
        if let detailItem = detailItem {
            
            let url : NSString = "https://www.metaweather.com/api/location/search/?query=" + detailItem.name as NSString
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
                self.GetManyDayData(locationNumber: String(locationNumber))
            }
            
            }.resume()
        }
    }
    
    func GetManyDayData(locationNumber : String) {
        let urlString = "https://www.metaweather.com/api/location/" + locationNumber + "/"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String:Any]{
                if let positionData = dictionary["latt_long"] as? String{
                    self.position = positionData
                }
                if let weather_data = dictionary["consolidated_weather"] as? [[String:Any]]{
                    self.weather = weather_data
                    self.updateView()
                }
            }
            
            }.resume()
    }
    
    func downloadImage(imgName : String) {
        let urlString = "https://www.metaweather.com/static/img/weather/png/" + imgName + ".png"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.img.image = UIImage(data : data)
            }
            
            }.resume()
    }
    
    func updateView(){
        DispatchQueue.main.async {
            if self.currentIndex >= self.weather.count - 1 {
                self.nextButton.isEnabled = false
            }
            else if self.nextButton.isEnabled == false{
                self.nextButton.isEnabled = true
            }
            
            if self.currentIndex < 1 {
                self.previewButton.isEnabled = false
            }
            else if self.previewButton.isEnabled == false{
                self.previewButton.isEnabled = true
            }
            
            let dayData = self.weather[self.currentIndex]
            self.date.text = (dayData["applicable_date"] as? String)
            self.weatherState.text = (dayData["weather_state_name"] as? String)
            self.minTemp.text = (((dayData["min_temp"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " °C"
            self.maxTemp.text = (((dayData["max_temp"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " °C"
            self.windSpeed.text = (((dayData["wind_speed"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " km/h"
            self.windDirection.text = (((dayData["wind_direction"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " °"
            self.pressure.text = (((dayData["air_pressure"] as? Double)?.format(f: self.doubleFormat))?.description ?? "") + " hPa"
            self.rain.text = ((dayData["predictability"] as? Int)?.description ?? "") + " %"
            self.downloadImage(imgName: dayData["weather_state_abbr"] as? String ?? "c")
            
        }
        return
    }
    
    @IBAction func previousClick(_ sender: Any) {
        self.currentIndex = self.currentIndex - 1
        updateView()
    }
    @IBAction func nextClick(_ sender: Any) {
        self.currentIndex = self.currentIndex + 1
        updateView()
    }
    
    
    @IBAction func showLocationOnMap(_ sender: Any) {
        performSegue(withIdentifier: "showMap", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is MapViewController
        {
            let vc = segue.destination as? MapViewController
            vc?.position = self.position
        }
    }
    
}
    
    


extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}



