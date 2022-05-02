//
// Created by Maxim Krimskiy on 4/22/21.
//

import Foundation
import MapKit

class GlobalStateController: ObservableObject {
    @Published var mapView: MKMapView = MKMapView() {
        willSet {
            objectWillChange.send();
        }
    };
    @Published var myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D() {
        didSet {
            if (!(Tracks.count > 0)) {
                return;
            }

            let myPoint = PointType(latitude: myLocation.latitude, longitude: myLocation.longitude);
            let (minimalDistanceTrack, _) = MapController().getNearestTrack(point: myPoint, tracks: Tracks);
            myTrackByLocation = minimalDistanceTrack;

            let (_, _, index) = MapController().getNearestPoint(point: myPoint, pointsList: minimalDistanceTrack.points)
            myIndexOnTrackByLocation = index;


        }
        willSet {
            objectWillChange.send();
        }
    };

    @Published var Tracks: [TrackForUseType] = [] {
        willSet {
            objectWillChange.send();
        }
    };
    @Published var Crossroads: [CrossroadType] = []
    @Published var MainJsonData: Data = Data() {
        willSet {
            objectWillChange.send();
        }
    };
    @Published var locationManager: CLLocationManager = CLLocationManager() {
        willSet {
            objectWillChange.send();
        }
    };

    @Published var navigationTrack: [MKMapPoint] = [];
    @Published var navigationPath: [CrossroadType] = [];
    @Published var navigationTo: Int = 0;

    @Published var myTrackByLocation: TrackForUseType? {
        willSet {
            print("myTrackByLocation - change")
            objectWillChange.send();
        }
    };
    @Published var myIndexOnTrackByLocation: Int? {
        willSet {
            print("myIndexOnTrackByLocation - change")
            objectWillChange.send();
        }
    };
}
