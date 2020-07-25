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
    let refreshControl = UIRefreshControl()
    var footerLoadingView: QiitaTagFooterCollectionReusableView?
    
    static let perPage = 20
    static let tagCellIdentifier = "qiitaTagCell"
    static let cellHeight: CGFloat = 88.0
    static let detailSegueIdentifier = "detailSegue"
    
    private(set) var selectedQiitaTag: QiitaTag?
    private(set) var isFromDetailVC: Bool = false
    let qiitaTagDataStore = QiitaTagDataStore()
    let qiitaTagImageLoadingOperationQueue = OperationQueue()
    var qiitaTagImageLoadingOperations: [IndexPath: QiitaTagImageOperation] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        qiitaTagDataStore.delegate = self
        collectionView.register(QiitaTagCell.self, forCellWithReuseIdentifier: ViewController.tagCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        reloadCollectionViewLayout()
        fetchQiitaTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromDetailVC {
            collectionView.reloadData()
            isFromDetailVC = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelAllOperationLoadingTagImageIfNeed()
        footerViewStopAnimationIfNeed()
        footerLoadingView = nil
        selectedQiitaTag = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        reloadCollectionViewLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        reloadCollectionViewLayout()
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? QiitaTagDetailViewController, let selectedQiitaTag = selectedQiitaTag {
            detailVC.tag = selectedQiitaTag
            isFromDetailVC = true
        }
    }

    @IBAction func refreshButtonDidTap(_ sender: Any) {
        refreshQiitaTags()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        refreshQiitaTags()
    }
    
    func refreshQiitaTags(perPage: Int = ViewController.perPage * 2) {
        qiitaTagImageLoadingOperationQueue.cancelAllOperations()
        qiitaTagImageLoadingOperations.forEach { (key, qiitaTagImageLoadingOperation) in
            qiitaTagImageLoadingOperation.cancel()
        }
        qiitaTagImageLoadingOperations = [:]
        qiitaTagDataStore.fetchTags(page: 1, perPage: perPage, sort: .count, isReset: true)
    }
    
    func fetchQiitaTags(perPage: Int = ViewController.perPage) {
        qiitaTagDataStore.fetchTags(perPage: perPage, sort: .count)
    }
    
    func startOperationLoadingTagImageIfNeed(indexPath: IndexPath,
                                             completionHandler: @escaping (UIImage?, Error?) -> Void) {
        guard let tag = qiitaTagDataStore.tagAt(index: indexPath.item) else { return }
        if let dataLoader = qiitaTagImageLoadingOperations[indexPath] {
            if let tagImage = dataLoader.tagImage {
                completionHandler(tagImage, nil)
            } else {
                dataLoader.completionHandler = completionHandler
            }
        } else {
            if let tagImageURL = URL(string: tag.icon_url),
                let operation = qiitaTagDataStore.loadTagImage(index: indexPath.item, tagImageURL: tagImageURL) {
                qiitaTagImageLoadingOperationQueue.addOperation(operation)
                qiitaTagImageLoadingOperations[indexPath] = operation
            }
        }
    }
    
    func cancelOperationLoadingTagImageIfNeed(indexPath: IndexPath) {
        guard let dataLoader = qiitaTagImageLoadingOperations[indexPath] else { return }
        dataLoader.cancel()
        qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
    }
    
    func cancelAllOperationLoadingTagImageIfNeed() {
        qiitaTagImageLoadingOperationQueue.cancelAllOperations()
        qiitaTagImageLoadingOperations.forEach { (key, qiitaTagImageLoadingOperation) in
            qiitaTagImageLoadingOperation.cancel()
        }
        qiitaTagImageLoadingOperations = [:]
    }
    
    func footerViewStartAnimationIfNeed() {
        guard let footerView = self.footerLoadingView else {
            return
        }
        footerView.activityIndicator.startAnimating()
    }
    
    func footerViewStopAnimationIfNeed() {
        guard let footerView = self.footerLoadingView else {
            return
        }
        footerView.activityIndicator.stopAnimating()
    }
    
    func reloadCollectionViewLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: view.bounds.height)
        }
        collectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for index in 0..<collectionView.numberOfItems(inSection: 0) {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? QiitaTagCell else {
                continue
            }
            let edgeInsets = createEdgeInsetIfNeed()
            let cellBounds = CollectionViewCellUtil.shared.calculateCellNowBounds(collectionView: collectionView,
                                                                                  cell: cell)
            let viewInStatus = ViewInChecker.shared.checkViewInStatus(rect: cellBounds, ratio: 0.5, edgeInsets: edgeInsets)
            cell.updateAppearance(viewInStatus: viewInStatus)
        }
    }
    
    func createEdgeInsetIfNeed() -> UIEdgeInsets {
        var top: CGFloat = 0.0
        var bottom: CGFloat = 0.0
        if let statusBarManager = view.window?.windowScene?.statusBarManager {
            top += statusBarManager.statusBarFrame.height
        }
        if let navigationBar = navigationController?.navigationBar {
            top += navigationBar.frame.size.height
        }
        if let tabBar = tabBarController?.tabBar {
            bottom += tabBar.frame.height
        }
        
        return UIEdgeInsets(top: top, left: 0.0, bottom: bottom, right: 0.0)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = qiitaTagDataStore.tagAt(index: indexPath.item) else { return }
        self.selectedQiitaTag = tag
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if qiitaTagDataStore.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50.0)
        }
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
            guard let tag = qiitaTagDataStore.tagAt(index: indexPath.item) else { continue }
            guard qiitaTagImageLoadingOperations[indexPath] == nil else { continue }
            if let tagImageURL = URL(string: tag.icon_url),
                let operation = qiitaTagDataStore.loadTagImage(index: indexPath.item, tagImageURL: tagImageURL) {
                qiitaTagImageLoadingOperationQueue.addOperation(operation)
                qiitaTagImageLoadingOperations[indexPath] = operation
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths { cancelOperationLoadingTagImageIfNeed(indexPath: indexPath) }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qiitaTagDataStore.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tag = qiitaTagDataStore.tagAt(index: indexPath.item),
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.tagCellIdentifier,
                                                            for: indexPath) as? QiitaTagCell else {
            return UICollectionViewCell()
        }

        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor.tertiaryLabel
        cell.selectedBackgroundView = selectedBackgroundView
    
        cell.updateBorderAppearance()
        // セルの高さが動的に変更することを確認するために改行をランダムに3 ~ 10行挿入する形にしている
        let text = tag.id + RandomStringGenerator.shared.generate(length: Int.random(in: 3..<10))
        cell.updateAppearance(indexPath: indexPath, id: text, icon: nil)
        startOperationLoadingTagImageIfNeed(indexPath: indexPath) { (image, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let image = image else { return }
                cell.updateAppearance(icon: image)
                self.qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
            }
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? QiitaTagCell else { return }
        startOperationLoadingTagImageIfNeed(indexPath: indexPath) { (image, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let image = image else { return }
                cell.updateAppearance(icon: image)
                self.qiitaTagImageLoadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        cancelOperationLoadingTagImageIfNeed(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "timelineFooter", for: indexPath) as? QiitaTagFooterCollectionReusableView else {
            return UICollectionReusableView()
        }
        footerView.activityIndicator.hidesWhenStopped = true
        footerView.activityIndicator.stopAnimating()
        self.footerLoadingView = footerView
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        footerViewStartAnimationIfNeed()
        fetchQiitaTags()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        footerViewStopAnimationIfNeed()
    }
}

extension ViewController: QiitaTagDataStoreDelegate {
    func qiitaTagDataStore(_: QiitaTagDataStore, didReceiveTags tags: [QiitaTag]) {
        refreshControl.endRefreshing()
        collectionView.reloadData()
        footerViewStopAnimationIfNeed()
        footerLoadingView = nil
    }
    
    func qiitaTagDataStore(_: QiitaTagDataStore, didInvalidReceiveTagWithError error: Error) {}
}
