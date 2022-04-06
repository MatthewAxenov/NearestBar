//
//  LocationManager.swift
//  Nearest bar
//
//  Created by Матвей on 25.03.2022.
//

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject {
    
    let locationManager: CLLocationManager
    static let shared = LocationManager()
    
    var currentLocation: CLLocation?
    
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: Locations
    
    func findLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Find bars
    
//    func findLocalBars(for location:CLLocation, completion: @escaping ((MKLocalSearch.Response?, Error?)->())) {        
//        var region = MKCoordinateRegion()
//        region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = "Бар"
//        request.region = region
//        let search = MKLocalSearch(request: request)
//        search.start(completionHandler: completion)
//    }
    
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
         
        }
    }
    
    
}
