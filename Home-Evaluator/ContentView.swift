//
//  ContentView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan

struct ContentView: View {
    @State var isScanning: Bool = false
    @State var structureScanComplete: Bool = false
    @State var capturedRooms: [CapturedRoom] = []
    @ObservedObject var results: CapturedRoomScan = .init(capturedRooms: [])
    @ObservedObject var locManager = LocationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    /*  NavigationLink("", isActive: $isScanning) {
                     ScannerView(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results, locManager: locManager)
                     }*/
                    ListingCard(locationManger: locManager, listing: "2200 Waterview Pkwy")
                    
                    ListingCard(locationManger: locManager, listing: "13107 Boheme Dr")
                }
                .listStyle(.plain)
                .navigationTitle("Nebula Rooms")
                .toolbar {
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
                Button(action: {isScanning = true}, label: {
                    Label(
                        title: { Text("Start Scan") },
                        icon: { /*@START_MENU_TOKEN@*/Image(systemName: "42.circle")/*@END_MENU_TOKEN@*/ }
                    )
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
