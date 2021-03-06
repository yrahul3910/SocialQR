import SwiftUI
import MultipeerKit
import UserNotifications

struct MainTabView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(entity: UserInfo.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \UserInfo.name, ascending: true)
    ])
    var user: FetchedResults<UserInfo>
    
    @FetchRequest(entity: UserFriendList.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \UserFriendList.jsonData, ascending: true)
    ])
    var friendList: FetchedResults<UserFriendList>
    
    @FetchRequest(entity: SystemState.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \SystemState.firstRun, ascending: true)
    ])
    var systemState: FetchedResults<SystemState>
    
    private var transceiver = MultipeerTransceiver()
    
    // What tab are we currently in?
    @State private var tabSelection = "Nearby"
    
    // JSON encoding and decoding
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Are we in a PM?
    @ObservedObject var inPrivateChat: ObservableBool = ObservableBool()
    
    // Our notification manager
    @ObservedObject var notificationManager = NotificationManager()
    
    // Who are we in a PM with?
    @State var inPrivateChatWith: Friend = nullFriend
    
    // Mapping from phone numbers to ChatModel instances
    @State var privateMessageModels: Dictionary<String, ChatModel> = ["": ChatModel()]
    
    // List of peers nearby
    @State var peers = PeerList()
    
    // List of peers who have sent friend requests
    @ObservedObject var receivedRequestPeers = PeerList()
    
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
    
    func saveDetails() {
        // Save the user profile and friends list.
        do {
            try self.moc.save()
        } catch {
            print("Failed to save to disk: " + error.localizedDescription)
        }
    }
    
    func instantiateChat(with peerInfo: Friend) {
        // Create the dictionary entry
        if !self.privateMessageModels.contains(where: {key, value in
            return key == peerInfo.phone
        }) {
            self.privateMessageModels[peerInfo.phone] = ChatModel()
        }
        
        // Start the chat
        self.inPrivateChatWith = peerInfo
        self.inPrivateChat.setTrue()        
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
        
        // Peer in range, so send request for info, sending our own info at the same time.
        do {
            let json = try JSONEncoder().encode(getFriendFromUserInfo(user: self.user.last!))
            let jsonString = String(data: json, encoding: .utf8)!
            let payload = CodablePayload(message: jsonString, type: "needs-info")
            let to: MultipeerKit.Peer = self.transceiver.availablePeers.first(where: { mpkPeer in
                mpkPeer.id == peer.id
            })!
            self.transceiver.send(payload, to: [to])
        } catch {
            print("[TabView] Failed to send needs-info request: " + error.localizedDescription)
        }
    }
    
    var body: some View {
        if systemState.isEmpty {
            FirstRunView()
        }
        else {
            ZStack {
                TabView(selection: $tabSelection) {
                    RequestsView(peerList: receivedRequestPeers, friendsList: getFriendListFromEntity(list: friendList[friendList.count - 1]), reqAcceptFunc: self.acceptRequest, ownPhoneNo: self.user.last!.phone!, inChatWith: self.$inPrivateChatWith,
                                 currentChatModel: self.privateMessageModels[self.inPrivateChatWith.phone], inChat: self.$inPrivateChat.value, transceiver: self.transceiver)
                        .tabItem {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Requests (\( self.receivedRequestPeers.peers.count))")
                        }
                        .tag("Requests")
                    
                    NearbyView(peerList: peers, chatModel: self.broadcastChatModel, hasUnread: self.hasUnreadBroadcasts, popupFunc: self.showPopup, requestFunc: self.sendRequest, broadcastToggleFunc: self.toggleShowingBroadcasts, transceiver: self.transceiver)
                        .tabItem {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Text("Near Me")
                        }
                        .tag("Nearby")
                    
                    FriendsView(friends: self.friendList[friendList.count - 1], chatFn: self.instantiateChat, popupFn: self.showPopup)
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Friends")
                        }
                        .environment(\.managedObjectContext, self.moc)
                        .tag("Friends")
                    
                    ProfileView(friends: self.friendList[self.friendList.count - 1])
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                        .tag("Profile")
                    
                    AboutView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .tag("About")
                }
                .onAppear() {
                    // Start the transceiver.
                    transceiver.resume()
                    
                    // If peer added, add to our list.
                    transceiver.peerAdded = { peer in
                        self.peers.addPeer(name: peer.name, id: peer.id)
                        notificationManager.sendNotification(title: "New neighbors!", subtitle: nil, body: "Someone new is near you. Say hi!", launchIn: 1.0)
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
                            self.receivedRequestPeers.addPeer(name: payload.message, id: from.id)
                        } else if payload.type == "message" {
                            // First, get the phone number, which we send in the message.
                            let message = payload.message
                            let splits = message.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { char in
                                return char == "|"
                            })
                            let phone = String(splits[0])
                            let actualMessage = String(splits[1])
                            
                            if (self.privateMessageModels.index(forKey: phone) == nil) {
                                self.privateMessageModels[phone] = ChatModel()
                            }
                            
                            self.privateMessageModels[phone]!.arrayOfPositions.append(.left)
                            self.privateMessageModels[phone]!.arrayOfSenders.append(self.inPrivateChatWith.name)
                            self.privateMessageModels[phone]!.arrayOfMessages.append(actualMessage)
                            
                            // Send acknowledgement
                            let payload = CodablePayload(message: self.user.last!.phone! + "|" + actualMessage, type: "ack")
                            self.transceiver.send(payload, to: [from])
                        } else if payload.type == "ack" {
                            // Handle acknowledgements
                            let message = payload.message
                            let splits = message.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { char in
                                return char == "|"
                            })
                            let phone = String(splits[0])
                            let actualMessage = String(splits[1])
                            
                            // Now find this message in the chat model
                            var ownMessageCount = 0
                            for idx in self.privateMessageModels[phone]!.arrayOfPositions.indices {
                                if self.privateMessageModels[phone]!.arrayOfPositions[idx] == .right {
                                    ownMessageCount += 1
                                    if (actualMessage == self.privateMessageModels[phone]!.arrayOfMessages[idx]) {
                                        // This is the ack'd message
                                        if self.privateMessageModels[phone]!.arrayOfAcks.count < ownMessageCount - 1 {
                                            // We have a possible dropped message
                                            self.showPopup(text: "Your message may not have been delivered.")
                                            
                                            // We need an extra element so this condition is not always triggered
                                            self.privateMessageModels[phone]!.arrayOfAcks.append(false)
                                            self.privateMessageModels[phone]!.arrayOfAcks.append(true)
                                        } else {
                                            self.privateMessageModels[phone]!.arrayOfAcks.append(true)
                                        }
                                        
                                        // There's no need to search any further.
                                        break
                                    }
                                }
                            }
                        } else if payload.type == "broadcast" {
                            /* If it's a broadcast message, use the information we have about
                             the broadcast messages being displayed to update the state of
                             whether or not there are unread broadcasts... */
                            if !self.isShowingBroadcasts {
                                self.hasUnreadBroadcasts = true
                            }
                            
                            // ... and then update our chat model.
                            self.broadcastChatModel.arrayOfPositions.append(BubblePosition.left)
                            self.broadcastChatModel.arrayOfSenders.append(String(from.name.split(separator: "'")[0]))
                            self.broadcastChatModel.arrayOfMessages.append(payload.message)
                        } else if payload.type == "needs-info" {
                            // A request has been accepted, need to send our details.
                            var json: String?
                            do {
                                json = String(
                                    data: try JSONEncoder().encode(getFriendFromUserInfo(user: self.user[self.user.count - 1])),
                                    encoding: .utf8
                                )
                            } catch {
                                print("[TabView] Could not encode user info: " + error.localizedDescription)
                            }
                            
                            let sentPayload = CodablePayload(message: json ?? "", type: "info")
                            self.transceiver.send(sentPayload, to: [from])
                            
                            /* We are now also friends, so we need to:
                             (a) add the user to our friend list
                             (b) create a new dictionary entry for this friend
                             (c) move the user to the messaging screen.
                             */
                            do {
                                // First, get the peer details
                                let peerInfo: Friend = try JSONDecoder().decode(Friend.self, from: payload.message.data(using: .utf8)!)
                                
                                // Get our friend list, and add it in
                                let currentFriendList: FriendList = getFriendListFromEntity(list: self.friendList[self.friendList.count - 1])
                                currentFriendList.friends.append(peerInfo)
                                let contextFriendList = UserFriendList(context: self.moc)
                                contextFriendList.jsonData = String(data: try JSONEncoder().encode(currentFriendList), encoding: .utf8)
                                
                                // Save to disk.
                                try self.moc.save()
                                
                                self.friendList[self.friendList.count - 1].jsonData = contextFriendList.jsonData
                                
                                self.instantiateChat(with: peerInfo)
                            } catch {
                                print("[TabView] Adding to friend list failed: " + error.localizedDescription)
                            }
                        } else if payload.type == "info" {
                            // A response for a request for info from an accepted request.
                            if payload.message == "" {
                                self.showPopup(text: "Could not establish a connection.")
                                return
                            }
                            
                            do {
                                let userInfo = try JSONDecoder().decode(Friend.self, from: payload.message.data(using: .utf8)!)
                                
                                /* Got our info. Now, we need to:
                                 (a) add the user to our friend list
                                 (b) create a new dictionary entry for this friend
                                 (b) move the user to the messaging screen.
                                 */
                                let currentFriendList = getFriendListFromEntity(list: self.friendList[self.friendList.count - 1])
                                currentFriendList.friends.append(userInfo)
                                let contextFriendList = UserFriendList(context: self.moc)
                                contextFriendList.jsonData = String(data: try JSONEncoder().encode(currentFriendList), encoding: .utf8)
                                
                                self.saveDetails()
                                self.instantiateChat(with: userInfo)
                            } catch {
                                print("[TabView] Failed to decode payload: " + error.localizedDescription)
                            }
                        }
                    })
                }
            }.onDisappear(perform: {
                self.saveDetails()
            }).popup(isPresented: $showingPopup, type: .floater(verticalPadding: 30), autohideIn: 2) {
                Text(self.popupText)
                    .bold()
                    .padding()
                    .frame(width: 200, height: 60)
                    .cornerRadius(30.0)
                    .shadow(radius: 2)
            }.sheet(isPresented: self.$inPrivateChat.value, content: {
                PrivateMessagingView(model: self.privateMessageModels[self.inPrivateChatWith.phone] ?? ChatModel(), transceiver: self.transceiver, ownPhoneNo: self.user.last!.phone!, friendInfo: self.inPrivateChatWith)
            })
        }
    }
}
