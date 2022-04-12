//
//  CompassViewController.swift
//  Nearest bar
//
//  Created by Матвей on 12.03.2022.
//

import UIKit
import CoreLocation
import MapKit



class CompassViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Search prop
    
    var search: String!
    
    var navTitle: String {
        switch search {
        case "бар", "ресторан", "магазин", "кинотеатр", "парк", "салон", "банк": return "\(search!)у"
        case "кафе": return "кафе"
        case "продукты", "продуктовый": return "продуктовому"
            
        default: return "месту"
        }
    }
    
    var lowLabelPlace: String {
        switch search {
        case "бар", "ресторан", "магазин", "кинотеатр", "парк", "салон", "банк": return "\(search!)ами"
        case "кафе": return "кафе"
        case "продукты", "продуктовый": return "продуктовыми"
            
        default: return "интересующими вас местами"
        }
    }
    
    //MARK: Location prop
    
    //MARK: Update (second locationManager)
    
    var currentLocation: CLLocation?
    
    let manager = CLLocationManager()
    
    
    
    let locationManager = LocationManager.shared.locationManager
    
    private var updateTimer: Timer?
    
    private var pointToShow: CLLocationCoordinate2D?
    
    private var pointLocation: CLLocation? {
        didSet {
            guard let pointLocation = pointLocation else {
                return
            }
//            let distance = self.calculateDistance(from: pointLocation, to: LocationManager.shared.currentLocation!)
            
            guard let currentLocation = currentLocation else {
                return
            }

            
            let distance = self.calculateDistance(from: pointLocation, to: currentLocation)

            self.distanceLabel.text = distance + " м"
        }
    }
    
    private var barAnnotations: [MKAnnotation]!
    
    
    //MARK: Outlets
    
    @IBOutlet weak var rotatingArrow: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var pressInstructionLabel: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    
    //MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        navigationItem.title = "Направление к ближайшему \(navTitle)"
        lowLabel.text = "Нажмите на экран, чтобы перейти на карту с ближайшими \(lowLabelPlace)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Update
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        startTimer()
        showLoading()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    //MARK: Update. Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    //MARK: Place serch (update)
    
    
    @objc func findNearest() {
        
        //Update
        
//        LocationManager.shared.findLocation()
        
        manager.startUpdatingLocation()
        
        guard let location = currentLocation else {
            return
        }
        print(location)

        
//        guard let location = LocationManager.shared.currentLocation else { return }
//        print(location)
        
        LocationManager.shared.findLocalPlaces(for: location, search: self.search) { [weak self] response, error in
            guard let self = self else { return }
            var tmpAnnotations = [MKAnnotation]()
            guard let response = response else { return }
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                tmpAnnotations.append(annotation)
            }
            self.barAnnotations = self.sortAnnotations(tmpAnnotations, location: location)
            if let nearest = self.barAnnotations.first {
                let point = CLLocationCoordinate2D(latitude: nearest.coordinate.latitude, longitude: nearest.coordinate.longitude)
                let pointLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
                self.pointToShow = point
                self.pointLocation = pointLocation
                self.barLabel.text = nearest.title ?? ""
            }
        }
//        LocationManager.shared.stopUpdatingLocation()
        
        manager.stopUpdatingLocation()
        hideLoading()
    }
    
    func sortAnnotations(_ annotations: [MKAnnotation], location: CLLocation) -> [MKAnnotation] {
        let result = annotations.sorted { mk1, mk2 in
            let distance1 = location.distance(from: CLLocation(latitude: mk1.coordinate.latitude, longitude: mk1.coordinate.longitude))
            let distance2 = location.distance(from: CLLocation(latitude: mk2.coordinate.latitude, longitude: mk2.coordinate.longitude))
            return distance1 < distance2
        }
        return result
    }
    
    //MARK: Timer
    
    func startTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(findNearest), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    //MARK: Loading
    
    private func showLoading(){
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.startAnimating()
        loadingLabel.isHidden = false
        pressInstructionLabel.isHidden = true
        barLabel.isHidden = true
        distanceLabel.isHidden = true
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading(){
        loadingIndicatorView.isHidden = true
        loadingIndicatorView.stopAnimating()
        loadingLabel.isHidden = true
        pressInstructionLabel.isHidden = false
        barLabel.isHidden = false
        distanceLabel.isHidden = false
        view.isUserInteractionEnabled = true

    }
    
    //MARK: Heading
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            if newHeading.headingAccuracy < 0 { return }
            guard let nearest = pointToShow else { return }
            let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading)
        
//            guard let location = LocationManager.shared.currentLocation else { return }
        
            guard let location = currentLocation else { return }

            let bearing = getBearing(location: location, point: nearest)
            let res = CGFloat(heading) - CGFloat(bearing)
            UIView.animate(withDuration: 0.5)
            {
                let angle = CGFloat(res).degreesToRadians
                self.rotatingArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(angle))
            }
        }
        
    
    //MARK: Bearing - угол отклонения
    
    func getBearing(location: CLLocation, point: CLLocationCoordinate2D) -> CGFloat {
            let latSource = CGFloat(location.coordinate.latitude).degreesToRadians
            let lonSource = CGFloat(location.coordinate.longitude).degreesToRadians
            
            let latBar = CGFloat(point.latitude).degreesToRadians
            let lonBar = CGFloat(point.longitude).degreesToRadians
            
            let dLon = lonBar - lonSource
            
            let y = sin(dLon)*cos(latBar)
            let x = cos(latSource)*sin(latBar) - sin(latSource)*cos(latBar)*cos(dLon)
            let radiansBearing = atan2(y, x)
            
            return (radiansBearing.radiansToDegrees>0) ? radiansBearing.radiansToDegrees : radiansBearing.radiansToDegrees + 360
        }
    
    func calculateDistance(from: CLLocation, to: CLLocation ) -> String {
        let distance = Int(from.distance(from: to))
        return String(distance)
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            
            let mapViewController = segue.destination as! MapViewController
            mapViewController.search = self.search
            
        }
    }
    
    
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

