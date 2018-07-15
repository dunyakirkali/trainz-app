//
//  ViewController.swift
//  trainz
//
//  Created by Dunya Kirkali on 04/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Cocoa
import CoreLocation
import MapKit
import SceneKit
import Turf

class ViewController: NSViewController {
    
    /// Train
    let train: Train = Train(location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    /// The track
    var coordinates = [CLLocationCoordinate2D]()
    
    /// List of Countries
    let countries = ["Netherlands", "Belgium"]

    /// IBOutlets
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var hornButton: NSButton!
    @IBOutlet weak var followToggle: NSButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speedSlider: NSSlider!
    @IBOutlet weak var countrySelector: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSlider()
        setupToggle()
        setupHorn()
        setupCountrySelector()
    }

    private func setupSlider() {
        speedSlider.isContinuous = true
        speedSlider.target = self
        speedSlider.action = #selector(ViewController.valueChanged(_:))
        speedSlider.doubleValue = 0.0
    }
    
    private func setupToggle() {
        followToggle.target = self
        followToggle.action = #selector(ViewController.followToggled(_:))
    }
    
    private func setupHorn() {
        hornButton.target = self
        hornButton.action = #selector(ViewController.hornTriggered(_:))
    }
    
    private func setupCountrySelector() {
        countrySelector.removeAllItems()
        
        countrySelector.addItems(withTitles: countries)
        countrySelector.target = self
        countrySelector.action = #selector(ViewController.countrySelected(_:))
    }
}

extension ViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        addTrack()
    }
}

extension ViewController {
    @objc func valueChanged(_ sender: NSSlider) {
        let scaledValue: Double = scale(speed: sender.doubleValue)
        train.speed = Measurement<UnitSpeed>(value: scaledValue, unit: .kilometersPerHour)
        speedLabel.stringValue = "\(Int(scaledValue)) km/h"
    }

    private func scale(speed: Double) -> Double {
        return speed / 100.0 * Train.topSpeed.value
    }
}

extension ViewController {
    @objc func followToggled(_ sender: NSButton) {
        print(sender.state)
    }
}

extension ViewController {
    @objc func hornTriggered(_ sender: NSButton) {
        NSSound.beep()
    }
}

extension ViewController {
    @objc func countrySelected(_ sender: NSPopUpButton) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString((sender.selectedItem?.title)!) { [weak self] response, error in
            guard let region = response?.first?.region as? CLCircularRegion else { return }
            let mkregion = MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2)
            self?.mapView.setRegion(mkregion, animated: true)
        }
    }
}

extension ViewController {
    func addTrack() {
        let thePath = Bundle.main.path(forResource: "EntranceToGoliathRoute", ofType: "plist")
        let pointsArray = NSArray(contentsOfFile: thePath!)
        let pointsCount = pointsArray?.count
    
        var pointsToUse = [CLLocationCoordinate2D]()

        for i in 0...pointsCount! {
            let p = NSPointFromString(pointsArray![i] as! String)
            pointsToUse.append(CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y)))
        }

        let myPolyline = MKPolyline(coordinates: pointsToUse, count: pointsCount!)
        mapView.add(myPolyline)
    }
}
