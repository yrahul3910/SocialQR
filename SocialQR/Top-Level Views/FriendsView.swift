import SwiftUI
import CodeScanner

struct FriendList: Codable {
    var friends: Array<Friend>
}

struct FriendsView: View {
    @State var friends: FriendList
    @State private var isShowingCamera = false
    private let simulatedData = try! String(data: JSONEncoder().encode(
        Friend(name: "R. Yedida",
               phone: "+19196368327",
               notes: "Nice dude",
               img: UIImage(systemName: "plus")?.pngData() ?? Data(),
               links: ["Website": "https://ryedida.me"],
               interests: ["coffee"],
               hobbies: ["programming"],
               occupation: "Ph.D. student")
    ), encoding: String.Encoding.utf8) ?? ""
    
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
                        FriendView(img: UIImage(data: friends.friends[index].img)!,
                                   name: friends.friends[index].name,
                                   phone: friends.friends[index].phone)
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