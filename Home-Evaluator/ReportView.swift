//
//  ReportView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan

struct ReportView: View {
    @Binding var capturedRooms: [CapturedRoom]
    var body: some View {
        Text("Rooms: \(capturedRooms.count)")
       /* List(capturedRooms.flatMap({$0.sections}) as! [CapturedRoom.Section], id: \.label) { section in
            Text(section.label.rawValue)
        }*/
        List(capturedRooms, id: \.identifier) { room in
                Section(room.identifier.uuidString) {
                    ForEach(room.sections, id: \.label) { section in
                        Text(section.label.rawValue)
                    }
                }
        }
    }
}

#Preview {
    ReportView(capturedRooms: .constant([]))
}
