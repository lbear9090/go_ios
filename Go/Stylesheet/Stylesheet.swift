//
//  Stylesheet.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public func setupAppearance() {
    UINavigationBar.appearance().isTranslucent = false
}

struct Stylesheet {
    static let buttonHeight: CGFloat = 44.0
    static let authButtonHeight: CGFloat = 48.0
    static let safeLayoutAreaBottomScrollInset: CGFloat = 60.0
    static let tableViewCellSeparatorHeight: CGFloat = 0.5
    static let textSectionHeaderHeight: CGFloat = 35.0
}

// MARK: - Color

extension UIColor {
    static let green: UIColor = #colorLiteral(red: 0.1294117647, green: 0.8156862745, blue: 0.7490196078, alpha: 1)
    static let black: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let black10: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1035549497)
    static let red: UIColor = #colorLiteral(red: 0.9960784314, green: 0.2196078431, blue: 0.1411764706, alpha: 1)
    static let blue: UIColor = #colorLiteral(red: 0.2, green: 0.568627451, blue: 1, alpha: 1)
    static let fbBlue:  UIColor = #colorLiteral(red: 0.3058823529, green: 0.4156862745, blue: 0.6470588235, alpha: 1)
    static let white: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let white90: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
    static let orange: UIColor = #colorLiteral(red: 0.9960784314, green: 0.631372549, blue: 0.1490196078, alpha: 1)
    static let slateGrey: UIColor = #colorLiteral(red: 0.4274509804, green: 0.4274509804, blue: 0.4470588235, alpha: 1)
    static let saffron: UIColor = #colorLiteral(red: 1, green: 0.6901960784, blue: 0.02745098039, alpha: 1)
    static let pinkRed: UIColor = #colorLiteral(red: 1, green: 0.02745098039, blue: 0.3529411765, alpha: 1)
    
    static let text: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let lightText: UIColor = #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.5960784314, alpha: 1)
    static let authTextField: UIColor = .darkText
    
    static let unselectedTag: UIColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
    static let selectedTag: UIColor = .green

    static let tableViewBackground: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let tableViewCellBackground: UIColor = #colorLiteral(red: 0.9998916984, green: 1, blue: 0.9998809695, alpha: 1)
    static let tableViewCellSeparator: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    static let notificationUnreadBackground: UIColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    
    static let tabBarUnselectedTint: UIColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
    
    static let skeletonColor1: UIColor = #colorLiteral(red: 0.9357102089, green: 0.9357102089, blue: 0.9357102089, alpha: 1)
    static let skeletonColor2: UIColor = #colorLiteral(red: 0.9751891112, green: 0.9751891112, blue: 0.9751891112, alpha: 1)
    
    // Tab Bar Colors
    static let newsFeedSelected: UIColor = #colorLiteral(red: 0.2705882353, green: 0.2431372549, blue: 0.8431372549, alpha: 1)
    static let newsFeedUnselected: UIColor = tabBarUnselectedTint
    static let feedSelected: UIColor = pinkRed
    static let feedUnselected: UIColor = tabBarUnselectedTint
    static let createSelected: UIColor = tabBarUnselectedTint
    static let createUnselected: UIColor = tabBarUnselectedTint
    static let chatSelected: UIColor = #colorLiteral(red: 0.8980392157, green: 0.3176470588, blue: 0.7215686275, alpha: 1)
    static let chatUnselected: UIColor = tabBarUnselectedTint
    static let profileSelected: UIColor = saffron
    static let profileUnselected: UIColor = tabBarUnselectedTint
    
    // Auth
    static let logingButton: UIColor = saffron
    static let signupButton: UIColor = pinkRed
}

// MARK: - Images

extension UIImage {
    // MARK: General
    static let webNavBack: UIImage = #imageLiteral(resourceName: "iconWebBackNav")
    static let webNavForward: UIImage = #imageLiteral(resourceName: "iconWebForwardNav")
    static let actionButton: UIImage = #imageLiteral(resourceName: "more")
    static let backButton: UIImage = #imageLiteral(resourceName: "back")
    static let saveIcon: UIImage = #imageLiteral(resourceName: "save")
    static let emptyState: UIImage = #imageLiteral(resourceName: "goEmptyState")
    static let searchIcon: UIImage = #imageLiteral(resourceName: "search")
    static let notificationIcon: UIImage = #imageLiteral(resourceName: "notificationUnselected")
    static let notificationUnreadIcon: UIImage = #imageLiteral(resourceName: "notificationUnselectedPending").withRenderingMode(.alwaysOriginal)
    static let addFriendButton: UIImage = #imageLiteral(resourceName: "addFriendList")
    static let pendingFriendsIcon: UIImage = #imageLiteral(resourceName: "friendsPending36")
    static let friendsIcon: UIImage = #imageLiteral(resourceName: "friends36")
    static let findFriends: UIImage = #imageLiteral(resourceName: "addFriend")
    static let findFriendsNavBar: UIImage = eventFriends
    static let invitedIcon: UIImage = #imageLiteral(resourceName: "invited16")
    
