import SwiftUI

struct RequestsView: View {
    @ObservedObject var peerList: PeerList
    
    var body: some View {
        VStack {
            Text("Message Requests")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(peerList.peers.indices, id: \.self, content: { [self] index in
                    HStack {
                        Text(verbatim: peerList.peers[index].name)
                        Spacer()
                        Button(action: {}, label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        })
                        Button(action: {
                            self.peerList.removePeer(id: peerList.peers[index].id)
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        })
                    }.padding()
                })
            }
        }
    }
}
