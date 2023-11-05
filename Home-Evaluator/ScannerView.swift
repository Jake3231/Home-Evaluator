//
//  ScannerView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan

struct ScannerView: View {
    @Binding var isScanning: Bool
    @Binding var structureScanComplete: Bool
   // @Binding var capturedRooms: [CapturedRoom]
    @ObservedObject var results: CapturedRoomScan = .init(capturedRooms: [])
    var locManager: LocationManager!
    
    var body: some View {
        RoomScanViewController(isScanning: $isScanning, structureScanComplete: $structureScanComplete, results: results)
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                HStack {
                    Button(isScanning ? "Finish Room" : "Begin Room") {
                        isScanning.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    NavigationLink(isActive: $structureScanComplete, destination: {
                        ReportView(capturedRooms: $results.capturedRooms)
                       // AddressView(locManager: locManager, image: UIImage())
                    }) {
                        Button("finish") {
                            structureScanComplete = true
                            isScanning = false
                        }
                        .buttonStyle(.bordered)
                        
                    }
                }
            }
    }
}

#Preview {
    ScannerView(isScanning: .constant(true), structureScanComplete: .constant(false), locManager: LocationManager())
}
