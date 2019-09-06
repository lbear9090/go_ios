//
//  SHOTableViewController.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit

fileprivate let Offset = 0
fileprivate let Limit = 20
fileprivate let PagingStartIndex = 10

class SHOTableViewController: SHOViewController, SHOKeyboardNotifications, SHOEmptyState {
    
    var keyboardNotificationObservers: [NSObjectProtocol] = []
    
    typealias SHORequestObjectCompletion = (_ object: Any?, _ error: Error?) -> Void
    
    var tableView: UITableView!
    var defaultBackgroundView: UIView? = nil
    
    var items: Array<Any>?
    var offset: Int = Offset
    var limit: Int = Limit
    var pagingStartIndex: Int = PagingStartIndex
    var shouldResetScroll: Bool = false
    
    fileprivate var refreshControl: UIRefreshControl?
    fileprivate var isRefreshing: Bool = false
    
    weak var refreshControlDelegate: SHORefreshable? {
        didSet {
            self.refreshControl = UIRefreshControl()
            self.refreshControl!.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            self.tableView.addSubview(self.refreshControl!)
            
            if let _ = refreshControlDelegate?.paginatable {
                self.tableView.setShouldShowInfiniteScrollHandler({ [unowned self] (tableView) -> Bool in
                    return self.offset > self.pagingStartIndex
                })
                
                self.tableView.addInfiniteScroll { [unowned self] (tableView) -> Void in
                    self.paginateData()
                }
            }
        }
    }
    
    var style: UITableViewStyle {
        return .plain
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
        
        if self.shouldResetScroll {
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshData();
    }
    
    override func loadView() {
        super.loadView()
        self.setupTableView()
        self.view.sendSubview(toBack: self.tableView)
    }
    
    func setupTableView() {
        self.tableView = UITableView(frame: .zero, style: self.style)
        
        self.tableView.backgroundColor = .tableViewBackground
        self.tableView.separatorStyle = .none
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        
        self.view.addSubview(self.tableView)
    }
    
    override func applyConstraints() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func refreshData() {
        self.offset = 0
        self.paginateData()
    }
    
    func paginateData() {
        guard self.isRefreshing == false else {
            return
        }
        
        self.isRefreshing = true
        self.refreshControlDelegate?.loadData()
    }
    
    // MARK: - Helpers
    
    func item<T>(at indexPath: IndexPath) -> T? {
        return self.items?[indexPath.row] as? T
    }
    
    // MARK: - KeyboardNotifications
    
    func animateLayoutForKeyboard(frame: CGRect) {
        self.tableView.setContentInsetsForKeyboard(with: frame)
    }
    
    // MARK: - SHOEmptyState
    
    var emptyStateView: UIView? {
        let emptyView = EmptyStateView()
        emptyView.label.text = self.emptyStateText
        return emptyView
    }
    
    public var emptyStateText: String {
        return "EMPTY_STATE_MESSAGE".localized
    }
    
    var isEmpty: Bool {
        guard let items = self.items else {
            return true
        }
        return items.count < 1
    }
    
}

// MARK: - CompletionHandler

extension SHOTableViewController {
    
    var sharedCompletionHandler: SHORequestObjectCompletion {
        return { (object: Any?, error: Error?) in
            
            if let error = error {
                self.showErrorAlertWith(message: error.localizedDescription)
            } else {
                if
                    let _ = self.items, self.offset != 0,
                    let array = object as? Array<Any> {
                    
                    if !array.isEmpty {
                        self.items?.append(contentsOf: array)
                    }

                } else {
                    self.items = object as? Array<Any>
                }
            }
            
            if let _ = self.refreshControlDelegate?.paginatable {
                self.offset = self.items?.count ?? self.offset
            }
            
            self.isRefreshing = false
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.tableView.finishInfiniteScroll()
                self.tableView.backgroundView = self.isEmpty ? self.emptyStateView : self.defaultBackgroundView
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SHOTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableview: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate

extension SHOTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
