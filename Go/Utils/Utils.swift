//
//  Utils.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension SHOUtils {
    
    static func logoutUser() {
        SHOSessionManager.shared.clearSession()
        FBSDKLoginManager().logOut()
        CacheManager.clearCache()
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.pushNotificationToken)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.currentUserId)
    }
    
}

extension Date {
    private static let relativeDateFormater: DateFormatter = DateFormatter()
    
    func relativeDaily() -> String {
        var dateFormat: DateFormat
        
        switch true {
        case Calendar.current.isDateInToday(self):
            return "Today".localized
        case Calendar.current.isDateInYesterday(self):
            return "Yesterday".localized
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear):
            dateFormat = DateFormat(value: "EEEE")
        case Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year):
            dateFormat = DateFormat(value: "MMMM d")
        default:
            dateFormat = DateFormat(value: "MMM d yyyy")
        }
        
        return self.string(withFormat: dateFormat) ?? ""
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
