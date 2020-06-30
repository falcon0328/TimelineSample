//
//  ViewController.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/06/29.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let qiitaAPIClient = QiitaAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        qiitaAPIClient.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qiitaAPIClient.fetchQiitaTags(perPage: 20, sort: .count)
    }

    @IBAction func refreshButtonDidTap(_ sender: Any) {
        qiitaAPIClient.fetchQiitaTags(perPage: 20, sort: .count)
    }
}

extension ViewController: QiitaAPIClientDelegate {
    func qiitaAPIClient(_: QiitaAPIClient, didReceiveTags tags: [QiitaTag]) {
        DispatchQueue.main.async { [weak self] in
            guard let sself = self else { return }
            sself.collectionView.reloadData()
        }
    }
    
    func qiitaAPIClient(_: QiitaAPIClient, didInvalidReceiveTagWithError error: Error) {}
}
