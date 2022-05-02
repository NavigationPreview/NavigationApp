//
// Created by Maxim Krimskiy on 4/22/21.
//

import Foundation
import MapKit

func decodeTracks(data: Data) -> [TrackForUseType] {
    guard let objs = try? JSONDecoder.init().decode(GeoJsonType.self, from: data) else {
        return [];
    }

    var result: [TrackForUseType] = [];
    objs.features.forEach { type in
        let id = type.properties.track.id;
        let name = type.properties.track.name;
        let points = type.geometry.coordinates;
        let turns = type.properties.crossroads;

        result.append(TrackForUseType(id: id, name: name, points: points, turns: turns))
    }

    return result;
}

func getCrossroads(_ tracks: [TrackForUseType]) -> [CrossroadType] {
    var result:[CrossroadType] = [];
    tracks.forEach { track in
        track.turns.forEach { turn in
            result.append(turn);
        }
    }

    return result
}

struct TrackForUseType: Codable {
    var id: Int;
    var name: String;
    var points: [PointType];
    var turns: [CrossroadType] = [];

    var MKMapPoints: [MKMapPoint] {
        var mapPoints: [MKMapPoint] = []
        for point in points {
            mapPoints.append(MKMapPoint(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)))
        }

        return mapPoints;
    }
}

struct GeoJsonType: Codable {
    var type: String;
    var features: [FeaturesType];
}

struct FeaturesType: Codable {
    var type: String;
    var properties: FeaturesPropertiesType;
    var geometry: FeaturesGeometryType;
}

struct FeaturesPropertiesType: Codable {
    var crossroads: [CrossroadType];
    var track: TrackType;
}

struct FeaturesGeometryType: Codable {
    var type: String;
    var coordinates: [PointType];
}

struct TrackType: Codable {
    var id: Int;
    var name: String;
}

struct CrossroadType: Codable {
    var id: Int;
    var point_index: Int;
    var point_index_to: Int;
    var angle: Double;
    var track_id_from: Int;
    var track_id_to: Int;

    func trackFrom(tracks: [TrackForUseType]) -> TrackForUseType {
        tracks.filter { t in t.id == track_id_from}[0]
    }
    func trackTo(tracks: [TrackForUseType]) -> TrackForUseType {
        tracks.filter { t in t.id == track_id_to}[0]
    }
}

struct PointType: Codable {
    let latitude: Double;
    let longitude: Double;

    init(latitude:Double, longitude: Double) {
        self.latitude = latitude;
        self.longitude = longitude;
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer();
        longitude = try container.decode(Double.self)
        latitude = try container.decode(Double.self)
    }
}

struct Places: Codable {
    let id: Int;
    let title: String;
    let description: String;
    let type_id: Int;
    let track_id: Int;
    var coord: [PointType];
}
