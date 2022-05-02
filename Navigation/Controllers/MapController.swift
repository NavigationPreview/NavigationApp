//
// Created by Maxim Krimskiy on 4/20/21.
//

import MapKit

struct MapController {
    func getNearestTrack(point: PointType, tracks: [TrackForUseType]) -> (TrackForUseType, Double) {
        var minimalDistanceIndex: Int = 0;
        var minimalDistanceTrack: TrackForUseType = tracks[minimalDistanceIndex];
        let (_, firstDistance, _) = getNearestPoint(point: point, pointsList: minimalDistanceTrack.points);
        var minimalDistance = firstDistance;

        for (currentIndex, currentTrack) in tracks.enumerated() {
            let (_, currentDistance, _) = getNearestPoint(point: point, pointsList: currentTrack.points);

            if (currentDistance < minimalDistance) {
                minimalDistance = currentDistance;
                minimalDistanceTrack = currentTrack;
                minimalDistanceIndex = currentIndex;
            }
        }

        return (minimalDistanceTrack, minimalDistance);
    }

    func getNearestPoint(point: PointType, pointsList: [PointType]) -> (PointType, Double, Int) {
        var minimalDistanceIndex: Int = 0;
        var minimalDistancePoint: PointType = pointsList[minimalDistanceIndex];
        var minimalDistance: Double = getDistanceBetweenTwoPoints(coordinateFrom: minimalDistancePoint, coordinateTo: point);

        for (currentIndex, currentPoint) in pointsList.enumerated() {
            let currentDistance: Double = getDistanceBetweenTwoPoints(coordinateFrom: currentPoint, coordinateTo: point)
            if (currentDistance < minimalDistance) {
                minimalDistanceIndex = currentIndex
                minimalDistancePoint = currentPoint;
                minimalDistance = currentDistance;
            }
        }

        return (minimalDistancePoint, minimalDistance, minimalDistanceIndex);
    }

    func getDistanceBetweenTwoPoints(coordinateFrom: PointType, coordinateTo: PointType) -> Double {

        let earthRadius: Double = 6371;

        func degreesToRadians(_ degrees: Double) -> Double {
            degrees * (Double.pi / 180)
        }

        func radiansToDegrees(_ radians: Double) -> Double {
            radians * (180 / Double.pi)
        }

        func centralSubtendedAngle(point1: PointType, point2: PointType) -> Double {
            let locationXLatRadians = degreesToRadians(point1.latitude);
            let locationYLatRadians = degreesToRadians(point2.latitude);

            let a = sin(locationXLatRadians) * sin(locationYLatRadians);
            let b = cos(degreesToRadians(abs(point1.longitude - point2.longitude)));
            let c = cos(locationXLatRadians) * cos(locationYLatRadians) * b;
            return radiansToDegrees(acos(a + c));
        }

        func greatCircleDistance(_ angle: Double) -> Double {
            2 * Double.pi * earthRadius * (angle / 360);
        }

        func distanceBetweenLocations(point1: PointType, point2: PointType) -> Double {
            greatCircleDistance(centralSubtendedAngle(point1: point1, point2: point2));
        }

        return distanceBetweenLocations(point1: coordinateFrom, point2: coordinateTo);
    }

    static func getDistanceBetweenTwoIndexesOnTrack(indexFrom: Int, indexTo: Int, track: TrackForUseType) -> Double {
        var distance = 0.0;

        if (indexTo <= indexFrom) {
            return distance;
        }
        
        for i in (indexFrom..<indexTo) {
            if (track.points.count - 2 < i) {
                continue;
            }
            distance += MapController().getDistanceBetweenTwoPoints(coordinateFrom: track.points[i], coordinateTo: track.points[i+1])
        }

        return distance;
    }
}
