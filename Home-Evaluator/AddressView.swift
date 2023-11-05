//
//  AddressView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import MapKit
import RoomPlan

struct AddressView: View {
    @ObservedObject var locManager: LocationManager
    @State var image: UIImage
    @State var addrString: String = ""
    @Binding var capturedRooms: [CapturedRoom]

    var body: some View {
        VStack {
            Text("Confirm Location")
                .font(.title3)
                .padding(.top, 20)
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
               /* .overlay(alignment: .top) {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 80)
                        .blur(radius: 60)
                }*/
            TextField("Address", text: $addrString)
                .textFieldStyle(.roundedBorder)
                .padding([.top, .leading, .trailing])
                .task {
                    addrString = locManager.userAddress
                }
                .task {
                    image = await locManager.getSnapshotForLocation()
                }
            Spacer()
            NavigationLink(destination: ReportView(capturedRooms: $capturedRooms), label: {
                Button("Confirm Address") {
                    
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            })
        }
        //ListingCard(image: image, listing: locManager.locManager.location!)
    }
}

#Preview {
    AddressView(locManager: LocationManager(), image: UIImage(), capturedRooms: .constant([]))
}
