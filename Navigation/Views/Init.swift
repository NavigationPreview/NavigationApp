//
// Created by Maxim Krimskiy on 4/22/21.
//

import SwiftUI
import MapKit
import AVKit

struct Init: View {
    @EnvironmentObject var GlobalState: GlobalStateController;
    @State var errorLoadData: Bool = false;

    static func loadTracks(_ GlobalState: GlobalStateController, _ useCache: Bool = true) {
        TrackApi.getGetJsonByLocationId(locationId: 1)
                .useCache()
                .fetchData(failure: { error in print(error) }, { data in
                    print(data);
                    GlobalState.MainJsonData = data;
                    GlobalState.Tracks = decodeTracks(data: data);
                    GlobalState.Crossroads = getCrossroads(GlobalState.Tracks)
                })
    }

    var body: some View {
        switch (true) {
        case GlobalState.Tracks.count == 0:
            VStack {
                Preloader().frame(width: 100, height: 100)
                Text("Загрузка данных...")

            }
                    .onTapGesture {
                        try! RealmObject.write {
                            RealmObject.deleteAll();
                            GlobalState.MainJsonData = Data();
                            GlobalState.Tracks = [];
                            GlobalState.Crossroads = [];

                            Init.loadTracks(GlobalState);
                        }
                    }
                    .onAppear {
                        Init.loadTracks(GlobalState);
                    }
        default:
            MapPage()
        }
        if (GlobalState.Tracks.count == 0) {

        } else {

        }

    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
