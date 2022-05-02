//
// Created by Maxim Krimskiy on 4/20/21.
//

import MapKit

class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    var parent: MapView
    var firstSetRegion = false;
    var gRecognizer = UILongPressGestureRecognizer()

    init(_ parent: MapView) {
        self.parent = parent
        super.init()
        gRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        gRecognizer.delegate = self
        self.parent.mapObj.showsCompass = false;
        self.parent.mapObj.addGestureRecognizer(gRecognizer)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        parent.region = mapView.region;
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? ExtendedPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = routePolyline.color;
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }

    @objc func tapHandler(_ gesture: UILongPressGestureRecognizer) {
        // position on the screen, CGPoint
        let location = gRecognizer.location(in: self.parent.mapObj)
        // position on the map, CLLocationCoordinate2D
        let coordinate = self.parent.mapObj.convert(location, toCoordinateFrom: self.parent.mapObj)

        print(coordinate)
        parent.myLocation = coordinate;


        parent.mapObj.removeAnnotations(parent.mapObj.annotations);
        let annotation = MKPointAnnotation()
        annotation.title = "Custom location"
        annotation.coordinate = coordinate
        parent.mapObj.addAnnotation(annotation)

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations
    locations: [CLLocation]) {

        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        if (!firstSetRegion) {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: locValue, span: span)
            parent.mapObj.setRegion(region, animated: true)
            firstSetRegion.toggle();
        }

        if (parent.myLocation.longitude != locValue.longitude) {
            parent.myLocation = locValue;
        }
    }
}

class ExtendedPolyline: MKPolyline {
    var color: UIColor = UIColor.systemGray;
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}