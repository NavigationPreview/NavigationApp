//
//  Constants.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/7/21.
//

import Foundation
import RealmSwift;

struct Constants {
    struct Application {
        static let version : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString");
        static let build : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion");
    }

    struct API {
        static let apiUrl = "http://185.69.154.122:8081/api";
        static let baseUrl = "http:/185.69.154.122:8081";
        static let cacheVersion = "1";
    }
}

let RealmObject = try! Realm(configuration: Realm.Configuration(schemaVersion: 1));
