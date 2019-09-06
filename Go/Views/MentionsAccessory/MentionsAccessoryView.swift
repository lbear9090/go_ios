//
//  MentionsAccessoryView.swift
//  Go
//
//  Created by Lucky on 04/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol MentionsAccessoryViewDelegate {
    func didSelectMetion(_ mentionString: String)
}

class MentionsAccessoryView: SHOView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: MentionsAccessoryViewDelegate?
    
    var datasource = [String]() {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
    private let reuseId = MentionCollectionViewCell.reuseIdentifier
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = CGSize(width: 50, height: self.bounds.height)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(MentionCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseId)
        
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()

    override func setup() {
        self.addSubview(self.collectionView)
        self.addSubview(self.separatorView)
    }
    
    override func applyConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.separatorView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    //MARK - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseId, for: indexPath)
        guard let mentionCell = cell as? MentionCollectionViewCell else {
            return cell
        }
        mentionCell.textLabel.text = datasource[indexPath.row]
        return mentionCell
    }
    
    //MARK - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mention = datasource[indexPath.row]
        self.delegate?.didSelectMetion(mention)
    }
}
