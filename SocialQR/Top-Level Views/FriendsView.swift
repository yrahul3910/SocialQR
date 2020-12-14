import SwiftUI
import CodeScanner

class FriendList: Codable, ObservableObject {
    var friends: Array<Friend> = []
    
    init(friends: Array<Friend>) {
        self.friends = friends
    }
}

struct FriendsView: View {
    @ObservedObject var friends: FriendList
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
        self.isShowingCamera = false
        
        switch result {
        case .success(let code):
            do {
                let decoded = try JSONDecoder().decode(Friend.self, from: Data(code.utf8))
                // TODO: Save on app close
                friends.friends.append(decoded)
            } catch {
                
            }
            
        case .failure(_):
            print("Scanning failed")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(friends.friends.indices, id: \.self) { index in
                        FriendView(img: UIImage(data: (friends.friends[index].img ?? "".data(using: .utf8))!),
                                   name: friends.friends[index].name!,
                                   phone: friends.friends[index].phone!)
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
