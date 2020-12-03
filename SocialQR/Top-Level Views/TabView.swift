import SwiftUI
import MultipeerKit
import UserNotifications

struct MainTabView: View {
    @State private var friends: FriendList = FriendList(friends: [])
    private let decoder = JSONDecoder()
    private var transceiver = MultipeerTransceiver()
    
    // Our own info
    private var userInfo: Friend = Friend()
    
    // Are we in a PM?
    @State var inPrivateChat: Bool = false
    
    // Who are we in a PM with?
    @State var inPrivateChatWith: Friend = nullFriend
    
    // Mapping from phone numbers to ChatModel instances
    @State var privateMessageModels: Dictionary<String, ChatModel> = ["": ChatModel()]
    
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
        
        userInfo = try! decoder.decode(Friend.self,
                                       from: UserDefaults.standard.data(forKey: "userInfo") ??
                                        JSONEncoder().encode(Friend()))
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
    
    // Accepts a friend request.
    func acceptRequest(from peer: Peer) {
        // Ask for user info.
        // First, check that the peer is still in range.
        if !self.transceiver.availablePeers.contains(where: { mpkPeer in
            mpkPeer.id == peer.id
        }) {
            self.showPopup(text: "Could not accept request, peer is now out of reach.")
            return
        }
        
        // Peer in range, so send request.
        let payload = CodablePayload(message: "", type: "needs-info")
        let to: MultipeerKit.Peer = self.transceiver.availablePeers.first(where: { mpkPeer in
            mpkPeer.id == peer.id
        })!
        self.transceiver.send(payload, to: [to])
    }
    
    var body: some View {
        ZStack {
            TabView {
                RequestsView(peerList: receivedRequestPeers, friendsList: friends, reqAcceptFunc: self.acceptRequest, inChatWith: self.inPrivateChatWith,
                             currentChatModel: self.privateMessageModels[self.inPrivateChatWith.phone!], inChat: self.$inPrivateChat, transceiver: self.transceiver)
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
                        self.broadcastChatModel.arrayOfSenders.append(String(from.name.split(separator: "'")[0]))
                        self.broadcastChatModel.arrayOfMessages.append(payload.message)
                    } else if payload.type == "needs-info" {
                        // A request has been accepted, need to send our details.
                        var json: String?
                        if (debug) {
                            json = String(
                                data: try! JSONEncoder().encode(nullFriend),
                                encoding: .utf8
                            )!
                        } else {
                            json = String(
                                data: try! JSONEncoder().encode(self.userInfo),
                                encoding: .utf8
                            )
                        }
                        
                        let payload = CodablePayload(message: json ?? "", type: "info")
                        self.transceiver.send(payload, to: [from])
                    } else if payload.type == "info" {
                        // A response for a request for info from an accepted request.
                        if payload.message == "" {
                            self.showPopup(text: "Could not establish a connection.")
                            return
                        }
                        
                        let userInfo = try! JSONDecoder().decode(Friend.self, from: payload.message.data(using: .utf8)!)
                        
                        /* Got our info. Now, we need to:
                         (a) add the user to our friend list
                         (b) create a new dictionary entry for this friend
                         (b) move the user to the messaging screen.
                         */
                        self.friends.friends.append(userInfo)
                        self.privateMessageModels[userInfo.phone!] = ChatModel()
                        self.inPrivateChat = true
                        self.inPrivateChatWith = userInfo
                    }
                })
            }
        }.onDisappear(perform: {
            // Save the user profile and friends list.
            let encoder = JSONEncoder()
            do {
                let encodedFriendList = try encoder.encode(self.friends)
                UserDefaults.standard.setValue(encodedFriendList, forKey: "friendList")
            } catch {
                print("Failed to save to disk: " + error.localizedDescription)
            }
        }).popup(isPresented: $showingPopup, autohideIn: 2) {
            HStack {
                Text(self.popupText)
            }
            .frame(width: 200, height: 60)
            .background(Color(red: 0.85, green: 0.8, blue: 0.95))
            .cornerRadius(30.0)
        }
    }
}
