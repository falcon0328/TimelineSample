//
//  QiitaTagDataStore.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/05.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation
import UIKit

protocol QiitaTagDataStoreDelegate: class {
    func qiitaTagDataStore(_: QiitaTagDataStore, didReceiveTags tags: [QiitaTag])
    func qiitaTagDataStore(_: QiitaTagDataStore, didInvalidReceiveTagWithError error: Error)
}

class QiitaTagDataStore {
    let qiitaAPIClient = QiitaAPIClient()
    var tags: [QiitaTag] = []
    var page: Int = 1
    var isLoading: Bool = false
    
    weak var delegate: QiitaTagDataStoreDelegate?
    
    func fetchTags(page: Int = 1, perPage: Int, sort: QiitaAPIClient.QiitaAPISortType) {
        guard !isLoading else { return }
        qiitaAPIClient.delegate = self
        qiitaAPIClient.fetchQiitaTags(page: page, perPage: perPage, sort: sort)
    }
    
    func loadTagImage(index: Int, tagImageURL: URL) -> QiitaTagImageOperation? {
        guard index >= 0 && index < tags.count else { return .none }
        return QiitaTagImageOperation(tagImageURL: tagImageURL)
    }
}

extension QiitaTagDataStore: QiitaAPIClientDelegate {
    func qiitaAPIClient(_: QiitaAPIClient, didReceiveTags tags: [QiitaTag]) {
        isLoading = false
        DispatchQueue.main.async { [weak self] in
            guard let sself = self else { return }
            sself.page += 1
            sself.tags += tags
            sself.delegate?.qiitaTagDataStore(sself, didReceiveTags: sself.tags)
        }
    }
    
    func qiitaAPIClient(_: QiitaAPIClient, didInvalidReceiveTagWithError error: Error) {
        isLoading = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.qiitaTagDataStore(self, didInvalidReceiveTagWithError: error)
        }
    }
}

class QiitaTagImageOperation: Operation {
    let tagImageURL: URL
    var tagImage: UIImage?
    var completionHandler: ((UIImage?, Error?)->Void)?
    
    init(tagImageURL: URL) {
        self.tagImageURL = tagImageURL
    }
    
    override func main() {
        guard !isCancelled else { return }
        URLSession.shared.dataTask(with: tagImageURL) { [weak self] (data, response, error) in
            guard let sself = self else { return }
            guard !sself.isCancelled,
                let data = data, let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                    sself.callbackIfNeed(image: nil, error: error)
                    sself.completionHandler = nil
                    return
            }
            if let image = UIImage(data: data) {
                sself.tagImage = image
                sself.callbackIfNeed(image: image, error: nil)
            } else {
                let error = NSError(domain: "QiitaTagImageOperationError", code: 0, userInfo: nil)
                sself.callbackIfNeed(image: nil, error: error)
            }
            sself.completionHandler = nil
        }.resume()
    }
    
    func callbackIfNeed(image: UIImage?, error: Error?) {
        guard let completionHandler = completionHandler else { return }
        completionHandler(image, error)
    }
}
