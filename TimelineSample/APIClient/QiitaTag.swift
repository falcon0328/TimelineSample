//
//  QiitaTag.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/06/29.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation

struct QiitaTag: Decodable, CustomStringConvertible {
    let followers_count: Int
    let icon_url: String
    let items_count: Int
    let id: String
    
    var description: String {
        return "QiitaTag(followers_count: \(followers_count), icon_url: \(icon_url), items_count: \(items_count), id: \(id))"
    }
}
