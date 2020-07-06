//
//  QiitaTagDataStore.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/05.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation
import UIKit

class QiitaTagDataStore {
    func loadTagImage(tagImageURL: URL) -> QiitaTagImageOperation {
        return QiitaTagImageOperation(tagImageURL: tagImageURL)
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
