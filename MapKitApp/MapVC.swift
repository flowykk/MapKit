import UIKit
import CoreLocation
import MapKit
import AVFoundation

class MapVC: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate
{
    private let locationManager = CLLocationManager()
    private var coordinatesArray = [CLLocationCoordinate2D]()
    private var annotationsArray = [MKAnnotation]()
    private var overlaysArray = [MKOverlay]()
    
    private let mapView = MKMapView()
    private let startLocation = UITextField()
    private let midLocation = UITextField()
    private let finishLocation = UITextField()
    
    private let goButton = UIButton()
    private let clearButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(tapGesture)
        
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureLocationManager()
        
        configureStartLocationTextField()
        configureMidLocationTextField()
        configureFinishLocationTextField()
        
        configureMap()
        
        configureGoButton()
        configureClearButton()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
    }
    
    private func configureStartLocationTextField() {
        startLocation.delegate = self
        
        startLocation.backgroundColor = .systemGray5
        startLocation.placeholder = "From"
        startLocation.font = UIFont.systemFont(ofSize: 15)
        startLocation.borderStyle = UITextField.BorderStyle.roundedRect
        startLocation.autocorrectionType = UITextAutocorrectionType.yes
        startLocation.keyboardType = UIKeyboardType.default
        startLocation.returnKeyType = UIReturnKeyType.go
        
        view.addSubview(startLocation)
        startLocation.pinHorizontal(to: view, 10)
        startLocation.pinTop(to: view, 55)
        startLocation.setHeight(40)
    }
    
    private func configureMidLocationTextField() {
        midLocation.delegate = self
        
        midLocation.backgroundColor = .systemGray5
        midLocation.placeholder = "Stop here"
        midLocation.font = UIFont.systemFont(ofSize: 15)
        midLocation.borderStyle = UITextField.BorderStyle.roundedRect
        midLocation.autocorrectionType = UITextAutocorrectionType.yes
        midLocation.keyboardType = UIKeyboardType.default
        midLocation.returnKeyType = UIReturnKeyType.go
        
        view.addSubview(midLocation)
        midLocation.pinHorizontal(to: view, 10)
        midLocation.pinTop(to: startLocation.bottomAnchor, 10)
        midLocation.setHeight(40)
    }
    
    private func configureFinishLocationTextField() {
        finishLocation.delegate = self
        
        finishLocation.backgroundColor = .systemGray5
        finishLocation.placeholder = "To"
        finishLocation.font = UIFont.systemFont(ofSize: 15)
        finishLocation.borderStyle = UITextField.BorderStyle.roundedRect
        finishLocation.autocorrectionType = UITextAutocorrectionType.yes
        finishLocation.keyboardType = UIKeyboardType.default
        finishLocation.returnKeyType = UIReturnKeyType.go
        
        view.addSubview(finishLocation)
        finishLocation.pinHorizontal(to: view, 10)
        finishLocation.pinTop(to: midLocation.bottomAnchor, 10)
        finishLocation.setHeight(40)
    }
    
    private func configureMap() {
        mapView.delegate = self
        
        mapView.layer.cornerRadius = 15
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        mapView.pinLeft(to: view)
        mapView.pinTop(to: finishLocation.bottomAnchor, 10)
        mapView.pinRight(to: view)
        mapView.pinBottom(to: view)
    }
    
    private func configureGoButton() {
        goButton.addTarget(self, action: #selector(getYourRoute), for: .touchUpInside)
        goButton.setTitle("Go", for: .normal)
        goButton.backgroundColor = .systemGreen
        goButton.titleLabel?.textColor = UIColor.white
        goButton.layer.cornerRadius = 25
        goButton.clipsToBounds = false
        goButton.layer.borderWidth = 4
        goButton.layer.borderColor = UIColor.green.cgColor
        
        view.addSubview(goButton)
        goButton.setHeight(70)
        goButton.setWidth(70)
        goButton.pinBottom(to: view, 70)
        goButton.pinRight(to: view, 30)
    }
    
    private func configureClearButton() {
        clearButton.addTarget(self, action: #selector(clearRoute), for: .touchUpInside)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.backgroundColor = .red
        clearButton.titleLabel?.textColor = UIColor.white
        clearButton.layer.cornerRadius = 25
        clearButton.clipsToBounds = false
        clearButton.layer.borderWidth = 4
        clearButton.layer.borderColor = UIColor.systemRed.cgColor
        
        view.addSubview(clearButton)
        clearButton.setHeight(70)
        clearButton.setWidth(70)
        clearButton.pinBottom(to: view, 70)
        clearButton.pinLeft(to: view, 30)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc
    private func handleMapTap() {
        view.endEditing(true)
    }
    
    @objc
    private func clearRoute(_ sender: UIButton) {
        self.mapView.removeAnnotations(self.annotationsArray)
        self.annotationsArray = []
        
        self.mapView.removeOverlays(self.overlaysArray)
        self.overlaysArray = []
        
        startLocation.text = ""
        finishLocation.text = ""
        midLocation.text = ""
    }
    
    @objc
    private func getYourRoute(_ sender: UIButton) {
        let completion1 = findMiddle
        
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.annotationsArray)
            self.annotationsArray = []
        }
        
        if self.overlaysArray.count > 0 {
            self.mapView.removeOverlays(self.overlaysArray)
            self.overlaysArray = []
        }
        
        self.coordinatesArray = []
        
        if (startLocation.text!.count == 0
            || midLocation.text!.count == 0
            || finishLocation.text!.count == 0) {
            return
        }
        
        if self.startLocation.text!.count == 0 {
            guard let sourceCoordinate = locationManager.location?.coordinate else { return }
            //            showCurrent(coordinates: sourceCoordinate, completion: completion1)
            self.coordinatesArray.append(sourceCoordinate)
            findMiddle()
        } else {
            DispatchQueue.global(qos: .utility).async {
                self.findLocation(location: self.startLocation.text!, showRegion: false, completion: completion1)
            }
        }
    }
    
    private func findMiddle() {
        let compl = finFinish
        DispatchQueue.global(qos: .utility).async {
            self.findLocation(location: self.midLocation.text!, showRegion: true, completion: compl)
        }
    }
    
    
    private func finFinish() {
        let compl = findLocations
        DispatchQueue.global(qos: .utility).async {
            self.findLocation(location: self.finishLocation.text!, showRegion: true, completion: compl)
        }
    }
    
    private func findLocation(location: String, showRegion: Bool = false, completion: @escaping () -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let coordinates = placemark.location!.coordinate
                self.coordinatesArray.append(coordinates)
                let point = MKPointAnnotation()
                point.coordinate = coordinates
                point.title = location
                
                if let country = placemark.country {
                    point.subtitle = country
                }
                
                self.mapView.addAnnotation(point)
                self.annotationsArray.append(point)
                
                if showRegion {
                    self.mapView.centerCoordinate = coordinates
                    let span = MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.mapView.setRegion(region, animated: showRegion)
                }
            } else {
                print(String(describing: error))
            }
            completion()
        }
    }
    
    private func showCurrent(coordinates: CLLocationCoordinate2D, showRegion: Bool = false, completion: @escaping () -> Void ) {
        self.coordinatesArray.append(coordinates)
        let point = MKPointAnnotation()
        point.coordinate = coordinates
        point.title = ""
        point.subtitle = ""
        
        self.mapView.addAnnotation(point)
        self.annotationsArray.append(point)
        
        if showRegion {
            self.mapView.centerCoordinate = coordinates
            let span = MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            self.mapView.setRegion(region, animated: showRegion)
        }
        completion()
    }
    
    private func doAfterOne() {
        let completion2 = findLocations
        DispatchQueue.global(qos: .utility).async {
            self.findLocation(location: self.finishLocation.text!, showRegion: true, completion: completion2)
        }
    }
    
    private func findLocations() {
        if self.coordinatesArray.count < 3 {
            return
        }
        
        let markLocationOne = MKPlacemark(coordinate: self.coordinatesArray[0])
        let markLocationHalf = MKPlacemark(coordinate: self.coordinatesArray[1])
        let markLocationTwo = MKPlacemark(coordinate: self.coordinatesArray[2])
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: markLocationOne)
        directionRequest.destination = MKMapItem(placemark: markLocationHalf)
        directionRequest.transportType = .automobile
    
        
        var directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if error != nil {
                print(String(describing: error))
            } else {
                let myRoute: MKRoute? = response?.routes.first
                if let a = myRoute?.polyline {
                    self.overlaysArray.append(a)
                    self.mapView.addOverlay(a)
                    
                    // Настройка отображения маршрута на карте
                    let rect = a.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                    
                    self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
                }
            }
        }
        
        directionRequest.source = MKMapItem(placemark: markLocationHalf)
        directionRequest.destination = MKMapItem(placemark: markLocationTwo)
        directionRequest.transportType = .automobile
        
        directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if error != nil {
                print(String(describing: error))
            } else {
                let myRoute: MKRoute? = response?.routes.first
                if let a = myRoute?.polyline {
                    self.overlaysArray.append(a)
                    self.mapView.addOverlay(a)
                    
                    // Настройка отображения маршрута на карте
                    let rect = a.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                    
                    self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startMap()
    }
    
    private func startMap() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = .systemPink
            polylineRenderer.lineWidth = 4
        }
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            //Create View
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            //Assign annotation
            annotationView?.annotation = annotation
        }
        
        
        annotationView?.image = UIImage(named: "point")?.resize(50, 50)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
}

public extension UIImage {
    func resize(_ width: Int, _ height: Int) -> UIImage {
        let maxSize = CGSize(width: width, height: height)
        
        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resized
    }
}
