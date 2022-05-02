//
//  Track.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/7/21.
//

import Foundation

struct TrackApi {
    static func getGetJsonByLocationId(locationId: Int) -> Request {
        Request(
            url: "\(Constants.API.apiUrl)/get-track-list-geoJSON-by-loc",
            data: ["location_id": locationId],
            method: .get
        )
    }

    static func getTrackList() -> Request {
        Request(
            url: "\(Constants.API.apiUrl)/get-track-list-names",
            data: [:],
            method: .get
        )
    }
}
