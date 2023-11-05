/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The sample app's main view controller that manages the scanning process.
*/

import UIKit
import RoomPlan
import SwiftUI

class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate {
    
    @IBOutlet var exportButton: UIButton?
    
    @IBOutlet var doneButton: UIBarButtonItem?
    @IBOutlet var cancelButton: UIBarButtonItem?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    var delegate: RoomCaptureSessionDelegate!
    
    var capturedRooms: [CapturedRoom] = []
    @Published var publishedCapturedRooms: [CapturedRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up after loading the view.
        setupRoomCaptureView()
        activityIndicator?.stopAnimating()
    }
    
    convenience init(delegate: RoomCaptureSessionDelegate) {
        self.init()
        self.delegate = delegate
    }

    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = delegate
        roomCaptureView.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    func finishedRoom() {
        roomCaptureView.captureSession.stop(pauseARSession: false)
    }
    
    func beginRoom() {
        roomCaptureView.captureSession.run(configuration: roomCaptureSessionConfig)
    }
    
    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
    }
    
    private func stopSession() {
        isScanning = false
        roomCaptureView?.captureSession.stop()
    }
    
    // Decide to post-process and show the final results.
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    // Access the final post-processed results.
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        //finalResults = processedResult
        self.exportButton?.isEnabled = true
        self.activityIndicator?.stopAnimating()
    }
    
    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    // Export the USDZ output by specifying the `.parametric` export option.
    // Alternatively, `.mesh` exports a nonparametric file and `.all`
    // exports both in a single USDZ.
    @IBAction func exportResults(_ sender: UIButton) {
        roomCaptureView.captureSession.stop()
        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
        let destinationURL = destinationFolderURL.appending(path: "Structure.usdz")
        let capturedRoomURL = destinationFolderURL.appending(path: "Rooms.json")
        
        async {
        do {
            print("ROOMS: \(capturedRooms.count)")
                let builder = StructureBuilder(options: .beautifyObjects)
                let structure = await try builder.capturedStructure(from: capturedRooms)
                try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
                let jsonEncoder = JSONEncoder()
            print("ROOMS2: \(structure.rooms.count)")
            let jsonData = try jsonEncoder.encode(capturedRooms)
                try jsonData.write(to: capturedRoomURL)
                //try finalResults?.export(to: destinationURL, exportOptions: .parametric)
            try structure.export(to: destinationURL, exportOptions: .parametric)
                
                let activityVC = UIActivityViewController(activityItems: [destinationFolderURL], applicationActivities: nil)
                activityVC.modalPresentationStyle = .popover
                
                present(activityVC, animated: true, completion: nil)
                if let popOver = activityVC.popoverPresentationController {
                    popOver.sourceView = self.exportButton
                }
            } catch {
                print("Error = \(error)")
            }
        }
    }
}

struct RoomScanViewController: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    @Binding var structureScanComplete: Bool
    @ObservedObject var results: CapturedRoomScan
 
    func makeUIViewController(context: Context) -> RoomCaptureViewController {
        let viewController = RoomCaptureViewController(delegate: context.coordinator)
        return viewController
        }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(capturedRooms: results)
        }
    
    
    class Coordinator: NSObject, ObservableObject, RoomCaptureSessionDelegate {
        private var result: CapturedRoomScan
        
        init(capturedRooms: CapturedRoomScan) {
            self.result = capturedRooms
        }
        
        func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
            let roomBuilder = RoomBuilder(options: [.beautifyObjects])
            async {
                let capturedRoom = try? await roomBuilder.capturedRoom(from: data)
                if let room = capturedRoom {
                    DispatchQueue.main.async {
                        self.result.capturedRooms.append(room)
                        print("APPENDING ROOM")
                    }
                }
            }
        }
    }

    func updateUIViewController(_ uiViewController: RoomCaptureViewController, context: Context) {
        if isScanning {uiViewController.beginRoom()} else {uiViewController.finishedRoom()}
        //if structureScanComplete {capturedRooms = uiViewController.capturedRooms}
    }
}

class CapturedRoomScan: ObservableObject, Equatable {
    static func == (lhs: CapturedRoomScan, rhs: CapturedRoomScan) -> Bool {
        return (lhs.capturedRooms.first?.identifier == rhs.capturedRooms.first?.identifier) && (lhs.capturedRooms.count == rhs.capturedRooms.count)
    }
    
    @Published var capturedRooms: [CapturedRoom]
    
    init(capturedRooms: [CapturedRoom]) {
        self.capturedRooms = capturedRooms
    }
}