    // MARK: Placeholders
    static let avatarPlaceholder: UIImage = #imageLiteral(resourceName: "profilePlaceholder114")
    static let roundAvatarPlaceholder: UIImage = #imageLiteral(resourceName: "profilePlaceholder36")
    static let largeRoundAvatarPlaceholder: UIImage = #imageLiteral(resourceName: "profilePlaceholder36")
    static let headerPlaceholder: UIImage = #imageLiteral(resourceName: "bannerPlaceholder")
    static let eventPlaceholder: UIImage = #imageLiteral(resourceName: "eventPlaceholder")
    static let squareEventPlaceholder: UIImage = #imageLiteral(resourceName: "eventCardPlaceholder")
    static let timelinePlaceholder: UIImage = #imageLiteral(resourceName: "timelinePlaceholder")
    static let notificationPlaceholder: UIImage = #imageLiteral(resourceName: "going")
    
    // MARK: Tab Bar
    static let newsFeedTab: UIImage = #imageLiteral(resourceName: "newsfeedUnselected")
    static let newsFeedTabSelected: UIImage = #imageLiteral(resourceName: "newsfeed")
    static let exploreTab: UIImage = #imageLiteral(resourceName: "feedUnselected")
    static let exploreTabSelected: UIImage = #imageLiteral(resourceName: "feed")
    static let addEventTab: UIImage = #imageLiteral(resourceName: "createUnselected")
    static let addEventTabSelected: UIImage = #imageLiteral(resourceName: "createUnselected")
    static let messagingTab: UIImage = #imageLiteral(resourceName: "currentConvUnselected")
    static let messagingTabSelected: UIImage = #imageLiteral(resourceName: "currentConv")
    static let profileTab: UIImage = #imageLiteral(resourceName: "profileUnselected")
    static let profileTabSelected: UIImage = #imageLiteral(resourceName: "profile")
    
    // MARK: Auth
    static var landingBackground: UIImage {
        if UIDevice.isIPhoneX {
            return #imageLiteral(resourceName: "splash_background_iphone_x")
        }
        
        return #imageLiteral(resourceName: "splash_background_iphone_8plus")
    }
    static let authLogo: UIImage = #imageLiteral(resourceName: "whiteLogo")
    static let navBarLogo: UIImage = #imageLiteral(resourceName: "navLogo")
    
    // MARK: Notifications
    static let notificationFriendRequest: UIImage = #imageLiteral(resourceName: "notificationFriendRequest")
    static let notificationContribution: UIImage = #imageLiteral(resourceName: "notificationContribution")
    static let notificationMessage: UIImage = #imageLiteral(resourceName: "notificationInvitationRequest")
    static let notificationInvitation: UIImage = #imageLiteral(resourceName: "notificationInvitation")
    static let notificationComment: UIImage = #imageLiteral(resourceName: "notificationComment")
    static let notificationTimeline: UIImage = #imageLiteral(resourceName: "notificationTimelineMedia")
    static let notificationGeneric: UIImage = #imageLiteral(resourceName: "notificationGeneric")
    
    // MARK: Newsfeed
    static let eventLocation: UIImage = #imageLiteral(resourceName: "event_location")
    static let eventTime: UIImage = #imageLiteral(resourceName: "date_tick")
    static let forwardButton: UIImage = #imageLiteral(resourceName: "forward")
    static let forwardButtonInactive: UIImage = #imageLiteral(resourceName: "forwardDeactivated")
    static let timlineButton: UIImage = #imageLiteral(resourceName: "timeline")
    static let timelineButtonInactive: UIImage = #imageLiteral(resourceName: "timelineDeactivated")
    static let messagesButton: UIImage = #imageLiteral(resourceName: "chat")
    static let messagesButtonInactive: UIImage = #imageLiteral(resourceName: "chatDeactivated")
    static let commentsButton: UIImage = #imageLiteral(resourceName: "comment")
    static let likeButton: UIImage = #imageLiteral(resourceName: "like")
    static let unlikeButton: UIImage = #imageLiteral(resourceName: "liked")
    static let eventHostIcon: UIImage = #imageLiteral(resourceName: "host")
    static let shareButton: UIImage = #imageLiteral(resourceName: "share")
    
