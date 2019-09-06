//
//  SelectFriendsViewController.swift
//  Go
//
//  Created by Lucky on 08/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import SnapKit

private let CollectionViewHeight: CGFloat = 100

class SelectFriendsViewController: SHOTableViewController {
    
    var selectedUsers: [UserModel] = [UserModel]() {
        didSet {
            self.showSelectedView(selectedUsers.count > 0)
        }
    }
    
    var collectionViewTopConstraint: Constraint?
    private var collectionViewHeightConstraint: Constraint?
    var tableViewBottomConstraint: Constraint?
    
    lazy var searchManager = SearchControllerManager(with: self)
    var searchString: String?

    private let separatorLayer = CALayer()

    lazy var selectionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: CollectionViewHeight * 0.75, height: CollectionViewHeight)
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .tableViewBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectedUserCollectionViewCell.self,
                                forCellWithReuseIdentifier: SelectedUserCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchManager.addSearchController(to: self)
        self.loadSearchResults()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !(self.selectionCollectionView.layer.sublayers?.contains(self.separatorLayer) ?? false) {
            self.separatorLayer.backgroundColor = UIColor.tableViewCellSeparator.cgColor
            selectionCollectionView.layer.addSublayer(self.separatorLayer)
        }

        let bounds = selectionCollectionView.bounds
        self.separatorLayer.frame = CGRect(x: 0, y: bounds.maxY - 0.5, width: bounds.width, height: 0.5)
    }
    
    // MARK: Setup
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.selectionCollectionView)
    }
    
    override func applyConstraints() {
        
        self.selectionCollectionView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.selectionCollectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                self.collectionViewTopConstraint = make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).constraint
            } else {
                self.collectionViewTopConstraint = make.top.equalTo(self.topLayoutGuide.snp.bottom).constraint
            }
            make.left.right.equalToSuperview()
            self.collectionViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        self.tableView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            self.tableViewBottomConstraint = make.bottom.equalToSuperview().constraint
            make.top.equalTo(self.selectionCollectionView.snp.bottom)
        }
    
    }
    
    public func showSelectedView(_ show: Bool) {
        let offset = show ? CollectionViewHeight : 0
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut, .transitionCrossDissolve],
                       animations: {
                        self.collectionViewHeightConstraint?.update(offset: offset)
                        self.selectionCollectionView.collectionViewLayout.invalidateLayout()
                        self.view.layoutIfNeeded()
        },
                       completion: { (completed) in
                        self.selectionCollectionView.reloadData()
        })
    }
    
    // MARK: Actions
    
    func loadSearchResults() {
        SHOAPIClient.shared.getFriends(withSearchTerm: self.searchString,
                                       limit: self.limit,
                                       offset: self.offset) { object, error, code in
            self.sharedCompletionHandler(object, error)
        }
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserTableViewCell = UserTableViewCell.reusableCell(from: tableView)
        cell.accessoryType = .checkmark
        cell.selectionStyle = .none
        
        if let user: UserModel = item(at: indexPath) {
            let userSelected = self.selectedUsers.contains(user)
            cell.tintColor = userSelected ? .green : .clear
            cell.populate(with: user)
            
            cell.attendingIconTappedHandler = { [unowned self] in
                let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
                controller.initialEventsType = .attending
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        } else {
            cell.tintColor = .clear
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let user: UserModel = item(at: indexPath) {
            if let index = self.selectedUsers.index(of: user) {
                self.selectedUsers.remove(at: index)
            }
            else {
                self.selectedUsers.append(user)
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

// MARK: - UICollectionViewDataSource

extension SelectFriendsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = SelectedUserCollectionViewCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath)
        
        let user = self.selectedUsers[indexPath.row]
        if let cell = cell as? SelectedUserCollectionViewCell {
            cell.populate(with: user)
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension SelectFriendsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = self.selectedUsers[indexPath.row]
        if let index = self.selectedUsers.index(of: user) {
            self.selectedUsers.remove(at: index)
        }
        self.tableView.reloadData()
    }
    
}

// MARK: - SearchControllerManagerDelegate

extension SelectFriendsViewController: SearchControllerManagerDelegate {
    
    func searchWithTerm(_ term: String?) {
        self.offset = 0
        self.searchString = term
        self.loadSearchResults()
    }
    
    func searchCancelled() {
        self.offset = 0
        self.searchString = nil
        self.loadSearchResults()
    }
    
}

