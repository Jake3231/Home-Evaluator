import Foundation
extension ChatView{
    class ViewModel: ObservableObject {
        @Published var messages: [Message] = []
        
        @Published var currentInput: String = ""
        
        private let openAIService = OpenAIService()
        func sendMessage(){
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
