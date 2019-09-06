//
//  TimelineSectionController.swift
//  Go
//
//  Created by Lucky on 10/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import IGListKit
import AVKit

private enum TimelineSection: Int {
    case context
    case owner
    case cover
    case actions
    case commentsCount
    
    static func section(for index: Int, includingContext: Bool) -> TimelineSection? {
        var index = index
        if !includingContext {
           index += 1
        }
        return TimelineSection(rawValue: index)
    }
}

protocol TimelineSectionControllerDelegate: AnyObject, SHOErrorAlert {
    func showTimeline(_ timeline: TimelineModel)
    func showOptionsForTimeline(_ timeline: TimelineModel)
    func showCommentsForTimeline(_ timeline: TimelineModel)
    func showProfileForUser(_ user: UserModel)
    func playVideo(withUrl urlString: String, view: VideoPlayerView)
    func presentFullscreenImage(withUrl urlString: String)
}

private let STATIC_CELL_COUNT: Int = 3

class TimelineSectionController: ListSectionController {
    
    private var timeline: TimelineModel!
    public weak var delegate: TimelineSectionControllerDelegate?
    
    private var contextRowAvailable: Bool {
        return self.timeline.feedContext != nil
    }
    
    private var showCommentCountRow: Bool {
        return self.self.timeline.commentCount > 2
    }

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.displayDelegate = self
    }
    
    private func adjustedIndex(from index: Int) -> Int {
        var offset = STATIC_CELL_COUNT
        offset += self.contextRowAvailable ? 1 : 0
        offset += self.showCommentCountRow ? 1 : 0
        return index - offset
    }
    
    override func didUpdate(to object: Any) {
        if let feedItem = object as? FeedItemModel {
            self.timeline = feedItem.timelineItem
        }
        else {
            self.timeline = object as? TimelineModel
        }
    }
    
    override func numberOfItems() -> Int {
        var count = STATIC_CELL_COUNT
        count += self.contextRowAvailable ? 1 : 0
        count += self.showCommentCountRow ? 1 : 0
        count += self.timeline.comments.count
        return count
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let context = collectionContext else {
            return UICollectionViewCell()
        }
        
        switch TimelineSection.section(for: index, includingContext: self.contextRowAvailable) {
        case .context?:
            let cell = context.dequeueReusableCell(of: ContextCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! ContextCollectionViewCell
            if let context = self.timeline.feedContext {
                cell.populate(with: context)
            }
            return cell

        case .owner?:
            let cell = context.dequeueReusableCell(of: ItemOwnerCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! ItemOwnerCollectionViewCell
            cell.populate(with: timeline.user)
            cell.showShadow = !self.contextRowAvailable
            cell.delegate = self
            return cell

        case .cover?:
            let mediaItem = timeline.mediaItems.first
            
            if let text = mediaItem?.text {
                let cell = context.dequeueReusableCell(of: TimelineTextCollectionViewCell.self,
                                                       for: self,
                                                       at: index) as! TimelineTextCollectionViewCell
                
                cell.label.text = text
                
                return cell
                
            } else {
                let cell = context.dequeueReusableCell(of: TimelineCoverCollectionViewCell.self,
                                                       for: self,
                                                       at: index) as! TimelineCoverCollectionViewCell
                
                if let imageUrl = mediaItem?.images?.largeUrl {
                    cell.setImage(withUrlString: imageUrl)
                }
                cell.videoUrlString = mediaItem?.videoUrl
            
                cell.videoPlayer.videoDelegate = self
            
                return cell
            }

        case .actions?:
            let cell = context.dequeueReusableCell(of: TimelineActionsCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! TimelineActionsCollectionViewCell
            cell.populate(withTimeline: self.timeline)
            cell.delegate = self
            
            let isLastCell = (self.timeline.comments.count == 0)
            cell.showShadow = isLastCell
            cell.separatorView.isHidden = !isLastCell
            
            return cell
            
        case .commentsCount?:
            if !showCommentCountRow {
                fallthrough
            } else {
                let cell = context.dequeueReusableCell(of: TimelineCommentCountCollectionViewCell.self,
                                                       for: self,
                                                       at: index) as! TimelineCommentCountCollectionViewCell
                cell.count = self.timeline.commentCount
                return cell
            }
            
        default:
            let cell = context.dequeueReusableCell(of: TimelineCommentCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! TimelineCommentCollectionViewCell

            let adjustedIndex = self.adjustedIndex(from: index)
            cell.populate(with: timeline.comments[adjustedIndex])
            
            let isLastComment = (adjustedIndex == timeline.comments.count - 1)
            cell.showShadow = isLastComment
            
            return cell
        }
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else {
            return .zero
        }
        
        switch TimelineSection.section(for: index, includingContext: self.contextRowAvailable) {
        case .context?, .actions?:
            return CGSize(width: context.containerSize.width, height: 34)

        case .owner?:
            return CGSize(width: context.containerSize.width, height: 44)

        case .cover?:
            return CGSize(width: context.containerSize.width, height: Constants.mediaHeight)
            
        case .commentsCount?:
            if !showCommentCountRow {
                fallthrough
            } else {
                return CGSize(width: context.containerSize.width, height: 30)
            }
            
        default:
            return CGSize(width: context.containerSize.width, height: 50)
        }
    }
    
    override func didSelectItem(at index: Int) {
        switch TimelineSection.section(for: index, includingContext: self.contextRowAvailable) {
        case .context?:
            if let user = self.timeline.feedContext?.actor {
                delegate?.showProfileForUser(user)
            }
            
        case .owner?:
            delegate?.showProfileForUser(self.timeline.user)
            
        case .cover?:
            if let imageUrl = self.timeline.mediaItems.first?.images?.largeUrl {
                delegate?.presentFullscreenImage(withUrl: imageUrl)
            } else {
                fallthrough
            }
             
        case .actions?:
            delegate?.showTimeline(self.timeline)

        default:
            delegate?.showCommentsForTimeline(self.timeline)
        }
    }

}

//MARK: - ItemOwnerCollectionViewCellDelegate

extension TimelineSectionController: ItemOwnerCollectionViewCellDelegate {
    
    func didSelectOptionsButton() {
        delegate?.showOptionsForTimeline(self.timeline)
    }
    
}

//MARK: - TimelineActionsCollectionViewCellDelegate

extension TimelineSectionController: TimelineActionsCollectionViewCellDelegate {
    
    func didTapCommentButton() {
        delegate?.showCommentsForTimeline(self.timeline)
    }
    
    func showError(withText text: String) {
        delegate?.showErrorAlertWith(message: text, completion: nil)
    }
    
}

// MARK: - ListScrollDelegate

extension TimelineSectionController: ListDisplayDelegate {
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
        if let detailsCell = cell as? TimelineCoverCollectionViewCell {
            detailsCell.stopVideo()
        }
    }
}

// MARK: - View Display Delegate

extension TimelineSectionController: VideoPlayerViewDelegate {
    func didTapFullScreenButton(_ videoView: VideoPlayerView, videoURL: URL?) {
        if let urlStr = videoURL?.absoluteString {
            delegate?.playVideo(withUrl: urlStr, view: videoView)
        }
    }
}

