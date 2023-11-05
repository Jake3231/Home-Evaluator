//
//  AddressView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import MapKit

struct AddressView: View {
    @ObservedObject var locManager: LocationManager
    @State var image: UIImage
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 250)
               // .background(content: {Color.red})
               /* .overlay(alignment: .bottom, content: {
                    ZStack(alignment: .bottom) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 350)
                            .blur(radius: 20) /// blur the image
                            .padding(-20) /// expand the blur a bit to cover the edges
                            .clipped() /// prevent blur overflow
                    }})*/
               /* .overlay(alignment: .bottomLeading) {
                    Text(locManager.userAddress)
                        .font(.title.bold())
                        .foregroundStyle(Color.white)
                        .background(.ultraThinMaterial)
                        .task {
                            print(locManager.checkAvailability())
                            image = await locManager.getSnapshotForLocation()
                        }
                }*/
                .ignoresSafeArea(edges: .top)
            Text(locManager.userAddress)
                .font(.title.bold())
                .foregroundStyle(Color.white)
                .task {
                    print(locManager.checkAvailability())
                    image = await locManager.getSnapshotForLocation()
                }
                .padding(.top, 0)
            Spacer()
            Text("Is this your address?")
                .font(.system(size: 35))
                .padding([.bottom, .leading, .trailing])
                .padding(.top, -50)
            Button("Confirm") {
                
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .tint(.green)
            Button("Edit") {
                
            }
            .buttonStyle(.borderless)
            Spacer()
        }
    }
}

#Preview {
    AddressView(locManager: LocationManager(), image: UIImage())
}
