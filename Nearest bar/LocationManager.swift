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
    //Делаем свойство класса, а не его образца
    static let shared = LocationManager()
    //Когда будем в vc обращаться к shared - будем возвращать ссылку на созданный объект внутри класса.
    
    var currentLocation: CLLocation?
    
    
    //Теперь этот класс нельзя будет создать нигде кроме Location Manager. Singleton - паттерн, вызывается первый раз когда мы его инициализируем, потом живет в памяти
    
    //Приватный инициализатор - для того, чтобы нельзя было что-то переопределять
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func findLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Добавил mapView как параметр функции
    
    func findLocalBars(for location:CLLocation, completion: @escaping ((MKLocalSearch.Response?, Error?)->())) {        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Бар"
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: completion)
    }
    
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
         
        }
    }
    
    
}
