//
//  ListingCard.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI

struct ListingCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .overlay {
                Text("Listing")
            }
    }
}

#Preview {
    ListingCard()
}
