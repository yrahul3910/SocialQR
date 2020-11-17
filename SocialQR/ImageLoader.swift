//
//  ImageLoader.swift
//  SocialQR
//
//  Created by Rahul Yedida on 11/16/20.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    private var cancellable: AnyCancellable?
    @Published var image: UIImage?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    deinit {
        cancel()
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
        
    func cancel() {
        cancellable?.cancel()
    }
}
