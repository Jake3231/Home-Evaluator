//
//  SummaryView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/5/23.
//

import SwiftUI
import CoreLocation

struct SummaryView: View {
    @State var totalEstimate: Double = 0.0
    var body: some View {
        VStack {
            ListingCard(locationManger: LocationManager(), title: "Title", streetAddr: "2200 Waterview Pkwy", listing: CLLocation(latitude: 32.98601, longitude: -96.75415))
                .ignoresSafeArea(edges: .top)
            VStack(alignment: .center) {
                Text(totalEstimate, format: .currency(code: "USD"))
                    .font(.system(size: 60))
                    .foregroundStyle(Color.green)
                Text("Estimated property value")
                    .font(.subheadline)
            }
            .padding(.top, -10)
            Divider()
            VStack {
                Text("2  Bathrooms")
                    .padding()
                Text("2  Bedrooms")
                    .padding()
                Text("1  Living room")
                    .padding()
            }
            .padding()
            
            Button("Understand this Estimate") {
                
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(.green)
            Spacer()
        }
    }
}

#Preview {
    SummaryView()
}
