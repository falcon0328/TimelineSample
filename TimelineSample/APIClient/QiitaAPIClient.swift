//
//  QiitaAPIClient.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/06/29.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation

protocol QiitaAPIClientDelegate: class {
    func qiitaAPIClient(_: QiitaAPIClient, didReceiveTags tags: [QiitaTag])
    func qiitaAPIClient(_: QiitaAPIClient, didInvalidReceiveTagWithError error: Error)
}

class QiitaAPIClient {
    static let shared = QiitaAPIClient()
    
    /// QiitaのAPI取得結果をどの順番でソートさせるかを指定する
    enum QiitaAPISortType: String {
        /// 記事数順
        case count
        /// 名前順
        case name
    }
    
    weak var delegate: QiitaAPIClientDelegate?
    
    /// Qiitaのタグ一覧を取得する
    /// - Parameters:
    ///   - page: ページ番号 (1から100まで)
    ///   - perPage: 1ページあたりに含まれる要素数 (1から100まで)
    ///   - sort: 並び順 (countで記事数順、nameで名前順)
    func fetchQiitaTags(page: Int = 1, perPage: Int, sort: QiitaAPISortType) {
        guard let url = URL(string: "https://qiita.com/api/v2/tags?page=\(page)&per_page=\(perPage)&sort=\(sort)") else {
            delegate?.qiitaAPIClient(self, didInvalidReceiveTagWithError: NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let sself = self else {
                return
            }
            guard let data = data,
                let response = response as? HTTPURLResponse else {
                    if let error = error {
                        sself.delegate?.qiitaAPIClient(sself, didInvalidReceiveTagWithError: error)
                    }
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                sself.delegate?.qiitaAPIClient(sself, didInvalidReceiveTagWithError: NSError(domain: "",
                                                                                             code: response.statusCode,
                                                                                             userInfo: nil))
                return
            }
            do {
                sself.delegate?.qiitaAPIClient(sself, didReceiveTags: try JSONDecoder().decode([QiitaTag].self, from: data))
            } catch {
                sself.delegate?.qiitaAPIClient(sself, didInvalidReceiveTagWithError: error)
            }
        }.resume()
    }
}
