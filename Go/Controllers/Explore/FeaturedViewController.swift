//
//  FeaturedViewController.swift
//  Go
//
//  Created by Lucky on 11/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import ADMozaicCollectionViewLayout

class FeaturedViewController: SHOViewController {
    
    private var sections = [FeaturedSectionModel]()
    private var request = FeedDataRequestModel()
    
    private let toolbarView: UIView = {
        let view: UIView = UIView.newAutoLayout()
        view.backgroundColor = .green
        return view
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("FILTER".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
        return refresh
    }()

    lazy var collectionView: UICollectionView = {
        let layout = ADMozaikLayout(delegate: self)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = self.refreshControl
        
        let reuseId = FeaturedCollectionViewCell.reuseIdentifier
        
        collectionView.register(FeaturedCollectionViewCell.self,
                                forCellWithReuseIdentifier: reuseId + FeaturedItemSize.small.rawValue)
        
        collectionView.register(FeaturedCollectionViewCell.self,
                                forCellWithReuseIdentifier: reuseId + FeaturedItemSize.medium.rawValue)
        
        collectionView.register(FeaturedCollectionViewCell.self,
                                forCellWithReuseIdentifier: reuseId + FeaturedItemSize.large.rawValue)
        
        collectionView.addInfiniteScroll { [unowned self] (collectionView) in
            self.fetchItems()
        }
        
        return collectionView
    }()
    
    //MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchItems()
    }
    
    override func setup() {
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.toolbarView)
        
        self.toolbarView.addSubview(self.dividerView)
        self.toolbarView.addSubview(self.filterButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.toolbarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.dividerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.filterButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview().inset(8)
            make.width.equalTo(50)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.top.equalTo(self.toolbarView.snp.bottom)
        }
    }
    
    //MARK: - Networking
    
    @objc func refreshItems() {
        self.request.offset = 0
        self.fetchItems()
    }
    
    func fetchItems() {
        if let cachedFeed = try? CacheManager.getFeatureFeedItems(), let feed = cachedFeed, self.request.offset == 0 {
            self.sections = feed
            self.collectionView.reloadData()
        } else if self.request.offset == 0 {
            self.showSpinner()
        }
        
        SHOAPIClient.shared.getFeaturedFeed(with: self.request) { (object, error, code) in
            self.dismissSpinner()
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else if let response = object as? FeaturedFetchModel {
                if self.request.offset == 0 {
                    self.sections.removeAll()
                    self.collectionView.reloadData()
                    
                    let _ = try? CacheManager.storeFeatureFeed(response.sections)
                }
                
                self.orderItems(in: response.sections)
                self.sections.append(contentsOf: response.sections)
                self.request.offset += response.offset
                
                if response.offset != 0 {
                    self.collectionView.reloadData()
                }

                self.collectionView.finishInfiniteScroll()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: - Helpers
    
    func orderItems(in sections: [FeaturedSectionModel]) {
        sections.filter { section -> Bool in
            return section.type == .rightMedium
            }.forEach { section in
                section.items.swapAt(1, 2)
        }
    }
    
    // MARK: - User Action
    
    @objc private func filterButtonTapped() {
        let filterController = FiltersViewController(with: self.request)
        filterController.selectionHandler = { [weak self] (selectedParams) in
            self?.request = selectedParams
            self?.refreshItems()
        }
        let navController = UINavigationController.init(rootViewController: filterController)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDataSource

extension FeaturedViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
    
        let reuseId = FeaturedCollectionViewCell.reuseIdentifier + item.size.rawValue
        let cell: FeaturedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! FeaturedCollectionViewCell
        cell.populate(with: item.event)
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension FeaturedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.sections.count > indexPath.section else {
            return
        }
        let section = self.sections[indexPath.section]
        
        guard section.items.count > indexPath.row else {
            return
        }
        let item = section.items[indexPath.row]
        
        let controller = EventViewController(withEventModel: item.event)
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

//MARK: - ADMozaikLayoutDelegate

extension FeaturedViewController: ADMozaikLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, mozaik layout: ADMozaikLayout, mozaikSizeForItemAt indexPath: IndexPath) -> ADMozaikLayoutSize {
        
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        switch item.size {
        case .small:
            return ADMozaikLayoutSize(numberOfColumns: 2, numberOfRows: 2)

        case .medium:
            return ADMozaikLayoutSize(numberOfColumns: 3, numberOfRows: 3)
            
        case .large:
            return ADMozaikLayoutSize(numberOfColumns: 4, numberOfRows: 4)
        }
    }
    
    func collectonView(_ collectionView: UICollectionView, mozaik layoyt: ADMozaikLayout, geometryInfoFor section: ADMozaikLayoutSection) -> ADMozaikLayoutSectionGeometryInfo {
        let columnsCount = 6
        let dimension = collectionView.bounds.width / CGFloat(columnsCount)
        
        var columns = [ADMozaikLayoutColumn]()
        for _ in 0..<columnsCount {
            columns.append(ADMozaikLayoutColumn(width: dimension))
        }
        
        return ADMozaikLayoutSectionGeometryInfo(rowHeight: dimension,
                                                 columns: columns,
                                                 minimumInteritemSpacing: 0,
                                                 minimumLineSpacing: 0)
    }
}

//MARK: - SegmentController

extension FeaturedViewController: SegmentController {
    var segmentTitle: String {
        return "FEATURED_TITLE".localized
    }
}
