//
//  BaseTagsViewController.swift
//  Go
//
//  Created by Lucky on 27/06/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import TagListView
import SnapKit

private let CollectionViewHeight: CGFloat = 40.0

class BaseTagsViewController: SHOScrollViewController, SearchControllerManagerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: - Properties
    private lazy var searchManager = SearchControllerManager(with: self)
    
    private var offset: Int = 0
    private let limit: Int = 100
    private var term: String?
    var selectedTags = [TagView]()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    lazy var tagListView: TagListView = {
        let tagView = TagListView.configuredView()
        tagView.delegate = self;
        return tagView
    }()
    
    //MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.scrollView.addInfiniteScroll { [weak self] scrollView in
            self?.getTags()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBarForUseInTabBar()
        self.searchManager.addSearchController(to: self)
        
        self.getTags()
    }
    
    override func setup() {
        super.setup()
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.separatorView)
        self.contentView.addSubview(self.tagListView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(ScrollViewInset, ScrollViewInset, ScrollViewInset, ScrollViewInset)
        
        self.collectionView.snp.makeConstraints { make in
            make.height.equalTo(CollectionViewHeight)
            make.left.right.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
        }
        
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        self.scrollView.snp.remakeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        self.tagListView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(TagListView.DefaultInset)
        }
        
    }
    
    //MARK: - Networking
    
    private func getTags() {
        if self.tagListView.tagViews.count == 0 {
            self.showSpinner()
        }
        
        SHOAPIClient.shared.tags(forTerm: term,
                                 from: self.offset,
                                 to: self.limit) { (object, error, code) in
                                    self.dismissSpinner()
                                    self.scrollView.finishInfiniteScroll()
                                    
                                    if let error = error {
                                        self.showErrorAlertWith(message: error.localizedDescription)
                                        
                                    } else if let array = object as? [TagModel] {
                                        
                                        if self.offset == 0 && self.tagListView.tagViews.count > 0 {
                                            self.tagListView.removeAllTags()
                                        }
                                        
                                        self.tagListView.addTags(array, withSelected: self.selectedTags)
                                        self.offset = self.tagListView.tagViews.count
                                        
                                    } else {
                                        self.showErrorAlertWith(message: "ERROR_UNKNOWN_MESSAGE".localized)
                                    }
        }
    }
    
    // MARK: - KeyboardNotifications
    
    override func animateLayoutForKeyboard(frame: CGRect) {
        //Don't adjust insets for keyboard frame
    }
    
    //MARK: - SearchControllerManagerDelegate
    
    func searchWithTerm(_ term: String?) {
        self.offset = 0
        self.term = term
        self.getTags()
    }
    
    func searchCancelled() {
        self.offset = 0
        self.term = nil
        self.getTags()
    }
    
    //MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedTags.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reuseIdentifier, for: indexPath)
        if let tagViewCell = cell as? TagCollectionViewCell {
            
            let selectedTag = self.selectedTags[indexPath.row]
            tagViewCell.populate(with: selectedTag)
            
            return tagViewCell
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell,
            let tagView = cell.tagReference {
            
            self.tagListView.selectedTags().first(where: { $0 == tagView })?.isSelected = false
            self.selectedTags = self.selectedTags.filter { $0 != tagView }
            self.invalidateSelectedTags()
        }
    }
    
    func invalidateSelectedTags() {
        self.collectionView.reloadData()
        
        //https://stackoverflow.com/a/50906645/2336734
        if #available(iOS 10.0, *) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}

//MARK: - TagListViewDelegate

extension BaseTagsViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        if tagView.isSelected {
            tagView.isSelected = false
            self.selectedTags = self.selectedTags.filter { $0 != tagView }
        } else {
            tagView.isSelected = true
            self.selectedTags.append(tagView)
        }
        
        self.invalidateSelectedTags()
        
        if self.selectedTags.count > 0 && tagView.isSelected {
            let indexPath = IndexPath(item: self.selectedTags.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
    
}

