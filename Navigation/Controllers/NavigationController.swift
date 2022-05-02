//
// Created by Maxim Krimskiy on 4/20/21.
//

import MapKit

struct NavigationController {
    private var database: [Int: [CrossroadType]];
    private var startKey: Int;
    private var endKey: Int;

    private var result: [[Int]] = [];
    var resultCrossroads: [[CrossroadType]] = [];

    func sortResultCrossroads(tracks: [TrackForUseType], myIndexOnTrackByLocation: Int) -> [[CrossroadType]] {
        func distance(_ crossroads: [CrossroadType]) -> Double {
            var sum = 0.0;
            for i in (0..<crossroads.count) {
                let item = crossroads[i];
                let from = i == 0 ? myIndexOnTrackByLocation : crossroads[i - 1].point_index_to


                let distance = MapController.getDistanceBetweenTwoIndexesOnTrack(
                    indexFrom: from,
                    indexTo: item.point_index,
                    track: item.trackFrom(tracks: tracks)
                );
                sum += distance;
            }

            return sum
        }


        return resultCrossroads.sorted(by: { distance($0) < distance($1) })
    };
    private var breakCounter = 0

    init(startKey: Int, endKey: Int, database: [CrossroadType], startIndexOnTrack: Int = 0) {
        self.startKey = startKey;
        self.endKey = endKey;

        var result: [Int: [CrossroadType]] = [:];

        database.forEach { item in
            if (result[item.track_id_from] == nil) {
                result[item.track_id_from] = [];
            }
            result[item.track_id_from]?.append(item);
        }

        self.database = result;

        _ = recursive(obj: self.database[startKey] ?? [], lastIndex: [startKey: startIndexOnTrack])

        getCrossroads(crossroadsList: database);
    }

    private mutating func getCrossroads(crossroadsList: [CrossroadType]) {
        result.forEach { r in
            var tempArray: [CrossroadType] = [];
            for i in 0..<r.count - 1 {
                let from = r[i]
                let to = r[i + 1]

                crossroadsList.forEach { crossroad in
                    if (crossroad.track_id_to == to && crossroad.track_id_from == from) {
                        tempArray.append(crossroad);
                    }
                }
            }
            resultCrossroads.append(tempArray)
        }
    }

    mutating func recursive(obj: [CrossroadType], path: [Int] = [], used: [Int] = [], lastIndex: [Int: Int] = [:]) -> [Int] {
        let obj: [CrossroadType] = obj;
        var path: [Int] = path;
        var used: [Int] = used;
        var lastIndex: [Int: Int] = lastIndex;

        if (breakCounter >= 1000) {
            return [];
        }

        if obj.count == 0 {
            return path;
        }

        for (value) in obj {
            breakCounter += 1;

            if (value.track_id_from == startKey) {
                path = [];
                used = [];
            }

            if (used.filter({ $0 == value.track_id_from }).count > 0) {
                path = Array(path.split(separator: value.track_id_from)[0]);
            }

            used.append(value.track_id_from);

            if path.contains(value.track_id_to) {
                continue;
            }

            if (value.point_index < lastIndex[value.track_id_from] ?? 0) {
                continue;
            }

            lastIndex[value.track_id_to] = value.point_index_to;

            path.append(value.track_id_from);
            if (value.track_id_to == endKey) {
                path.append(endKey);
                result.append(path);
            }

            path = recursive(obj: database[value.track_id_to] ?? [], path: path, lastIndex: lastIndex);
        }
        return path;
    }
}
