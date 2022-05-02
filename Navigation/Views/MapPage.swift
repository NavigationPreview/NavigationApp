//
//  Home.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/14/21.
//

import SwiftUI
import MapKit
import AVKit

struct MapPage: View {
    @EnvironmentObject var GlobalState: GlobalStateController;
    @State private var searchText: String = "";
    @State private var spokeTurn_idTrack: Int = 0;

    @State private var startingRegion = MKCoordinateRegion();

    func zoom(_ zoomin: Bool) {
        var region = GlobalState.mapView.region;
        var span = MKCoordinateSpan();
        span.latitudeDelta = zoomin ? region.span.latitudeDelta / 2 : region.span.latitudeDelta * 2;
        span.longitudeDelta = zoomin ? region.span.longitudeDelta / 2 : region.span.longitudeDelta * 2;
        region.span = span;

        GlobalState.mapView.setRegion(region, animated: true);
    }

    var body: some View {
        ZStack {
            MapView(mapObj: GlobalState.mapView, myLocation: $GlobalState.myLocation, region: $startingRegion)
                    .printTracks(GlobalState.Tracks)
                    .printNavigationTrack(GlobalState)
                    .edgesIgnoringSafeArea(.all)

            HStack {
                VStack {
                    Spacer()
                    HStack {
                        Text("Refresh Realm")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding();
                    }
                            .background(Color(.systemBackground))
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                try! RealmObject.write {
                                    RealmObject.deleteAll();
                                    GlobalState.MainJsonData = Data();
                                    GlobalState.Tracks = [];
                                    GlobalState.Crossroads = [];

                                    Init.loadTracks(GlobalState);
                                }
                            }
                            .padding()
                            .padding(.bottom, 20)
                }
                Spacer()
            }

            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "plus")
                            .frame(width: 25, height: 25)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                zoom(true)
                            }
                    Image(systemName: "minus")
                            .frame(width: 25, height: 25)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                zoom(false)
                            }
                }
            }
                    .padding()
                    .padding(.bottom, 20)
                    .foregroundColor(Color(.label))
            VStack {
                VStack {
                    if (GlobalState.navigationTo > 0 && GlobalState.navigationPath.count > 0) {
                        VStack {
                            Text(GlobalState.Tracks.filter { type in
                                type.id == GlobalState.navigationTo
                            }[0].name)
                                    .padding(.bottom)
                                    .font(.title)

                            let item = GlobalState.navigationPath[0];
                            let from = GlobalState.myIndexOnTrackByLocation!

                            let distance = Int(MapController.getDistanceBetweenTwoIndexesOnTrack(
                                    indexFrom: from,
                                    indexTo: item.point_index,
                                    track: item.trackFrom(tracks: GlobalState.Tracks)
                            ) * 1000);

                            if (distance < 100 && spokeTurn_idTrack != item.track_id_from) {
                                VStack {
                                }.onAppear {
                                    let synthesizer = AVSpeechSynthesizer()
                                    let utterance = AVSpeechUtterance(string: "\(item.angle > 0 ? "Правый поворот" : "Левый поворот") через \(distance) метров на улицу \(item.trackTo(tracks: GlobalState.Tracks).name)")
                                    utterance.volume = 1;
                                    utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                                    synthesizer.speak(utterance)
                                    spokeTurn_idTrack = item.track_id_from;
                                }
                            }

                            HStack {
                                VStack {
                                    Image(systemName: item.angle > 0 ? "arrow.turn.up.right" : "arrow.turn.up.left")
                                            .font(.largeTitle)

                                    Text("Через \(distance)м")
                                            .padding(.top)
                                            .font(.caption)
                                }

                                Text("Поворот на \(item.trackTo(tracks: GlobalState.Tracks).name)")
                                        .frame(maxWidth: .infinity)
                                        .font(.headline)
                            }
                        }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .onTapGesture {
                                    withAnimation {
                                        print("Open list")
                                    }
                                }
                    } else {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextFieldPlaceholderColor(placeholder: Text("Поиск..."), text: $searchText.animation())
                                    .onChange(of: searchText) { a in
                                        if (a != "") {
                                            withAnimation {
                                                GlobalState.navigationTo = 0;
                                            }
                                        }
                                    }
                            if searchText != "" {
                                Image(systemName: "xmark.circle.fill")
                                        .imageScale(.medium)
                                        .onTapGesture {
                                            withAnimation {
                                                self.searchText = ""
                                            }
                                        }
                            }
                        }.padding()
                    }
                    if (GlobalState.navigationTo > 0 && GlobalState.navigationPath.count == 0) {
                        VStack {
                            Text("Маршрут не найден")
                                    .font(.headline)
                        }.padding(.bottom)
                    } else if (searchText != "") {
                        ScrollView {
                            LazyVStack {
                                let list = GlobalState.Tracks.filter {
                                    $0.id != GlobalState.myTrackByLocation?.id &&
                                            $0.name.lowercased().contains(searchText.lowercased())
                                };

                                if (list.count > 0) {
                                    ForEach(list, id: \.id) { value in
                                        ZStack {
                                            Color(.systemGray6)
                                                    .cornerRadius(15)
                                            HStack {
                                                HStack() {
                                                    Image(systemName: "mappin.circle")
                                                    Text("\(value.name)")
                                                    Spacer()
                                                }
                                            }.padding()
                                        }
                                                .fixedSize(horizontal: false, vertical: true)
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                                .padding(.vertical)
                                                .padding(.horizontal)
                                                .onTapGesture {
                                                    withAnimation {
                                                        GlobalState.navigationTo = value.id;
                                                        searchText = "";
                                                    }
                                                }
                                    }
                                } else {
                                    Text("Места не найдены")
                                            .font(.headline)
                                }
                            }
                        }
                    }
                }
                        .foregroundColor(Color(.label))
                        .background(Color(.systemBackground))
                        .cornerRadius(25)
                        .padding([.horizontal, .top])
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                if (GlobalState.navigationTo > 0 && GlobalState.navigationPath.count > 0) {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                                .padding(10)
                                .imageScale(.medium)
                                .foregroundColor(Color(.label))
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                    }
                            .padding(.trailing)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                withAnimation {
                                    self.searchText = ""
                                    GlobalState.navigationTo = 0;
                                }
                            }
                }
                Spacer()
            }
        }
    }
}
