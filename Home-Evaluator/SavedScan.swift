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
    SavedScan(location: CLLocation(latitude: 32.99051, longitude: -96.75474), title: "UV Apartment", streetAddress: "2200 Waterview Pkwy", streetViewImage: nil)
]
