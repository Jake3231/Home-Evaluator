//
//  ReportView.swift
//  Home-Evaluator
//
//  Created by Jake Spann on 11/4/23.
//

import SwiftUI
import RoomPlan
import SceneKit
import CoreML

struct ReportView: View {
    @Binding var capturedRooms: [CapturedRoom]
    @State var areaInSqFt: [String: Float] = [:]
    @State var scenes: [String:URL] = [:]
    var address: String = ""
	@State var valueEstimate: Double = -1.0
	@State var model: MyTabularRegressor_1?
	@State var input: MyTabularRegressor_1Input? = MyTabularRegressor_1Input(PROPERTY_TYPE: "Single Family Residential", CITY: "Richardson", ZIP_OR_POSTAL_CODE: 78641.0, BEDS: 4.0, BATHS: 2.5, SQUARE_FEET: 2294.0, LOT_SIZE: 3000.0, YEAR_BUILT: 2018.0, __SQUARE_FEET: 169.14, HOA_MONTH: 30.0, LATITUDE: 30.634521, LONGITUDE: -97.849760)
    
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
        

		Text("Estimate: \(valueEstimate, specifier: "%.2f")").task {
			if model == nil {
				let config = MLModelConfiguration()
				config.computeUnits = .all
				
				do {
					model = try MyTabularRegressor_1(configuration: config)
				} catch {
					print("Model instantiation failed.", error)
				}
			}
			
			guard let model = model else {
				return
			}
		
			if let input = input {
				do {
					let output = try model.prediction(input: input)
					valueEstimate = output.PRICE
				} catch {
					print("Prediction error occured.", error)
				}
			}
		}

        List(capturedRooms, id: \.identifier) { room in
            Section(content: {
                ForEach(room.sections, id: \.label) { section in
                    //@State var modelReady: Bool = false
                    ReportRow(room: room)
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

struct ReportRow: View {
    @State var modelReady: Bool = false
    var room: CapturedRoom
    @State var sceneURL: URL = URL(fileURLWithPath: "")
    
    var body: some View {
        HStack {
            if modelReady {
                SceneView(scene: try! SCNScene(url: sceneURL, options: [.checkConsistency: true]))
            } else {
                Rectangle()
                    .foregroundStyle(Color.orange)
                    .frame(width: 20, height: 20)
                    .task {
                        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
                        let destinationURL = destinationFolderURL.appending(path: "Room-\(room.identifier.uuidString).usdz")
                        sceneURL = destinationURL
                        try! room.export(to: destinationURL)
                        modelReady = true
                        print("model ready")
                    }
            }
            Text("section.label.rawValue")
        }
    }
}

#Preview {
    ReportView(capturedRooms: .constant([]))
}
