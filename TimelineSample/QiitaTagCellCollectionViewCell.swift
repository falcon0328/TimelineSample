//
//  QiitaTagCellCollectionViewCell.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/03.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import UIKit

class QiitaTagCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        idLabel.text = nil
        followersLabel.text = nil
    }
    
    func updateAppearance(icon: UIImage?) {
        iconImageView.image = icon
    }
    
    func updateAppearance(indexPath: IndexPath, id: String, followers: String, icon: UIImage?) {
        idLabel.text = "\(indexPath.item + 1) " + id
        followersLabel.text = followers
        updateAppearance(icon: icon)
    }
}
