//
//  RoomDetailsView.swift
//  Home-Evaluator
//
//  Created by Jason Antwi-Appah on 11/5/23.
//

import SwiftUI
import RoomPlan
import SceneKit

struct RoomDetailsView: View {
	@State var room: CapturedRoom?
	@State var modelReady: Bool!
	@State var sceneURL: URL!
	@State var scene: SCNScene!
	var roomSqFt: Float = 0.0
	
	var body: some View {
		ScrollView {
			VStack {
				if modelReady {
					RoundedRectangle(cornerRadius: 0)
						.foregroundStyle(.black.secondary)
						.overlay(alignment: .top) {
							SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
								.frame(height: 150)
								.clipped()
						}
						.frame(height: 210)
						.clipped()
				} else {
					ProgressView()
						.progressViewStyle(.circular)
						.frame(width: 140, height: 130)
						.task {
							if let room = room {
								let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
								let destinationURL = destinationFolderURL.appending(path: "Room-\(room.identifier.uuidString).usdz")
								sceneURL = destinationURL
								print("loaded url")
							} else {
								print("missing room")
							}
							
							if (sceneURL != URL(fileURLWithPath: "")) {
								scene = try! SCNScene(url: sceneURL, options: [.checkConsistency: true])
								modelReady = true
								
								print("model ready")
							}
						}
				}
				HStack {
					VStack(alignment: .leading) {
						Text("TYPE")
							.font(.title3)
						Text(room?.sections[0].label.rawValue ?? "Other")
							.foregroundStyle(.secondary)
					}
					.padding(.leading)
					Spacer()
					VStack(alignment: .leading) {
						Text("SQ. FT")
							.font(.title3)
						Text("\(roomSqFt)")
							.foregroundStyle(.secondary)
					}
					.padding(.leading)
					Spacer()
				}
				Section("Detected Elements") {
					VStack(alignment: .leading) {
						HStack {
							List(room?.objects ?? [], id: \.identifier) { o in
								Text(o.identifier.uuidString)
							}
						}
					}
				}
			}
		}
	}
}