    // MARK: Explore
    static let feedActiveButton: UIImage = #imageLiteral(resourceName: "list")
    static let mapActiveButton: UIImage = #imageLiteral(resourceName: "map")
    static let mapPinActive: UIImage = #imageLiteral(resourceName: "active")
    static let mapPinInactive: UIImage = #imageLiteral(resourceName: "inactive")
    
    // MARK: Event
    static let attendingIcon: UIImage = #imageLiteral(resourceName: "going")
    static let maybeAttendingIcon: UIImage = #imageLiteral(resourceName: "maybe")
    static let notAttendingIcon: UIImage = #imageLiteral(resourceName: "notGoing")
    static let noAttendanceStateIcon: UIImage = #imageLiteral(resourceName: "null")
    static let cancelButton: UIImage = #imageLiteral(resourceName: "cancel")
    static let acceptButton: UIImage = #imageLiteral(resourceName: "go")
    static let maybeButton: UIImage = #imageLiteral(resourceName: "notSureIcon")
    static let rejectButton: UIImage = #imageLiteral(resourceName: "rejectInvite")
    static let attending: UIImage = #imageLiteral(resourceName: "attending")
    static let hosting: UIImage = #imageLiteral(resourceName: "hosting")
    static let playIcon: UIImage = #imageLiteral(resourceName: "play_circle_filled")
    
    // MARK: Add Event
    static let addEvent: UIImage = #imageLiteral(resourceName: "addImage")
    static let title: UIImage = #imageLiteral(resourceName: "title")
    static let description: UIImage = #imageLiteral(resourceName: "description")
    static let time: UIImage = #imageLiteral(resourceName: "time")
    static let date: UIImage = #imageLiteral(resourceName: "date")
    static let adultOnly: UIImage = #imageLiteral(resourceName: "18")
    static let location: UIImage = #imageLiteral(resourceName: "location")
    static let hashTag: UIImage = #imageLiteral(resourceName: "hashtag")
    static let eventFriends: UIImage = #imageLiteral(resourceName: "friends")
    static let publicInvitation: UIImage = #imageLiteral(resourceName: "publicByInvitation")
    static let privateEvent: UIImage = #imageLiteral(resourceName: "privateEvent")
    static let limitedSpace: UIImage = #imageLiteral(resourceName: "limitedSpace")
    static let guestCap: UIImage = #imageLiteral(resourceName: "guestCap")
    static let eventForwarding: UIImage = #imageLiteral(resourceName: "eventForwarding")
    static let allowChat: UIImage = #imageLiteral(resourceName: "chat")
    static let allowTimeline: UIImage = #imageLiteral(resourceName: "timeline")
    static let contribution: UIImage = #imageLiteral(resourceName: "contribution")
    static let contributionAmount: UIImage = #imageLiteral(resourceName: "contributionAmount")
    static let contributionReason: UIImage = #imageLiteral(resourceName: "reason")
    static let contributionOptional: UIImage = #imageLiteral(resourceName: "contributionOptional")
    static let bring: UIImage = #imageLiteral(resourceName: "bring")
    static let selectLocation: UIImage = #imageLiteral(resourceName: "location_green")
    static let ticket: UIImage = #imageLiteral(resourceName: "ticket")
    static let link: UIImage = #imageLiteral(resourceName: "link")
    
    // MARK: Search
    static let searchHashTag: UIImage = #imageLiteral(resourceName: "hashtag")
    static let searchLocation: UIImage = #imageLiteral(resourceName: "location")
    
    // MARK: Settings
    static let settingsFBLogo: UIImage = #imageLiteral(resourceName: "facebook")
    static let stripeBadge: UIImage = #imageLiteral(resourceName: "stripeBadge")
    static let acceptRequest: UIImage = #imageLiteral(resourceName: "thumbUp")
    static let rejectRequest: UIImage = #imageLiteral(resourceName: "thumbDown")
    static let accountIcon: UIImage = #imageLiteral(resourceName: "account")
    static let countryIcon: UIImage = #imageLiteral(resourceName: "country")
    static let accountActiveIcon: UIImage = #imageLiteral(resourceName: "account_active")
    static let countryActiveIcon: UIImage = #imageLiteral(resourceName: "country_active")
    static let verifyEmail: UIImage = #imageLiteral(resourceName: "verify_email")
    static let verifyIDFront: UIImage = #imageLiteral(resourceName: "verify_id")
    static let verifyIDBack: UIImage = #imageLiteral(resourceName: "verify_id_back")
    static let settingsIcon: UIImage = #imageLiteral(resourceName: "settings")
    static let deleteTagIcon: UIImage = #imageLiteral(resourceName: "deleteTag16")
    
