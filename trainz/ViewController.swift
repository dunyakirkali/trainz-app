//
//  ViewController.swift
//  trainz
//
//  Created by Dunya Kirkali on 04/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Cocoa
import Mapbox

class ViewController: NSViewController {

    let topSpeed: Double = 500 // kmph

    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var hornButton: NSButton!
    @IBOutlet weak var followToggle: NSButton!
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var speedSlider: NSSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupSlider()
        setupToggle()
        setupHorn()
        
        let center = CLLocationCoordinate2D(latitude: 19.820689, longitude: -155.468038)
        mapView.setCenter(center, animated: false)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func setupMapView() {
        mapView.delegate = self
    }
    
    private func setupSlider() {
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
}

extension ViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Wait for the map to load before initiating the first camera movement.
        
        // Create a camera that rotates around the same center point, rotating 180°.
        // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 4500, pitch: 15, heading: 180)
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
}

extension ViewController {
    @objc func valueChanged(_ sender: NSSlider) {
        let scaledValue: Int = scale(speed: sender.doubleValue)
        speedLabel.stringValue = "\(scaledValue) km/h"
    }

    private func scale(speed: Double) -> Int {
        return Int(speed / 100.0 * topSpeed)
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
