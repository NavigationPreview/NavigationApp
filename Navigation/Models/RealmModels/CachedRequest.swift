//
//  CachedRequest.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/12/21.
//

import Foundation
import RealmSwift

class RealmCachedRequest: Object {
    @objc dynamic var key: String = "";
    @objc dynamic var value: String = "";
    @objc dynamic var data: Data = Data();
    @objc dynamic var timestamp: Date = Date();

    convenience init(key: String, value: String, timestamp: Date = Date()) {
        self.init();
        self.key = key;
        self.value = value;
        self.timestamp = timestamp;
    }

    convenience init(key: String, data: Data, timestamp: Date = Date()) {
        self.init();
        self.key = key;
        self.data = data;
        self.timestamp = timestamp;
    }

    override static func primaryKey() -> String? {
        "key"
    }
}
