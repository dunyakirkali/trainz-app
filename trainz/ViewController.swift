//
//  ViewController.swift
//  trainz
//
//  Created by Dunya Kirkali on 04/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {
    
    let topSpeed: Double = 500 // kmph

    @IBOutlet weak var hornButton: NSButton!
    @IBOutlet weak var followToggle: NSButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speedSlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupSlider()
        setupToggle()
        setupHorn()
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

extension ViewController: MKMapViewDelegate {

}

extension ViewController {
    @objc func valueChanged(_ sender: NSSlider) {
        print(scale(speed: sender.doubleValue))
    }
    
    private func scale(speed: Double) -> Double {
        return speed / 100.0 * topSpeed
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
