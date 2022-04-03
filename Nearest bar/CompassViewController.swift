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
    
    let locationManager = LocationManager.shared.locationManager
    
    private var updateTimer: Timer?
    
    private var pointToShow: CLLocationCoordinate2D?
    
    private var barAnnotations: [MKAnnotation]!
    
    @IBOutlet weak var rotatingArrow: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var pressInstructionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
        showLoading()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    //MARK: Поиск бара
    
    @objc func findNearest() {
        LocationManager.shared.findLocation()
        guard let location = LocationManager.shared.currentLocation else { return }
        LocationManager.shared.findLocalBars(for: location) { [weak self] response, error in
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
                self.pointToShow = point
            }
        }
        LocationManager.shared.stopUpdatingLocation()
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
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading(){
        loadingIndicatorView.isHidden = true
        loadingIndicatorView.stopAnimating()
        loadingLabel.isHidden = true
        pressInstructionLabel.isHidden = false
        view.isUserInteractionEnabled = true

    }
    
    //MARK: Heading
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            if newHeading.headingAccuracy < 0 { return }
            guard let nearest = pointToShow else { return }
            let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading)
            guard let location = LocationManager.shared.currentLocation else { return }
            let bearing = getBearing(location: location, point: nearest)
            let res = CGFloat(heading) - CGFloat(bearing)
            UIView.animate(withDuration: 0.5)
            {
                let angle = CGFloat(res).degreesToRadians
                self.rotatingArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(angle))
//                print(heading, bearing)
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
    
    
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

