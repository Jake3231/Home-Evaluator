import SwiftUI



struct ChatView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            ScrollView{
                ForEach(viewModel.messages, id: \.id){ message in 
                    messageView(message: message)
                }
            }
            HStack{
                TextField("Enter a message...", text: $viewModel.currentInput)
                Button{
                    viewModel.sendMessage()
                } label: {
                    Text("Send")
                }
            }
        }
        .padding()
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer()}
            Text(try! AttributedString(markdown: message.content.replacingOccurrences(of: "\\n", with: "\n")))
                .padding()
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
            if message.role == .assistant { Spacer()}
        }
        .cornerRadius(5)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
