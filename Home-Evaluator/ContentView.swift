//
//  ContentView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan
import CoreLocation

struct ContentView: View {
    @State var isScanning: Bool = false
    @State var structureScanComplete: Bool = false
    @State var capturedRooms: [CapturedRoom] = []
    @ObservedObject var results: CapturedRoomScan = .init(capturedRooms: [])
    @ObservedObject var locManager = LocationManager()
    
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                List(defaultScans) { scan in
                    /*  NavigationLink("", isActive: $isScanning) {
                     ScannerView(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results, locManager: locManager)
                     }*/
                    ListingCard(locationManger: locManager, title: scan.title, streetAddr: scan.streetAddress ?? "", listing: scan.location)
                }
                .searchable(text: $searchText, prompt: "Search Properties...")
                .listStyle(.plain)
                .navigationTitle("Hex")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image("Hex")
                    }
                    ToolbarItemGroup(placement: .secondaryAction) {
                        Button(action: {print("hi")}, label: {Image(systemName: "gear")})
                    }
                    /*ToolbarItemGroup(placement: .bottomBar, content: {
                     Button(action: {isScanning = true}, label: {
                     Image(systemName: "plus")
                     .symbolVariant(.circle.fill)
                     .symbolRenderingMode(.hierarchical
                     )
                     })
                     .controlSize(.large)
                     })*/
                }
                .task {
                    locManager.checkAvailability()
                }
                .overlay(alignment: .bottom) {
                    NavigationLink(isActive: $isScanning, destination: {
                        ScannerView(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results, locManager: locManager)}, label: {
                            Button(action: {isScanning = true}, label: {
                                Label(
                                    title: { Text("Start Scan") },
                                    icon: { Image(systemName: "camera.viewfinder") }
                                )
                                .frame(width: 300, height: 30)
                            })
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(Color("HexPurple"))
                            //.frame(width: 50)
                            .padding()
                        })
                    
                }
            }
        }
    }
}

#Preview {
    ContentView(searchText: "")
}
