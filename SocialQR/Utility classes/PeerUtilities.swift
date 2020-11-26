import Foundation

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
