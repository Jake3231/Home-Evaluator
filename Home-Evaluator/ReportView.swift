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
import CoreLocation

struct ReportView: View {
    @Binding var capturedRooms: [CapturedRoom]
    @State var areaInSqFt: [String: Float] = [:]
    @State var totalArea: Float = 0.0
    @State var shouldShowFinalView: Bool = false
    //@State var scenes: [String:SCNScene] = [:]
    var address: String = ""
    var locationManager: LocationManager!
	@State var valueEstimate: Double = -1.0
	@State var model: MyTabularRegressor_1?
	@State var input: MyTabularRegressor_1Input? = MyTabularRegressor_1Input(PROPERTY_TYPE: "Single Family Residential", CITY: "Richardson", ZIP_OR_POSTAL_CODE: 78641.0, BEDS: 4.0, BATHS: 2.5, SQUARE_FEET: 2294.0, LOT_SIZE: 3000.0, YEAR_BUILT: 2018.0, __SQUARE_FEET: 169.14, HOA_MONTH: 30.0, LATITUDE: 30.634521, LONGITUDE: -97.849760)
    @State var readyForML: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("VALUATION")
                Text(valueEstimate, format: .currency(code: "USD"))
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text("BED/BATH")
                Text("4/2")
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text("TOTAL SQ. Ft")
                Text("\(totalArea) Sq ft")
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: readyForML) {
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
		
            CLGeocoder().reverseGeocodeLocation(locationManager.locManager.location!, completionHandler: {placemarks, error in
                let zip = placemarks?.first?.postalCode
                input?.ZIP_OR_POSTAL_CODE = try! Double.init(zip!, format: .number)
                input?.SQUARE_FEET = Double(totalArea)
			if let input = input {
                print(input.ZIP_OR_POSTAL_CODE)
                print(input.SQUARE_FEET)
				do {
					let output = try model.prediction(input: input)
					valueEstimate = output.PRICE
				} catch {
					print("Prediction error occured.", error)
				}
			}
            })
		}
        .padding(.bottom, 10)

        List(capturedRooms, id: \.identifier) { room in
            /* Section(content: {
             ForEach(room.sections, id: \.label) { section in
             //@State var modelReady: Bool = false
             Text(section.label.rawValue)
             }
             }, header: {*/
            //Text(String(areaInSqFt[room.identifier.uuidString] ?? 0.0) + " sq ft")
            Section("Rooms") {
                ReportRow(room: room, roomSqFt: areaInSqFt[room.identifier.uuidString] ?? 0.0)
                    .listRowSeparator(.hidden)
            }
            Section("My Insights") {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color("HexGray"))
                    .frame(height: 60)
                    .overlay {
                        HStack {
                            Text("This is a prompt we can ask?")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                    }
                    .listRowSeparator(.hidden)
                .tint(Color("HexPurple"))
                
                NavigationLink(isActive: $shouldShowFinalView, destination: {ChatView()}, label: {
                    Button(action: {shouldShowFinalView = true}, label: {
                        Label(
                            title: { Text("More Insights") },
                            icon: { Image(systemName: "lightbulb.max") }
                        )
                        .frame(width: 300, height: 30)
                    })
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(Color("HexPurple"))
                    .foregroundStyle(Color.white)
                    //.frame(width: 50)
                    .padding()
                        .listRowSeparator(.hidden)
                })
                
            }
            //  })
           /* DisclosureGroup(content: {
                ForEach(room.sections, id: \.label) { section in
                    //@State var modelReady: Bool = false
                    Text(section.label.rawValue)
                }
            }, label: {
                ReportRow(room: room, roomSqFt: areaInSqFt[room.identifier.uuidString] ?? 0.0)
            })*/
                .task {
                
                for floor in room.floors {
                    if (floor.category == .floor) {
                        print(floor.dimensions)
                        let areaEstimate = floor.dimensions.x * floor.dimensions.y
                        totalArea += areaEstimate * 10.7639
                        print("total area: \(totalArea)")
                        areaInSqFt[room.identifier.uuidString] =  (areaInSqFt[room.identifier.uuidString] ?? 0.0) + areaEstimate * 10.7639
                    }
                }
                readyForML = true
            }
        }
        .navigationTitle("2200 Waterview Pkwy")
        .listStyle(.plain)
        Spacer()
        NavigationLink(destination: SummaryView(totalEstimate: valueEstimate), isActive: $shouldShowFinalView, label: {
            Button("Continue") {
                shouldShowFinalView = true
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        })
    }
}

struct ReportRow: View {
    @State var modelReady: Bool = false
    var room: CapturedRoom
    @State var sceneURL: URL = URL(fileURLWithPath: "")
    @State var scene: SCNScene!
    var roomSqFt: Float
    
    var body: some View {
        HStack {
            if modelReady {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
                    .foregroundStyle(.black.secondary)
                    .overlay(alignment: .top) {
                        VStack {
                            SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                                //.ignoresSafeArea(edges: .top)
                                .frame(height: 150)
                                .clipped()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Room 1")
                                        .font(.title3)
                                    Text("\(roomSqFt) SQ FT")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading)
                                Spacer()
                            }
                        }
                        .clipped()
                    }
                    .frame(height: 210)
                    .clipped()
            } else {
               ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 140, height: 130)
                    .task {
                        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
                        let destinationURL = destinationFolderURL.appending(path: "Room-\(room.identifier.uuidString).usdz")
                        //sceneURL = destinationURL
                        try! room.export(to: destinationURL)
                        scene = try! SCNScene(url: destinationURL, options: [.checkConsistency: true])
                        modelReady = true
                        print("model ready")
                    }
            }
            //Button()
        }
    }
}

#Preview {
    ReportView(capturedRooms: .constant([]))
}
