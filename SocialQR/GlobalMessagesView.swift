// from https://medium.com/better-programming/build-a-chat-app-interface-with-swiftui-96609e605422

import SwiftUI
import MultipeerKit


struct GlobalMessagesView: View {
    @ObservedObject var model: ChatModel
    var transceiver: MultipeerTransceiver
        
        var body: some View {
            GeometryReader { geo in
                VStack {
                    //MARK:- ScrollView
                    CustomScrollView(scrollToEnd: true) {
                        LazyVStack {
                            ForEach(0..<model.arrayOfMessages.count, id:\.self) { index in
                                ChatBubble(position: model.arrayOfPositions[index], color: model.arrayOfPositions[index] == BubblePosition.right ?.green : .blue) {
                                    Text(model.arrayOfMessages[index])
                                }
                            }
                        }
                    }.padding(.top)
                    //MARK:- text editor
                    HStack {
                        ZStack {
                            TextEditor(text: $model.text)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundColor(.gray)
                        }.frame(height: 50)
                        
                        Button(action: {
                            if model.text != "" {
                                model.position = BubblePosition.right
                                model.arrayOfPositions.append(model.position)
                                // TODO: Show name of sender
                                model.arrayOfMessages.append(model.text)
                                
                                let payload = CodablePayload(message: model.text, type: "broadcast")
                                self.transceiver.broadcast(payload)
                                
                                model.text = ""
                            }
                        }) { Image(systemName: "paperplane.fill") }
                    }.padding()
                }
            }
        }
}
