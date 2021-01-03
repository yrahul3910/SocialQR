import SwiftUI
import CodeScanner
import AVFoundation

class FriendList: Codable, ObservableObject {
    var friends: Array<Friend> = []
    
    init(friends: Array<Friend>) {
        self.friends = friends
    }
}

struct FriendsView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var friends: UserFriendList
    @State var chatFn: (Friend) -> ()
    
    @State private var isShowingCamera = false
    private let simulatedData = try! String(data: JSONEncoder().encode(
        Friend(name: "R. Yedida",
               phone: "+19196368327",
               notes: "Nice dude",
               img: UIImage(systemName: "plus")?.pngData() ?? Data()
        )
    ), encoding: String.Encoding.utf8) ?? ""
    
    // Handle QR code scanning
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        // Quick vibration for tactile feedback
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        self.isShowingCamera = false
        
        switch result {
        case .success(let code):
            do {
                let decoded = try JSONDecoder().decode(Friend.self, from: Data(code.utf8))
                
                let currentFriends = try JSONDecoder().decode(FriendList.self, from: (friends.jsonData!.data(using: .utf8))!)
                currentFriends.friends.append(decoded)
                
                let contextFriendList = UserFriendList(context: self.moc)
                contextFriendList.jsonData = String(data: try JSONEncoder().encode(currentFriends), encoding: .utf8)
            } catch {
                print("[FriendsView] Failed to update: " + error.localizedDescription)
            }
            
        case .failure(_):
            print("Scanning failed")
        }
    }
    
    var body: some View {
        let friendList = try! JSONDecoder().decode(FriendList.self, from: (self.friends.jsonData!.data(using: .utf8))!)
        
        return NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(friendList.friends.indices, id: \.self) { index in
                        FriendView(img: UIImage(data: (friendList.friends[index].img ?? "".data(using: .utf8))!),
                                   name: friendList.friends[index].name,
                                   phone: friendList.friends[index].phone,
                                   chatFn: self.chatFn)
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarItems(trailing:
                                    Button(action: { self.isShowingCamera = true }) {
                                        Image(systemName: "plus")
                                            .padding()
                                    }
            )
            .sheet(isPresented: $isShowingCamera) {
                CodeScannerView(codeTypes: [.qr], simulatedData: self.simulatedData, completion: self.handleScan)
            }
        }
    }
}
