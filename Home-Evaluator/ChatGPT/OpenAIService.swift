import Foundation
import Alamofire

class OpenAIService {
    
	private var address: String?
    private let chatEndpoint = "https://4107-129-110-241-55.ngrok-free.app/"
	
	init(address: String) {
		self.address = address
	}
    
    func SendMessage(input: String) async -> String? {
		guard let address = address else {
			return "No address."
		}
        let newURL = chatEndpoint + "chat?address=" + address + "&input=" + input
        do {
            let req = try await AF.request(newURL, method: .get).serializingString().value
            return req
        } catch {
            print("bruh", error)
        }
        
        return "Error"
    }
}

enum SenderRole: String, Codable {
    case user
    case assistant
}



                   

