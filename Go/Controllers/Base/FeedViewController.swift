//
//  NewsFeedViewController.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import IGListKit
import AVKit

typealias FeedDataRequestClosure = ([ListDiffable]?, Error?) -> Void
typealias CachedFeedDataRequestClosure = ([ListDiffable]?) -> Void

protocol FeedDataProvider {
    func getItemsWithRequest(_ request: FeedDataRequestModel, completionHandler: @escaping FeedDataRequestClosure)
    func getCachedItems(completionHandler: @escaping CachedFeedDataRequestClosure)
    var emptyStateString: String { get }
}

extension FeedDataProvider {
    func getCachedItems(completionHandler: @escaping CachedFeedDataRequestClosure) {
        completionHandler(nil)
    }
}

extension FeedDataProvider {
    var emptyStateString: String {
        return "EMPTY_STATE_MESSAGE".localized
    }
}

let InfinitePagingSecionToken: String = "InfinitePagingSecion"

class FeedViewController: SHOViewController, EventSectionControllerDelegate, TimelineSectionControllerDelegate, ListAdapterDataSource, UIScrollViewDelegate {
    
    var request = FeedDataRequestModel()

    public let dataProvider: FeedDataProvider
    private var datasourceArray = [ListDiffable]()
    private var initialLoadCompleted: Bool = false
    private var loading = false
    private var currentUser: UserModel?
    
    private lazy var optionsManager = OptionsAlertManager(for: self)
    
    let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = self.refreshControl
        
