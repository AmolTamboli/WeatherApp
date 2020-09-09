//
//  WeatherDetailsVC.swift
//  weatherApp
//
//  Created by Amol Tambolir on 09/09/20.
//  Copyright © 2020 Amol Tamboli. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherDetailsVC: UIViewController {
    @IBOutlet var viewTable: UITableView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    var current: CurrentWeather?
   // var currentLocation: CLLocation?
     var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Weather Details"
        
        self.loader.hidesWhenStopped = true
        self.loader.layer.cornerRadius = 10
        self.loader.clipsToBounds = true
        self.loader.backgroundColor = .systemRed
       self.loader.color = .white
     
       tableViewCustomization()
        
       requestWeatherForLocation()
        
       view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
    }
    
    private func tableViewCustomization(){
        viewTable.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        viewTable.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)

        viewTable.delegate = self
        viewTable.dataSource = self
        viewTable.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
    }
   private func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
    DispatchQueue.main.async {
        self.loader.startAnimating()
    }
//        let long = currentLocation.coordinate.longitude
//        let lat = currentLocation.coordinate.latitude

        let long = currentLocation.longitude
        let lat = currentLocation.latitude
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"

        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
           DispatchQueue.main.async {
               self.loader.stopAnimating()
           }
            // Validation
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }

            // Convert data to models/some object

            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }

            guard let result = json else {
                return
            }

            let entries = result.daily.data

            self.models.append(contentsOf: entries)

            let current = result.currently
            self.current = current

            self.hourlyModels = result.hourly.data

            // Update user interface
            DispatchQueue.main.async {
                self.viewTable.reloadData()

                self.viewTable.tableHeaderView = self.createTableHeader()
            }

        }).resume()
    }
    func createTableHeader() -> UIView {
        let headerVIew = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))

        headerVIew.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)

        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/2))

        headerVIew.addSubview(locationLabel)
        headerVIew.addSubview(tempLabel)
        headerVIew.addSubview(summaryLabel)

        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center

        locationLabel.text = "Selected Location"

        guard let currentWeather = self.current else {
            return UIView()
        }

        tempLabel.text = "\(currentWeather.temperature)°"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        summaryLabel.text = self.current?.summary

        return headerVIew
    }

}
extension WeatherDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
          return 1
        }
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
            return cell
        }

        // Continue
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

