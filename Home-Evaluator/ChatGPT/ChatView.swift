import SwiftUI



struct ChatView: View {
    private var address: String?
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            Text("Your Personal AI Realtor")
            ScrollView{
                ForEach(viewModel.messages, id: \.id){ message in
                    messageView(message: message)
                }
            }
            HStack{
                TextField("Ask Hex...", text: $viewModel.currentInput)
                Button{
                    viewModel.sendMessage()
                } label: {
                    Text("Send")
                }
            }
        }
        .overlay {
            if viewModel.messages.isEmpty {
                Image("Hex")
                    .frame(width: 150, height: 150)
            }
        }
        .padding()
    }
    
    init(address: String) {
        self.address = address
        self.viewModel = ViewModel(address: address)
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer()}
            Text(try! AttributedString(markdown: message.content.replacingOccurrences(of: "\\n", with: "\n")))
                .padding()
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if message.role == .assistant {Spacer()}
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(address: "2200 Waterview Pkwy Richardson, TX 75080 ")
    }
}
