//
//  RandomStringGenerator.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/22.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation

class RandomStringGenerator {
    static let shared = RandomStringGenerator()
    
    func generate(length: Int) -> String {
          let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          var randomString: String = ""
          for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
            randomString += "\n"
          }
          return randomString
      }
}
