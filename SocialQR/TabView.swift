import SwiftUI
import MultipeerKit
import UserNotifications

struct CodablePayload: Codable, Hashable {
    let message: String
    let type: String
}

struct Peer {
    let name: String
    let id: String
}

class PeerList: ObservableObject {
    @Published var peers: [Peer]
    
    init() {
        self.peers = []
    }
    
    func addPeer(name peerName: String, id peerId: String) {
        self.peers.append(Peer(name: peerName, id: peerId))
    }
    
    func removePeer(id peerId: String) {
        self.peers.remove(
            at: self.peers.firstIndex(where: { peer in
                peer.id == peerId
            })!
        )
    }
}

struct MainTabView: View {
    private let friends: FriendList
    private let decoder = JSONDecoder()
    private var transceiver = MultipeerTransceiver()
    
    @State var peers = PeerList()
    @State var receivedRequestPeers = PeerList()
    @State var showingPopup = false
    @State var popupText: String = ""
    
    init() {
        /* Fetch the user friend list from the stored data. If it does
         not exist, then create an empty friend list, and return that
         instead.
         */
        friends = try! decoder.decode(FriendList.self,
                                      from: UserDefaults.standard.data(forKey: "friendList") ?? JSONEncoder().encode(FriendList(friends: [])))
    }
    
    func showPopup(text: String) {
        self.popupText = text
        self.showingPopup = true
    }
    
    func sendRequest(to peer: Peer) {
        let payload = CodablePayload(message: UIDevice.current.name, type: "request")
        
        for neighbor in self.transceiver.availablePeers {
            if neighbor.id == peer.id {
                self.transceiver.send(payload, to: [neighbor])
                break
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView {
                RequestsView(peerList: receivedRequestPeers)
                    .tabItem {
                        Image(systemName: "person.badge.plus.fill")
                        Text("Requests")
                    }
                
                NearbyView(peerList: peers, popupFunc: self.showPopup, requestFunc: self.sendRequest)
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Near Me")
                    }
                
                FriendsView(friends: self.friends)
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Friends")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
            }.onAppear() {
                transceiver.resume()
                transceiver.peerAdded = { peer in
                    self.peers.addPeer(name: peer.name, id: peer.id)
                }
                transceiver.peerRemoved = { peer in
                    self.peers.removePeer(id: peer.id)
                    self.receivedRequestPeers.removePeer(id: peer.id)
                }
                transceiver.receive(CodablePayload.self, using: { payload, from in
                    if payload.type == "request" {
                        self.receivedRequestPeers.addPeer(name: from.name, id: from.id)
                    }
                })
            }
        }.popup(isPresented: $showingPopup, autohideIn: 2) {
            HStack {
                Text(self.popupText)
            }
            .frame(width: 200, height: 60)
            .background(Color(red: 0.85, green: 0.8, blue: 0.95))
            .cornerRadius(30.0)
        }
    }
}
