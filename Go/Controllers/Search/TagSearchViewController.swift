//
//  TagSearchViewController.swift
//  Go
//
//  Created by Lucky on 25/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

class TagSearchViewController: SHOTableViewController, SearchSegmentController, SHORefreshable, SHOPaginatable {
    
    var segmentTitle: String = "TAGS_SEARCH".localized
    var lastSearchedTerm: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControlDelegate = self
    }
    
    func loadResults(for term: String? = nil) {
        self.offset = 0
        self.fetchResults(for: term)
    }
    
    func loadData() {
        self.fetchResults(for: self.lastSearchedTerm)
    }
    
    func fetchResults(for term: String?) {
        SHOAPIClient.shared.tags(forTerm: term, from: self.offset, to: self.limit) { (object, error, code) in
            self.sharedCompletionHandler(object, error)
        }
    }
    
}

//MARK: Tableview datasource

extension TagSearchViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = SearchTableViewCell.reusableCell(from: tableView)
        cell.imageView?.image = .searchHashTag

        if let tag: TagModel = item(at: indexPath) {
            cell.titleLabel.text = tag.text
            cell.detailLabel.text = String(format: "TAG_POSTS_COUNT".localized, arguments: [tag.count])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let tag: TagModel = item(at: indexPath) {
            let controller = FeedViewController(with: TagEventsDataProvider(withTag: tag.text))
            controller.title = "#\(tag.text)"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
