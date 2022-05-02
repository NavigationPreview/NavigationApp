//
//  Request.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/6/21.
//

import Foundation
import Alamofire
import RealmSwift

class Request {
    private var url: String;
    private var data: [String: Any];
    private var method: HTTPMethod;

    private var useCacheFlag = false;

    init(
        url: String,
        data: [String: Any] = [:],
        method: HTTPMethod = .post
    ) {
        self.url = url;
        self.data = data;
        self.method = method;
    }

    public func useCache() -> Request {
        print("Use cache")
        useCacheFlag = true;
        return self;
    }

    private func setToCache(key: String, data: Data) {
        let obj = RealmObject.object(ofType: RealmCachedRequest.self, forPrimaryKey: "\(key)");
        if (obj != nil) {
            try! RealmObject.write {
                obj?.data = data;
            }
            print("Update cache")
            return;
        }
        let task = RealmCachedRequest(key: "\(key)", data: data)
        try! RealmObject.write {
            RealmObject.add(task)
        }
        print("Create cache")
    }

    private func getFromCache(_ key: String) -> Data {
        let row = RealmObject.object(ofType: RealmCachedRequest.self, forPrimaryKey: key)

        if (row == nil) {
            return Data();
        }

        print("Fetch from cache")
        return row!.data;
    }

    func fetchJSON(_ completion: ((_ response: AFDataResponse<Any>) -> Void)? = nil, _ failure: ((_ response: AFError) -> Void)? = nil) {
        AF
            .request(url, method: method, parameters: data)
            .responseJSON { response in
                if completion != nil {
                    completion?(response);
                }
            };
    }

    func fetchData(failure: ((_ response: AFError) -> Void)? = nil, _ success: ((_ response: Data) -> Void)? = nil) {
        if (useCacheFlag) {
            let data = getFromCache("\(url)-\(Constants.API.cacheVersion)");
            if (data.count > 0) {
                if success != nil {
                    success?(data);
                }
                return
            }
        }


        AF
            .request(url, method: method, parameters: data)
            .responseData { response in
                print("Request from Network")
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)")
//                }
                switch response.result {
                case .success(let value):
                    if (self.useCacheFlag) {
                        self.setToCache(key: "\(self.url)-\(Constants.API.cacheVersion)", data: value)
                    }
                    if success != nil {
                        success?(value);
                    }

                case .failure(let error):
                    if failure != nil {
                        failure?(error);
                    }
                };
            }
    }
}
