//
//  SavedScan.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/5/23.
//

import Foundation
import CoreLocation

struct SavedScan: Identifiable {
    var id: String {streetAddress ?? ""}
    var location: CLLocation
    var title: String = "Scan"
    var streetAddress: String?
    var streetViewImage: Data?
}

let defaultScans: [SavedScan] = [
    SavedScan(location: CLLocation(latitude: 32.98454, longitude: -96.75188), title: "UV Apartment", streetAddress: "2200 Waterview Pkwy", streetViewImage: nil),
    SavedScan(location: CLLocation(latitude: 32.99051, longitude: -96.75474), title: "Res Hall West", streetAddress: "955 N Loop Rd", streetViewImage: nil),
    SavedScan(location: CLLocation(latitude: 32.98601, longitude: -96.75415), title: "UV 2", streetAddress: "2600 Waterview Pkwy", streetViewImage: nil)
]
