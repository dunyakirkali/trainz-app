//
//  ViewController.swift
//  trainz
//
//  Created by Dunya Kirkali on 04/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Cocoa
import Mapbox
import SceneKit
import Turf

class ViewController: NSViewController {
    
    /// The pitch to use for the map view
    let kMapPitchDegrees: Float = 0.0
    
    var timer: Timer?
    var i = 0

    /// Top speed for a train
    let topSpeed: Double = 500 // kmph
    
    /// Frames per second
    let fps: Int = 60
    
    /// SceneKit scene
    var scene: SCNScene!
    var playerNode: SCNNode!
    
    /// The track
    var coordinates = [CLLocationCoordinate2D]()

    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var hornButton: NSButton!
    @IBOutlet weak var followToggle: NSButton!
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var speedSlider: NSSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupSlider()
        setupToggle()
        setupHorn()
        setupSceneView()
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1 / fps), target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func setupSceneView() {
        // transparent background for use as overlay
        sceneView.backgroundColor = NSColor.clear
        scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.loops = true
        sceneView.isPlaying = true
        
        playerNode = SCNNode()
        let playerScene = SCNScene(named: "classy_crab.stl")!
        let playerModelNode = playerScene.rootNode.childNodes.first!
        playerNode.addChildNode(playerModelNode)
        scene.rootNode.addChildNode(playerNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 35)
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupMapView() {
        let camera = MGLMapCamera()
        camera.pitch = CGFloat(kMapPitchDegrees)
        mapView.setCamera(camera, animated: false)
        
        mapView.delegate = self
        mapView.setCenter(CLLocationCoordinate2D(latitude:38.897435, longitude: -77.039679), animated: false)
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
}

extension ViewController {
    @objc func tick() {
        // EXP
        i += 1
        let dist = LineString(coordinates).distance() // Meters
        let offset = (currentSpeed * Double(i)).truncatingRemainder(dividingBy: dist)
        let point = LineString(coordinates).coordinateFromStart(distance: offset)
        if let point = point {
            let camera = MGLMapCamera(lookingAtCenter: point, fromDistance: 1000, pitch: CGFloat(kMapPitchDegrees), heading: mapView.camera.heading)
            
//            mapView.setCamera(camera, withDuration: TimeInterval(1 / fps), animationTimingFunction: nil, completionHandler: nil)
            
            mapView.setCamera(camera, animated: false)
        }
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
        
    
        if let polyline = feature.shapes.last as? MGLPolylineFeature {
            coordinates = Array(UnsafeBufferPointer(start: polyline.coordinates, count: Int(polyline.pointCount)))
        }
        
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

extension ViewController: SCNSceneRendererDelegate {
    func coordinateToOverlayPosition(coordinate: CLLocationCoordinate2D) -> SCNVector3 {
        let p: CGPoint = mapView.convert(coordinate, toPointTo: mapView)
        return SCNVector3Make(p.x, sceneView.bounds.size.height - p.y, 0)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        // get pitch of map
//        let mapPitchRads: CGFloat = mapView.camera.pitch * CGFloat(Float.pi) / 180.0
//
//        let playerPoint = coordinateToOverlayPosition(coordinate: mapView.centerCoordinate)
//        let scaleMat = SCNMatrix4MakeScale(10.0, 10.0, 10.0)
//        playerNode.transform = SCNMatrix4Mult(
//            scaleMat,
//            SCNMatrix4Mult(
//                SCNMatrix4MakeRotation(-mapPitchRads, 1, 0, 0),
//                SCNMatrix4MakeTranslation(playerPoint.x, playerPoint.y, 0)
//            )
//        )
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
    
    var currentSpeed: Double {
        let scaledValue: Int = scale(speed: speedSlider.doubleValue)
        return Double(scaledValue) * 1000.0 / 60.0 / 60.0 / Double(fps)
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
