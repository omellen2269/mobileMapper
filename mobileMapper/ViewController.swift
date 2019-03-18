//
//  ViewController.swift
//  mobileMapper
//
//  Created by Olivia Mellen on 3/6/19.
//  Copyright © 2019 John Hersey High School. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var parks: [MKMapItem] = []
    var initialRegion: MKCoordinateRegion!
    var isIntialMapLoad = true
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isIntialMapLoad {
            initialRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isIntialMapLoad = false
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        let zoomButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = zoomButton
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let button = control as! UIButton
        if button.buttonType == .contactAdd {
            mapView.setRegion(initialRegion, animated: true)
        }
        var currentMapItem = MKMapItem()
        if let title = view.annotation?.title, let parkName = title {
            for mapItem in parks {
                if mapItem.name == parkName {
                    currentMapItem = mapItem
                }
            }
        }
        //let placeMark = currentMapItem.placemark
        //print(placeMark)
        if let phoneNumber = currentMapItem.phoneNumber {
            createAlert(phoneNumber)
        }
    }
    
    func createAlert(_ phoneNumber: String) {
        let alert = UIAlertController(title: "Phone Number", message: phoneNumber, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    @IBAction func whenZoomPressed(_ sender: Any)
    {
        let center = currentLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func whenSearchPressed(_ sender: Any)
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "parks"
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            for mapItem in response.mapItems {
                self.parks.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    
}

