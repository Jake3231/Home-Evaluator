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
    @State var demoCapturedRooms: [CapturedRoom] = []
    
    
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                List(defaultScans) { scan in
                    NavigationLink(destination: {
                        ReportView(capturedRooms: $demoCapturedRooms, result: .constant(scan), locationManager: locManager)
                            .task {
                                let room1 = Bundle.main.url(forResource: "Room-2DA4E699-B495-464B-AAA3-A7F1B291C4D3", withExtension: "json")!
                                guard let room = try? loadCapturedRoom(from: room1) else { return }
                                demoCapturedRooms.append(room)
                                let room2 = Bundle.main.url(forResource: "Room-B43E5ADE-6760-4543-9D81-3AA14ED725A8", withExtension: "json")!
                                guard let room = try? loadCapturedRoom(from: room2) else { return }
                                demoCapturedRooms.append(room)
                                /*let room3 = Bundle.main.url(forResource:  "Room-DAEA524F-82E9-4F74-9CF4-2574400EFF6E", withExtension: "json")!
                                guard let room = try? loadCapturedRoom(from: room3) else {return }
                                demoCapturedRooms.append(room)*/
                            }
                    }, label: {
                        ListingCard(locationManger: locManager, title: scan.title, streetAddr: scan.shortStreetAddress ?? "", listing: scan.location)
                    })
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
    
    private func loadCapturedRoom(from url: URL) throws -> CapturedRoom? {
        let jsonData = try? Data(contentsOf: url)
        guard let data = jsonData else { return nil }
        let capturedRoom = try? JSONDecoder().decode(CapturedRoom.self, from: data)
        return capturedRoom
    }
}

#Preview {
    ContentView(searchText: "")
}
