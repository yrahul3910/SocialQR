// from https://medium.com/better-programming/build-a-chat-app-interface-with-swiftui-96609e605422

import SwiftUI
import MultipeerKit


struct PrivateMessagingView: View {
    @ObservedObject var model: ChatModel
    var transceiver: MultipeerTransceiver
    @State var friendInfo: Friend
    @State var gotAck: Bool = true
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                //MARK:- Heading
                VStack {
                    Text(friendInfo.name)
                        .bold()
                        .font(.largeTitle)
                    Button(action: {
                        let formattedString = "sms:\(friendInfo.phone)&body="
                        let url: NSURL = URL(string: formattedString)! as NSURL
                        
                        UIApplication.shared.open(url as URL)
                    }) {
                        Text(verbatim: friendInfo.phone)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .shadow(radius: 5)
                
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
