//
//  ViewInChecker.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/18.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import Foundation
import UIKit

enum ViewInStatus {
    case viewIn
    case viewOut
}

class ViewInChecker {
    static let shared = ViewInChecker()
    
    private var currentWindow: UIWindow? {
        return UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
    }
    
    func checkViewInStatus(rect: CGRect, ratio: CGFloat, edgeInsets: UIEdgeInsets = .zero) -> ViewInStatus {
        let intersection = onWindowSize(rect: rect, edgeInsets: edgeInsets)
        let intersectionArea = floor(intersection.width * intersection.height)
        let targetArea = floor(rect.width * rect.height)
        if intersectionArea < 0 || targetArea < 0 { return .viewOut }
        return intersectionArea >= (targetArea * ratio) ? .viewIn : .viewOut
    }
    
    func onWindowSize(rect: CGRect, edgeInsets: UIEdgeInsets = .zero) -> CGRect {
        guard let currentWindow = currentWindow else { return .zero }
        let windowRect = CGRect(x: currentWindow.frame.origin.x,
                                y: currentWindow.frame.origin.y,
                                width: currentWindow.frame.width - edgeInsets.left - edgeInsets.right,
                                height: currentWindow.frame.height - edgeInsets.top - edgeInsets.bottom)
        
        let sx = max(rect.origin.x, windowRect.origin.x)
        let sy = max(rect.origin.y, windowRect.origin.y)
        let ex = min(rect.origin.x + rect.size.width,
                     windowRect.origin.x + windowRect.size.width)
        let ey = min(rect.origin.y + rect.size.height,
                     windowRect.origin.y + windowRect.size.height)
        let w = ex - sx
        let h = ey - sy
        return w > 0 && h > 0 ? CGRect(x: sx, y: sy, width: w, height: h) : .zero
    }
}
