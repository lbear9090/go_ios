//
//  EventSectionController.swift
//  Go
//
//  Created by Lucky on 08/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import IGListKit

private enum EventSection: Int {
    case context
    case owner
    case details
    case actions
    
    static func section(for index: Int, includingContext: Bool) -> EventSection? {
        var index = index
        if !includingContext {
            index += 1
        }
        return EventSection(rawValue: index)
    }
}

protocol EventSectionControllerDelegate: AnyObject {
    func showProfileForUser(_ user: UserModel)
    func showDetailsForEvent(_ event: EventModel, goButtonTapped: Bool)
    func showOptionsForEvent(_ event: EventModel)
    func forwardEvent(_ event: EventModel)
    func showTimelineForEvent(_ event: EventModel)
    func showMessagingForEvent(_ event: EventModel)
    func playVideo(view: VideoPlayerView, _ event: EventModel)
    func showShareSheetForEvent(_ event: EventModel)
}

private let STATIC_CELL_COUNT: Int = 3

class EventSectionController: ListSectionController {
    
    private var event: EventModel!
    public weak var delegate: EventSectionControllerDelegate?
    
    private var showContextRow: Bool {
        return self.event.feedContext != nil
    }
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.displayDelegate = self
    }
    
    override func didUpdate(to object: Any) {
        if let feedItem = object as? FeedItemModel {
            self.event = feedItem.event
        } else {
            self.event = object as? EventModel
        }
    }
    
    override func numberOfItems() -> Int {
        var count = STATIC_CELL_COUNT
        count += self.showContextRow ? 1 : 0
        return count
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let context = collectionContext else {
            return UICollectionViewCell()
        }
        
        switch EventSection.section(for: index, includingContext: self.showContextRow) {
        case .context?:
            let cell = context.dequeueReusableCell(of: ContextCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! ContextCollectionViewCell
            if let contextItem = self.event.feedContext {
                cell.populate(with: contextItem)
            }
            return cell
            
        case .owner?:
            let cell = context.dequeueReusableCell(of: ItemOwnerCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! ItemOwnerCollectionViewCell
            cell.populate(with: self.event.host)
            cell.delegate = self
            cell.showShadow = !self.showContextRow
            return cell
            
        case .details?:
            let cell = context.dequeueReusableCell(of: EventDetailsCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! EventDetailsCollectionViewCell
            cell.populate(withEvent: self.event)
            cell.delegate = self
            cell.videoPlayer.videoDelegate = self
            return cell
            
        case .actions?:
            let cell = context.dequeueReusableCell(of: EventActionsCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! EventActionsCollectionViewCell
            cell.populate(withEvent: self.event)
            cell.delegate = self
            return cell
            
        default:
            return UICollectionViewCell()
        }
        
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else {
            return .zero
        }
        
        switch EventSection.section(for: index, includingContext: self.showContextRow) {
        case .context?, .actions?:
            return CGSize(width: context.containerSize.width, height: 34)

        case .details?:
            return CGSize(width: context.containerSize.width, height: Constants.mediaHeight + 74.0)
            
        case .owner?:
            return CGSize(width: context.containerSize.width, height: 44)

        default:
            return .zero
        }
    }
    
    override func didSelectItem(at index: Int) {
        switch EventSection.section(for: index, includingContext: self.showContextRow) {
        case .context?:
            if let user = self.event.feedContext?.actor {
                delegate?.showProfileForUser(user)
            }
            
        case .owner?:
            delegate?.showProfileForUser(self.event.host)
            
        default:
            delegate?.showDetailsForEvent(self.event, goButtonTapped: false)
            break
        }
    }

}

//MARK: - ItemOwnerCollectionViewCellDelegate

extension EventSectionController: ItemOwnerCollectionViewCellDelegate {
    
    func didSelectOptionsButton() {
        delegate?.showOptionsForEvent(self.event)
    }
    
}

//MARK: - EventDetailsCollectionViewCellDelegate

extension EventSectionController: EventDetailsCollectionViewCellDelegate {
    
    func didTapGoButton() {
        delegate?.showDetailsForEvent(self.event, goButtonTapped: true)
    }
    
}

//MARK: - EventActionsCollectionViewCellDelegate

extension EventSectionController: EventActionsCollectionViewCellDelegate {
    
    func didTapForwardButton() {
        delegate?.forwardEvent(self.event)
    }
    
    func didTapTimelineButton() {
        delegate?.showTimelineForEvent(self.event)
    }
    
    func didTapMessagingButton() {
        delegate?.showMessagingForEvent(self.event)
    }
    
    func didTapShareButton() {
        delegate?.showShareSheetForEvent(self.event)
    }
}

// MARK: - ListScrollDelegate

extension EventSectionController: ListDisplayDelegate {
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        // Left empty intentionally
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        // Left empty intentionally
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        // Left empty intentionally
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let eventDetailsCell = cell as? EventDetailsCollectionViewCell {
            eventDetailsCell.stopVideo()
        }
    }
}

// MARK: - View Display Delegate

extension EventSectionController: VideoPlayerViewDelegate {
    func didTapFullScreenButton(_ videoView: VideoPlayerView, videoURL: URL?) {
        delegate?.playVideo(view: videoView, self.event)
    }
}


