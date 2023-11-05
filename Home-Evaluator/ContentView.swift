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

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Listing1", isActive: $isScanning) {
                    RoomScanViewController(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results)
                        .navigationBarHidden(true)
                        .overlay {
                            HStack {
                                Button(isScanning ? "Finish Room" : "Begin Room") {
                                    isScanning.toggle()
                                }
                                .buttonStyle(.bordered)
                                
                                NavigationLink(isActive: $structureScanComplete, destination: {ReportView(capturedRooms: $results.capturedRooms)}) {
                                    Button("finish") {
                                        structureScanComplete = true
                                        isScanning = false
                                    }
                                    .buttonStyle(.bordered)
                                    
                                }
                            }
                        }
                            }
                    Text("Listing2")
            }
            .listStyle(.plain)
            .navigationTitle("App Name")
            .toolbar {
               // Button(action: {print("hi")}, label: {Image(systemName: "gear")})
                ToolbarItemGroup(placement: .bottomBar, content: {
                    Button(action: {isScanning = true}, label: {
                        Image(systemName: "plus")
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.hierarchical
                            )
                    })
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
