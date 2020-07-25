//
//  QiitaTagCell.swift
//  TimelineSample
//
//  Created by AtsukiSeo on 2020/07/24.
//  Copyright © 2020 AtsukiSeo. All rights reserved.
//

import UIKit

class QiitaTagCell: UICollectionViewCell {
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemYellow
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
        let customView = UIImageView()
        customView.backgroundColor = .green
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        idLabel.text = nil
        backgroundColor = UIColor.systemBackground
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.0).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        
        contentView.addSubview(idLabel)
        idLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0).isActive = true
        idLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12.0).isActive = true
        idLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -1 * (12.0 * 3 + 64.0)).isActive = true
        
        if let lastSubview = contentView.subviews.last {
            contentView.bottomAnchor.constraint(equalTo: lastSubview.bottomAnchor, constant: 12).isActive = true
        }
    }
    
    func updateBorderAppearance(borderWidth: CGFloat = 0.25, borderColor: CGColor = UIColor.tertiaryLabel.cgColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    func updateAppearance(viewInStatus: ViewInStatus) {
        if viewInStatus == .viewIn {
            backgroundColor = UIColor.systemBackground
        } else {
            backgroundColor = UIColor.red
        }
    }
    
    func updateAppearance(icon: UIImage?) {
        iconImageView.image = icon
    }
    
    func updateAppearance(indexPath: IndexPath, id: String, icon: UIImage?) {
        idLabel.text = "\(indexPath.item + 1) " + id
        updateAppearance(icon: icon)
    }
}
