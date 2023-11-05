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
                    ListingCard(locationManger: locManager, title: scan.title, streetAddr: scan.shortStreetAddress ?? "", listing: scan.location)
                }
                .searchable(text: $searchText, prompt: "Search Properties...")
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            Image("Hex")
                                .resizable()
                                .scaledToFit()
                                .padding(5)
                            Text("Hex")
                                .font(.largeTitle.bold())
                        }
                    }
                    ToolbarItemGroup(placement: .secondaryAction) {
                        Button(action: {print("settings")}, label: {
                            Image(systemName: "gear")})
                    }
                }
                .task {
                    locManager.checkAvailability()
                }
                VStack {
                    Spacer()
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 200)
                        .blur(radius: 50)
                }
                .padding([.bottom, .leading, .trailing], -30)
                .ignoresSafeArea(edges: .bottom)
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
