//
//  ListingCard.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import CoreLocation

struct ListingCard: View {
    var locationManger: LocationManager!
    @State var image: UIImage = UIImage()
    @State var title: String = "Title"
    @State var streetAddr: String = "Address unknown"
    var listing: CLLocation
    
    var body: some View {
            RoundedRectangle(cornerRadius: 10, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .foregroundStyle(.background.secondary)
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 80)
                        .blur(radius: 60)
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title.bold())
                        Label(title: {
                            Text(streetAddr)
                        }, icon: {Image(systemName: "mappin.circle")})
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(10)
                }
                .task {
                    image = await locationManger.getSnapshotFor(address: listing)
                }
        .frame(height: 210)
        .listRowSeparator(.hidden, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ListingCard(locationManger: LocationManager(), image: UIImage(), listing: CLLocation())
}
