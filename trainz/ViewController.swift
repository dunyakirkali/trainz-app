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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.setCenter(CLLocationCoordinate2D(latitude:38.897435, longitude: -77.039679), animated: false)
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
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // Parse the GeoJSON data.
//        DispatchQueue.global().async {
            guard let url = Bundle.main.url(forResource: "metro-line", withExtension: "geojson") else { return }
            
            let data = try! Data(contentsOf: url)
            
            DispatchQueue.main.async {
                self.drawShapeCollection(data: data)
            }
//        }
    }
    
    func drawShapeCollection(data: Data) {
        guard let style = self.mapView.style else { return }
        
        // Use [MGLShape shapeWithData:encoding:error:] to create a MGLShapeCollectionFeature from GeoJSON data.
        let feature = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature
        
        // Create source and add it to the map style.
        let source = MGLShapeSource(identifier: "transit", shape: feature, options: nil)
        style.addSource(source)
        
        // Create station style layer.
        let circleLayer = MGLCircleStyleLayer(identifier: "stations", source: source)
        
        // Use a predicate to filter out non-points.
        circleLayer.predicate = NSPredicate(format: "TYPE = 'Station'")
        circleLayer.circleColor = NSExpression(forConstantValue: NSColor.red)
        circleLayer.circleRadius = NSExpression(forConstantValue: 6)
        circleLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)
        circleLayer.circleStrokeColor = NSExpression(forConstantValue: NSColor.black)
        
        // Create line style layer.
        let lineLayer = MGLLineStyleLayer(identifier: "rail-line", source: source)
        
        // Use a predicate to filter out the stations.
        lineLayer.predicate = NSPredicate(format: "TYPE = 'Rail line'")
        lineLayer.lineColor = NSExpression(forConstantValue: NSColor.red)
        lineLayer.lineWidth = NSExpression(forConstantValue: 2)
        
        // Add style layers to the map view's style.
        style.addLayer(circleLayer)
        style.insertLayer(lineLayer, below: circleLayer)
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
