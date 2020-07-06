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
    static let tagCellIdentifier = "qiitaTagCell"
    /// 保存するデータ数の最大値
    static let maxDataCount = 1000
    static let cellHeight: CGFloat = 88.0
    
    let qiitaTagDataStore = QiitaTagDataStore()
    let qiitaTagImageLoadingOperationQueue = OperationQueue()
    var qiitaTagImageLoadingOperations: [IndexPath: QiitaTagImageOperation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        qiitaTagDataStore.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        fetchQiitaTags()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }

    @IBAction func refreshButtonDidTap(_ sender: Any) {
        fetchQiitaTags()
    }
    
    func fetchQiitaTags() {
        qiitaTagDataStore.fetchTags(page: 1, perPage: 100, sort: .count)
    }
    
    func cancelLoadingTagImageIfNeed(indexPath: IndexPath) {
        guard let dataLoader = qiitaTagImageLoadingOperations[indexPath] else { return }
        dataLoader.cancel()
        qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: ViewController.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard qiitaTagImageLoadingOperations[indexPath] == nil else { continue }
            let tag =  qiitaTagDataStore.tags[indexPath.row]
            if let tagImageURL = URL(string: tag.icon_url),
                let operation = qiitaTagDataStore.loadTagImage(index: indexPath.item, tagImageURL: tagImageURL) {
                qiitaTagImageLoadingOperationQueue.addOperation(operation)
                qiitaTagImageLoadingOperations[indexPath] = operation
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths { cancelLoadingTagImageIfNeed(indexPath: indexPath) }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qiitaTagDataStore.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.tagCellIdentifier,
                                                            for: indexPath) as? QiitaTagCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tag =  qiitaTagDataStore.tags[indexPath.row]
        cell.layer.borderWidth = 0.25
        cell.layer.borderColor = UIColor.black.cgColor
        
        let updateCellClosure: (UIImage?, Error?) -> () = { image, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let image = image else { return }
                cell.updateAppearance(icon: image)
                self.qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
            }
        }
        if let dataLoader = qiitaTagImageLoadingOperations[indexPath] {
            if let tagImage = dataLoader.tagImage {
                updateCellClosure(tagImage, nil)
            } else {
                dataLoader.completionHandler = updateCellClosure
            }
        } else {
            if let tagImageURL = URL(string: tag.icon_url),
                let operation = qiitaTagDataStore.loadTagImage(index: indexPath.item, tagImageURL: tagImageURL) {
                qiitaTagImageLoadingOperationQueue.addOperation(operation)
                qiitaTagImageLoadingOperations[indexPath] = operation
            }
        }
        cell.updateAppearance(id: tag.id, followers: "\(tag.followers_count)", icon: nil)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? QiitaTagCellCollectionViewCell else { return }
        let updateCellClosure: (UIImage?, Error?) -> () = { image, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let image = image else { return }
                cell.iconImageView.image = image
                self.qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
            }
        }
        if let dataLoader = qiitaTagImageLoadingOperations[indexPath] {
            if let tagImage = dataLoader.tagImage {
                updateCellClosure(tagImage, nil)
            } else {
                dataLoader.completionHandler = updateCellClosure
            }
        } else {
            let tag = qiitaTagDataStore.tags[indexPath.row]
            if let tagImageURL = URL(string: tag.icon_url),
                let operation = qiitaTagDataStore.loadTagImage(index: indexPath.item, tagImageURL: tagImageURL) {
                qiitaTagImageLoadingOperationQueue.addOperation(operation)
                qiitaTagImageLoadingOperations[indexPath] = operation
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        cancelLoadingTagImageIfNeed(indexPath: indexPath)
    }
}

extension ViewController: QiitaTagDataStoreDelegate {
    func qiitaTagDataStore(_: QiitaTagDataStore, didReceiveTags tags: [QiitaTag]) {
        collectionView.reloadData()
    }
    
    func qiitaTagDataStore(_: QiitaTagDataStore, didInvalidReceiveTagWithError error: Error) {}
}
