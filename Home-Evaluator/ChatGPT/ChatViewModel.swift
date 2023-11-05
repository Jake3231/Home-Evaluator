import Foundation
extension ChatView{
    class ViewModel: ObservableObject {
		
		private var address: String?
		@Published var messages: [Message] = []
        @Published var currentInput: String = ""
		private let openAIService: OpenAIService?
		
		
		init(address: String) {
			openAIService = OpenAIService(address: address)
			self.address = address
		}
		
        
        func sendMessage(){
			guard let openAIService = openAIService else {
				print("Error on OAI service.")
			}
			
            let newMessage = Message(id: UUID(), role: .user, content:currentInput, createAt:Date())
            messages.append(newMessage)
            currentInput = ""
            
            Task {
                let response = await openAIService.SendMessage(input: newMessage.content)
                guard let received = response else {
                    print("BRUH")
                    return
                }
                let receivedMessage = Message(id: UUID(), role: .assistant, content:received, createAt: Date())
            await MainActor.run(body: {
                    messages.append(receivedMessage)
                })
            }
        }
    }
}

struct Message: Decodable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createAt:Date
}
