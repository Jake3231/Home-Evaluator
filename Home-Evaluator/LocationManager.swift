//
//  LocationManager.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locManager = CLLocationManager()
    
    @Published var userAddress: String = ""
    @Published var fullAddress: String = ""
    
    func checkAvailability() -> Bool {
        locManager.requestAlwaysAuthorization()
        locManager.delegate = self
        locManager.requestLocation()
        return locManager.authorizationStatus == .authorizedWhenInUse || locManager.authorizationStatus == .authorizedAlways
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got location update")
        if let location = locations.last {
            // withCheckedContinuation { continuation in
            //locManager.requestLocation()
                CLGeocoder().reverseGeocodeLocation(locManager.location!, completionHandler: {placemarks, error in
                    if let place = placemarks?.first {
                        if let place = placemarks?.first {
                            let address = [
                                place.subThoroughfare,
                                place.thoroughfare,
                                place.locality,
                                place.administrativeArea,
                                place.postalCode,
                                place.country
                            ]
                            
                            self.fullAddress = address.compactMap({ $0 }).joined(separator: " ")
                            print("SET SELF FULL ADDR TO \(self.fullAddress)")
                        }
                        self.userAddress = (placemarks?.first?.subThoroughfare ?? "") + " " + (placemarks?.first?.thoroughfare ?? "")
                    }
                })
            }
        //}
    }
    
    func getSnapshotForLocation() async -> UIImage {
        var image: UIImage!
        await withCheckedContinuation { continuation in
            let request = MKLookAroundSceneRequest(coordinate: locManager.location!.coordinate)
            request.getSceneWithCompletionHandler{scene, error in
                let options = MKLookAroundSnapshotter.Options()
                options.pointOfInterestFilter = .excludingAll
                MKLookAroundSnapshotter(scene: scene!, options: options).getSnapshotWithCompletionHandler({snapshot, error in
                   image = snapshot?.image
                    continuation.resume()
                })
            }
        }
        return image
    }
    
    func getSnapshotFor(address: CLLocation) async -> UIImage {
        var image: UIImage!
        await withCheckedContinuation { continuation in
            print(address.coordinate.longitude)
            let request = MKLookAroundSceneRequest(coordinate: address.coordinate)
            request.getSceneWithCompletionHandler{scene, error in
                let options = MKLookAroundSnapshotter.Options()
                options.pointOfInterestFilter = .excludingAll
                MKLookAroundSnapshotter(scene: scene!, options: options).getSnapshotWithCompletionHandler({snapshot, error in
                   image = snapshot?.image
                    continuation.resume()
                })
            }
        }
        return image
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("loc did fail")
        print(error)
    }
    
    func userAddressForGPT() async -> String? {
        var userAddr: String?
        await withCheckedContinuation { continuation in
            locManager.requestLocation()
            CLGeocoder().reverseGeocodeLocation(locManager.location!, completionHandler: {placemarks, error in
                if let place = placemarks?.first {
                    let address = [
                        place.name,
                        place.locality,
                        place.administrativeArea,
                        place.postalCode,
                        place.country
                    ]
                    
                    userAddr = address.compactMap({ $0 }).joined(separator: " ")
                }
                continuation.resume()
            })
        }
        return userAddr
    }
    
    
}
