//
//  Home.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/14/21.
//

import SwiftUI
import MapKit
import AVKit

struct MapPageRes: View {
    @State private var error: Bool = false;
    @State private var loading: Bool = true;
    @State private var showSheet: Bool = false;
    @State private var showNavigation: Bool = false;
    @State private var startingRegion = MKCoordinateRegion();

    @State private var searchText: String = "";

    @EnvironmentObject var GlobalState: GlobalStateController;


    var body: some View {
        ZStack {
            MapView(mapObj: GlobalState.mapView, myLocation: $GlobalState.myLocation, region: $startingRegion)
                    .printTracks(GlobalState.Tracks)
                    .printNavigationTrack(GlobalState)
                    .ignoresSafeArea()
            searchInput
            VStack {
                Spacer();
                if (showNavigation) {
                    NavigatorBlock()
                }
                HStack {
                    HStack {
                        Text("Refresh Realm").foregroundColor(.white).font(.headline).padding();
                    }.background(Color.black).cornerRadius(50).onTapGesture {
                        try! RealmObject.write {
                            RealmObject.deleteAll();
                            GlobalState.MainJsonData = Data();
                            GlobalState.Tracks = [];
                            GlobalState.Crossroads = [];

                            Init.loadTracks(GlobalState);
                        }
                    }

                    HStack {
                        Text("Toggle Navigation").foregroundColor(.white).font(.headline).padding();
                    }.background(Color.black).cornerRadius(50).onTapGesture {
                        showNavigation.toggle();
                    }
                }
            }
        }
    }

    var searchInput: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("asd", text: $searchText)
                    if searchText != "" {
                        Image(systemName: "xmark.circle.fill")
                                .imageScale(.medium)
                                .foregroundColor(Color(.systemGray3))
                                .padding(3)
                                .onTapGesture {
                                    withAnimation {
                                        self.searchText = ""
                                    }
                                }
                    }
                }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
            }.padding().background(Color.black)
            Spacer()
        }
    }
}


struct NavigatorBlock: View {
    @State var generatePaths: [[CrossroadType]]?;
    @State var spokeTurn_idTrack: Int = 0;

    @EnvironmentObject private var GlobalState: GlobalStateController;

    var body: some View {
        HStack {
                VStack {
                    Form {
                        Section(header: Text("Select place TO")) {
                            Picker("To:", selection: $GlobalState.navigationTo) {
                                ForEach(GlobalState.Tracks.filter {
                                    $0.id != GlobalState.myTrackByLocation?.id
                                }, id: \.id) { track in
                                    Text("(\(track.id)) \(track.name)").tag(track.id)
                                }
                            }.onChange(of: GlobalState.navigationTo) { (v) in
                                GlobalState.navigationTo = v;
                            }
                        }
                    }
                    list
                }
        }
            .frame(height: 300)
            .background(Color.red)
    }

    var list: some View {
        List {
            if (GlobalState.navigationPath.count > 0) {
                ForEach(GlobalState.navigationPath.indices, id: \.self) { i in
                    let item = GlobalState.navigationPath[i];
                    let from = i == 0 ? GlobalState.myIndexOnTrackByLocation! : GlobalState.navigationPath[i - 1].point_index_to

                    let distance = Int(MapController.getDistanceBetweenTwoIndexesOnTrack(
                        indexFrom: from,
                        indexTo: item.point_index,
                        track: item.trackFrom(tracks: GlobalState.Tracks)
                    ) * 1000);

                    Text("\(distance)m - \(item.trackFrom(tracks: GlobalState.Tracks).name) -> \(item.angle > 0 ? "Правый поворот" : "Левый поворот") -> \(item.trackTo(tracks: GlobalState.Tracks).name)").onAppear {
                        if (distance < 100 && i == 0 && spokeTurn_idTrack != item.track_id_from) {
                            let synthesizer = AVSpeechSynthesizer()
                            let utterance = AVSpeechUtterance(string: "\(item.angle > 0 ? "Правый поворот" : "Левый поворот") через \(distance) метров на улицу \(item.trackTo(tracks: GlobalState.Tracks).name)")
                            utterance.volume = 1;
                            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                            synthesizer.speak(utterance)
                            spokeTurn_idTrack = item.track_id_from;
                        }
                    }
                }
            }
        }.frame(height: 200)
    }
}


extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}