        return collectionView
    }()

    lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    
    var eventSectionController: EventSectionController {
        let eventSectionController = EventSectionController()
        eventSectionController.delegate = self
        return eventSectionController
    }
    
    var timelineSectionController: TimelineSectionController {
        let timelineSectionController = TimelineSectionController()
        timelineSectionController.delegate = self
        return timelineSectionController
    }
    
    //MARK: - Init methods

    init(with dataProvider: FeedDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        
        CacheManager.getCurrentUser(withFallbackPolicy: .network(controller: self)) { (user, error) in
            self.currentUser = user
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adapter.performUpdates(animated: true)
        self.refreshData()
        self.collectionView.reloadData()
    }
    
    override func setup() {
        self.view.addSubview(self.collectionView)
        adapter.collectionView = self.collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    override func applyConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Networking
    
    func loadData() {
        if self.datasourceArray.count == 0 {
            self.dataProvider.getCachedItems { [weak self] items in
                if let items = items {
                    self?.datasourceArray = items
                    self?.adapter.reloadObjects(items)
                    
                    self?.dismissSpinner()
                } else {
                    self?.showSpinner()
                }
                
                self?.getItems()
            }
        } else {
            self.getItems()
        }
    }
    
    private func getItems() {
        self.dataProvider.getItemsWithRequest(self.request) { [weak self] (items, error) in
            self?.initialLoadCompleted = true
            self?.loading = false
            self?.dismissSpinner()
            self?.refreshControl.endRefreshing()
            
            if let error = error {
                self?.showErrorAlertWith(message: error.localizedDescription)
            } else if let items = items {
                
                if self?.request.offset == 0 {
                    self?.datasourceArray = items
                    self?.adapter.reloadObjects(items)
                } else {
                    self?.datasourceArray.append(contentsOf: items)
                }
                self?.adapter.performUpdates(animated: true)
            }
        }
    }

    @objc func refreshData() {
        self.initialLoadCompleted = false
        self.request.offset = 0
        self.loadData()
    }
    
    //MARK: - ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects = self.datasourceArray
        
        if self.loading {
            objects.append(InfinitePagingSecionToken as ListDiffable)
        }
        
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is FeedItemModel:
            if let feedItem = object as? FeedItemModel {
                switch feedItem.type {
                case .event:
                    return self.eventSectionController
                case .timeline:
                    return self.timelineSectionController
                }
            } else {
                fallthrough
            }
        case is EventModel:
            return self.eventSectionController
            
        case is TimelineModel:
            return self.timelineSectionController
            
        case is String:
            if object as! String == InfinitePagingSecionToken {
                return self.spinnerSectionController
            } else {
                fallthrough
            }
            
        default:
            fatalError("You must supply corresponding setion controller for each model type")
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        guard self.initialLoadCompleted else {
            return nil
        }
        let emptyView = EmptyStateView(frame: self.view.frame)
        emptyView.label.text = self.dataProvider.emptyStateString
        return emptyView
    }
    
    private var spinnerSectionController: ListSingleSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            if let cell = cell as? SpinnerCollectionViewCell {
                cell.activityIndicator.startAnimating()
            }
        }
        
        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else {
                return .zero
            }
            return CGSize(width: context.containerSize.width, height: 100)
        }
        
        return ListSingleSectionController(cellClass: SpinnerCollectionViewCell.self,
                                           configureBlock: configureBlock,
                                           sizeBlock: sizeBlock)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //FIXME: - This calculation can be improved
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        
        if !self.loading && distance < 50 {
            self.loading = true

            self.request.offset = self.datasourceArray.count
            self.adapter.performUpdates(animated: true, completion: nil)
            self.loadData()
        }
    }
    
    //MARK: - EventSectionControllerDelegate & TimelineSectionControllerDelegate
    
    func showProfileForUser(_ user: UserModel) {
        let controller = UserProfileViewController.controllerForUserWithId(userId: user.userId, userModel: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showDetailsForEvent(_ event: EventModel, goButtonTapped: Bool) {
        let controller = EventViewController(withEventModel: event)
        //Don't animate Go button in details controller if current user is the host
        controller.animateButton = goButtonTapped && currentUser != event.host
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showOptionsForEvent(_ event: EventModel) {
        self.optionsManager.showOptions(forEvent: event) { [unowned self] in
            self.adapter.performUpdates(animated: true)
        }
    }
    
    func forwardEvent(_ event: EventModel) {
        let controller = EventForwardingViewController(eventId: event.eventId)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTimelineForEvent(_ event: EventModel) {
        let dataProvider = TimelineDataProvider(eventId: event.eventId)
        let controller = EventTimelineViewController(with: dataProvider,
                                                     eventId: event.eventId,
                                                     eventTitle: event.title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showMessagingForEvent(_ event: EventModel) {
        guard let controller = ConversationThreadViewController(conversationID: event.conversationID) else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTimeline(_ timeline: TimelineModel) {
        let dataProvider = TimelineDataProvider(eventId: timeline.associatedEventId)
        let controller = EventTimelineViewController(with: dataProvider,
                                                     eventId: timeline.associatedEventId,
                                                     eventTitle: timeline.associatedEventTitle)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showOptionsForTimeline(_ timeline: TimelineModel) {
        self.optionsManager.showOptions(forTimeline: timeline) { [unowned self] in
            self.refreshData()
        }
    }
    
    func showCommentsForTimeline(_ timeline: TimelineModel) {
        let controller = CommentsViewController(eventId: timeline.associatedEventId, timelineId: timeline.id)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentFullscreenImage(withUrl urlString: String) {
        SHOImageViewerUtils(controller: self, objects: [urlString]).show()
    }
    
    func playVideo(withUrl urlString: String, view: VideoPlayerView) {
        if let videoUrl = URL(string: urlString) {
            let playerController = AVPlayerViewController.configured(with: videoUrl, startPosition: view.player?.currentTime())
            playerController.actionHandler = { [unowned view] (controller) in
                if let seekTime = controller.player?.currentTime() {
                    view.player?.seek(to: seekTime)
                    view.playButtonPressed()
                }
            }
            self.present(playerController, animated: true) {
                playerController.player?.play()
            }
        }
    }
    
    func playVideo(view: VideoPlayerView, _ event: EventModel) {
        if let mediaItem = event.mediaItems.first,
            let videoURLStr = mediaItem.videoUrl {
            self.playVideo(withUrl: videoURLStr, view: view)
        }
    }
    
    func showShareSheetForEvent(_ event: EventModel) {
        self.optionsManager.configureBranchObjectForSharing(event)
        self.optionsManager.showSharingOptions(event: event)
    }
}
