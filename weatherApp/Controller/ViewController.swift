//
//  MAPVC.swift
//  weatherApp
//
//  Created by Amol Tamboli on 09/09/20.
//  Copyright © 2020 Amol Tamboli. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MAPVC: UIViewController {
    //MARK:- Outlets
    @IBOutlet var viewMap: MKMapView!
    
    //MARK:- Variable decleartion
    
    let location = CLLocationManager()
    
    
    //MARK:- Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserLocatoinService()
        self.title = "Weather App"
        viewMap.isZoomEnabled = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(triggerTouchAction(gestureReconizer:)))
        viewMap.addGestureRecognizer(gestureRecognizer)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        location.stopUpdatingLocation()
    }
    @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
        print("total taps:\(gestureReconizer.numberOfTapsRequired)")
       // if gestureReconizer.numberOfTapsRequired == 2{
            let location1 = gestureReconizer.location(in: viewMap)
            let coordinate = viewMap.convert(location1, toCoordinateFrom: viewMap)
        DispatchQueue.main.async {
            if let wVC = self.storyboard?.instantiateViewController(identifier: "WeatherDetailsVC")as? WeatherDetailsVC{
                wVC.currentLocation = coordinate
             self.navigationController?.pushViewController(wVC, animated: true)
            }
        }
       // }

        
    }
}
//MARK:- Location Manager
extension MAPVC:CLLocationManagerDelegate{
    private func checkUserLocatoinService(){
        
        if CLLocationManager.locationServicesEnabled(){
          setUpLocationManager()
          checkLocationAutorization()
        }
    }
    private func checkLocationAutorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            viewMap.showsUserLocation = true
            break
        case .denied:
            break
        case .notDetermined:
             location.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
        break
        @unknown default:
            fatalError()
        }
    }
    private func setUpLocationManager(){
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            render(location)
        }
    }
    private func render(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let regino = MKCoordinateRegion(center: coordinate, span: span)
        
    
        viewMap.setRegion(regino, animated: true)
        
        //Adding pin on map
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        viewMap.addAnnotation(pin)
    }
}
