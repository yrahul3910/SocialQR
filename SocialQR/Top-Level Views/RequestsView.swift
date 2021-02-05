import SwiftUI
import MultipeerKit

struct RequestsView: View {
    @ObservedObject var peerList: PeerList
    @State var friendsList: FriendList
    var reqAcceptFunc: (Peer) -> Void
    var ownPhoneNo: String
    @Binding var inChatWith: Friend
    @State var currentChatModel: ChatModel? = ChatModel()
    @Binding var inChat: Bool
    var transceiver: MultipeerTransceiver
    
    var body: some View {
        let neighbors = Array(Set(peerList.peers))

        NavigationView {
            ScrollView {
                ForEach(neighbors.indices, id: \.self, content: { [self] index in
                    HStack {
                        Text(verbatim: neighbors[index].name)
                        Spacer()
                        NavigationLink(
                            destination: PrivateMessagingView(model: currentChatModel ?? ChatModel(), transceiver: transceiver, ownPhoneNo: self.ownPhoneNo, friendInfo: inChatWith),
                            isActive: $inChat) { EmptyView() }
                        Button(action: {
                            // Request accepted, let the parent handle it.
                            reqAcceptFunc(neighbors[index])
                        }, label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        })
                        Button(action: {
                            self.peerList.removePeer(id: neighbors[index].id)
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        })
                    }.padding()
                })
            }.navigationBarTitle("Requests")
        }
    }
}
