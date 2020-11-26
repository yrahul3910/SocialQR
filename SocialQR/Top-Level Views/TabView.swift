import SwiftUI
import MultipeerKit
import UserNotifications

struct MainTabView: View {
    private let friends: FriendList
    private let decoder = JSONDecoder()
    private var transceiver = MultipeerTransceiver()
    
    // List of peers nearby
    @State var peers = PeerList()
    
    // List of peers who have sent friend requests
    @State var receivedRequestPeers = PeerList()
    
    // Showing a popup? (Used for toast notifications)
    @State var showingPopup = false
    
    // Toast notification text
    @State var popupText: String = ""
    
    // Do we have any unread broadcast messages?
    @State var hasUnreadBroadcasts: Bool = false
    
    // Are we showing the broadcast messages?
    @State var isShowingBroadcasts: Bool = false
    
    // The chat model for the broadcast messages
    @State var broadcastChatModel: ChatModel = ChatModel()
    
    init() {
        /* Fetch the user friend list from the stored data. If it does
         not exist, then create an empty friend list, and return that
         instead.
         */
        friends = try! decoder.decode(FriendList.self,
                                      from: UserDefaults.standard.data(forKey: "friendList") ?? JSONEncoder().encode(FriendList(friends: [])))
    }
    
    /* Function passed down to NearbyView to update us on whether or not
    we are showing the broadcast messages. We use this function to pass
    state up. */
    func toggleShowingBroadcasts() {
        self.isShowingBroadcasts = !self.isShowingBroadcasts
    }
    
    // Helper function to show toast notifications.
    func showPopup(text: String) {
        self.popupText = text
        self.showingPopup = true
    }
    
    // Sends a friend request.
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
                
                NearbyView(peerList: peers, chatModel: self.broadcastChatModel, hasUnread: self.hasUnreadBroadcasts, popupFunc: self.showPopup, requestFunc: self.sendRequest, broadcastToggleFunc: self.toggleShowingBroadcasts, transceiver: self.transceiver)
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
                // Start the transceiver.
                transceiver.resume()
                
                // If peer added, add to our list.
                transceiver.peerAdded = { peer in
                    self.peers.addPeer(name: peer.name, id: peer.id)
                }
                
                // ...and if peer leaves, remove from both our lists.
                transceiver.peerRemoved = { peer in
                    self.peers.removePeer(id: peer.id)
                    self.receivedRequestPeers.removePeer(id: peer.id)
                }
                
                // If we receive a payload...
                transceiver.receive(CodablePayload.self, using: { payload, from in
                    // ...check the type of payload.
                    if payload.type == "request" {
                        // If it's a request, then add it to our list of received requests.
                        self.receivedRequestPeers.addPeer(name: from.name, id: from.id)
                    } else if payload.type == "broadcast" {
                        /* If it's a broadcast message, use the information we have about
                        the broadcast messages being displayed to update the state of
                        whether or not there are unread broadcasts... */
                        if !self.isShowingBroadcasts {
                            self.hasUnreadBroadcasts = true
                        }
                        
                        // ...and then update our chat model.
                        self.broadcastChatModel.arrayOfPositions.append(BubblePosition.left)
                        self.broadcastChatModel.arrayOfMessages.append(payload.message)
                        
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