    // MARK: Chat
    static let chatInputBarAddMedia: UIImage = #imageLiteral(resourceName: "chatAddMedia")
    static let chatInputBarSend: UIImage = #imageLiteral(resourceName: "chatSend")
    static let chatLocationPin: UIImage = .mapPinActive
    static let chatDeliveredStatus: UIImage = #imageLiteral(resourceName: "chatDeliveredStatus")
    static let chatSeenStatus: UIImage = #imageLiteral(resourceName: "chatSeenStatus")
    static let chatBackground: UIImage = #imageLiteral(resourceName: "chatBackground")
    static let chatFailedStatus: UIImage = #imageLiteral(resourceName: "failed")
    static let conversationPlaceholder: UIImage = #imageLiteral(resourceName: "groupChatPlaceholder")
    static let mediaPlaceholder: UIImage = #imageLiteral(resourceName: "bannerPlaceholder")
    
    // MARK: Profile
    static let friendCountIcon: UIImage = #imageLiteral(resourceName: "friend_count_icon")
    static let companyNameIcon: UIImage = #imageLiteral(resourceName: "business")
    static let profileNameIcon: UIImage = #imageLiteral(resourceName: "names")
    static let profileDescriptionIcon: UIImage = #imageLiteral(resourceName: "description")
    static let profileDOBIcon: UIImage = #imageLiteral(resourceName: "dateOfBirth")
    static let profileGenderIcon: UIImage = #imageLiteral(resourceName: "gender")
    static let profilePhoneIcon: UIImage = #imageLiteral(resourceName: "phone")
    static let profileEmailIcon: UIImage = #imageLiteral(resourceName: "email")
    static let profileSyncIcon: UIImage = #imageLiteral(resourceName: "syncCalendar")
    static let editIcon: UIImage = #imageLiteral(resourceName: "edit")
    static let privateEventIcon: UIImage = #imageLiteral(resourceName: "privateEventIndicator")
    static let myFriendsIcon: UIImage = #imageLiteral(resourceName: "myFriends36")
    static let attendingEvent: UIImage = #imageLiteral(resourceName: "goButtonGreen")
    static let maybeAttendingEvent: UIImage = #imageLiteral(resourceName: "goButtonOrange")
    
    // MARK: Video Player
    static let fullScreenIcon: UIImage = #imageLiteral(resourceName: "icFullscreen")
    static let selectMediaIcon: UIImage = #imageLiteral(resourceName: "editCopy")
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//MARK: - Fonts

enum Font {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    func withSize(_ size: FontSize) -> UIFont {
        switch self {
            
        case .light:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .light)
            
        case .regular:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .regular)
            
        case .medium:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .medium)
            
        case .semibold:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .semibold)
            
        case .bold:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .bold)
        }
    }
}

enum FontSize: CGFloat {
    case extraSmall = 10.0
    case small = 12.0
    case medium = 15.0
    case large = 17.0
    case extraLarge = 20.0
    case massive = 28.0
}

enum CornerRadius: CGFloat {
    case small = 2.0
    case medium = 4.0
    case large = 8.0
}

extension UIViewController {
    
    public func configureAuthenticationNavBar() {
        self.navigationController?.navigationBar.setBackgroundTransparent()
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                        NSAttributedStringKey.font: Font.semibold.withSize(.medium)]
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barStyle = .default
        
        self.navigationController?.navigationBar.backIndicatorImage = .backButton
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = .backButton
    }
    
    public func configureNavigationBarForUseInTabBar() {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
                                                                        NSAttributedStringKey.font: Font.semibold.withSize(.medium)]
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
        
        self.navigationController?.navigationBar.backIndicatorImage = .backButton
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = .backButton
    }
    
}

extension UIDevice {
    public static var isIPhoneX: Bool {
        let bounds = UIScreen.main.bounds
        return bounds.size.width == 375.0 && bounds.size.height == 812.0
    }
}
