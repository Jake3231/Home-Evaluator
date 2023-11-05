//
//  ReportView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan
import SceneKit

struct ReportView: View {
    @Binding var capturedRooms: [CapturedRoom]
    @State var areaInSqFt: [String: Float] = [:]
    
    var body: some View {
        /*List(capturedRooms.flatMap({$0.sections}) as! [CapturedRoom.Section], id: \.label) { section in
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .overlay {
                    VStack {
                        Text(section.label.rawValue)
                        /*Text("\(areaInSqFt) sq ft")
                            .task {
                                for floor in section.1 {
                                    if (floor.category == .floor) {
                                        print(floor.dimensions)
                                        let areaEstimate = floor.dimensions.x * floor.dimensions.y
                                        areaInSqFt = areaEstimate * 10.7639
                                    }
                                }
                            }*/
                    }
                }
            //Text(section.label.rawValue)
        }*/
        List(capturedRooms, id: \.identifier) { room in
            Section(content: {
                ForEach(room.sections, id: \.label) { section in
                    HStack {
                        Rectangle()
                            .foregroundStyle(Color.orange)
                            .frame(width: 20, height: 20)
                        Text(section.label.rawValue)
                    }
                }
            }, header: {
                Text(String(areaInSqFt[room.identifier.uuidString] ?? 0.0) + " sq ft")
            }).task {
                    for floor in room.floors {
                        if (floor.category == .floor) {
                            print(floor.dimensions)
                            let areaEstimate = floor.dimensions.x * floor.dimensions.y
                            areaInSqFt[room.identifier.uuidString] =  (areaInSqFt[room.identifier.uuidString] ?? 0.0) + areaEstimate * 10.7639
                        }
                    }
                }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ReportView(capturedRooms: .constant([]))
}
