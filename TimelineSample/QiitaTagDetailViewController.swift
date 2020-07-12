//
//  QiitaTagDetailViewController.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/12.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import UIKit

class QiitaTagDetailViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var tag: QiitaTag?
    var operation: QiitaTagImageOperation?
    let operationQueue = OperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateApperance()
        fetchTagImageIfNeed()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        operation?.cancel()
        operationQueue.cancelAllOperations()
        operation = nil
    }
    
    func fetchTagImageIfNeed() {
        guard let tag = tag, let tagImageURL = URL(string: tag.icon_url) else { return }
        let operation = QiitaTagImageOperation(tagImageURL: tagImageURL)
        operation.completionHandler = { image, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.iconImageView.image = image
            }
        }
        operationQueue.addOperation(operation)
        self.operation = operation
    }
    
    func updateApperance() {
        if let tag = self.tag {
            self.idLabel.text = tag.id
            self.itemsLabel.text = "\(tag.items_count)"
            self.followersLabel.text = "\(tag.followers_count)"
        } else {
            self.idLabel.text = nil
            self.itemsLabel.text = nil
            self.followersLabel.text = nil
        }
    }

}
