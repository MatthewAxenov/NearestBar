//
//  ViewController.swift
//  Nearest bar
//
//  Created by Матвей on 10.03.2022.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    private var barAnnotations: [MKAnnotation]! {
        didSet {
            print(barAnnotations.first?.title)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        barAnnotations = []
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        guard let currentLocation = LocationManager.shared.currentLocation else { return }
        render(currentLocation)
        LocationManager.shared.findLocalBars(for: currentLocation) { [weak self] response, error in
            var tmpAnnotations = [MKAnnotation]()
            guard let response = response else { return }
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
//                print(annotation.title!)
                tmpAnnotations.append(annotation)
                self?.mapView?.addAnnotation(annotation)
            }
            self?.barAnnotations = self?.sortAnnotations(tmpAnnotations, location: currentLocation)
        }
    }
    
    func sortAnnotations(_ annotations: [MKAnnotation], location: CLLocation) -> [MKAnnotation] {
        let result = annotations.sorted { mk1, mk2 in
            let distance1 = location.distance(from: CLLocation(latitude: mk1.coordinate.latitude, longitude: mk1.coordinate.longitude))
            let distance2 = location.distance(from: CLLocation(latitude: mk2.coordinate.latitude, longitude: mk2.coordinate.longitude))
            return distance1 < distance2
        }
        return result
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}



