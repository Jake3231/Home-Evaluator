//
//  ScannerView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan
import CoreLocation

struct ScannerView: View {
    @Binding var isScanning: Bool
    @Binding var structureScanComplete: Bool
   // @Binding var capturedRooms: [CapturedRoom]
    @ObservedObject var results: CapturedRoomScan = .init(capturedRooms: [])
    var locManager: LocationManager!
    @State var result: SavedScan = SavedScan(location: CLLocation())
    
    var body: some View {
        RoomScanViewController(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results)
            //.navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .navigationBarBackButtonHidden()
            .overlay(alignment: .bottom) {
                HStack {
                   Button(isScanning ? "Finish Room" : "Begin Room") {
                        isScanning.toggle()
                    }
                    .buttonStyle(.bordered)
                    /*Button(action: {}, label: {
                        Circle()
                            .frame(width: 90, height: 90)
                    })
                    .padding(.bottom, 200)*/
                    
                  /*  NavigationLink(isActive: $structureScanComplete, destination: {
                        ReportView(capturedRooms: $results.capturedRooms)
                       // AddressView(locManager: locManager, image: UIImage())
                    }) {
                        Button("Complete Scan") {
                            structureScanComplete = true
                            isScanning = false
                        }
                        .buttonStyle(.bordered)
                        
                    }*/
                }
               /* .sheet(isPresented: $structureScanComplete, content: {
                    //AddressView(locManager: locManager, image: UIImage(), capturedRooms: $results.capturedRooms)
                    //ReportView(capturedRooms: $results.capturedRooms, locationManager: locManager)
                    SummaryView()
                })*/
                .toolbar {
                    NavigationLink(isActive: $structureScanComplete, destination: {
                        ReportView(capturedRooms: $results.capturedRooms, result: $result, locationManager: locManager)
                    }) {
                        Button("Complete Scan") {
                            structureScanComplete = true
                            isScanning = false
                            result = SavedScan(location: locManager.locManager.location!, title: "Title", shortStreetAddress: locManager.userAddress, fullStreetAddress: locManager.fullAddress, streetViewImage: nil)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
    }
}

#Preview {
    ScannerView(isScanning: .constant(true), structureScanComplete: .constant(false), locManager: LocationManager())
}
