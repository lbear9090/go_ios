//
//  SHOCellReuseProtocols.swift
//  Go
//
//  Created by Lee Whelan on 06/10/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import Foundation
import UIKit

public protocol SHOReusableIdentifier: class {
    static var reuseIdentifier: String { get }
}

public extension SHOReusableIdentifier {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

public protocol SHOReusableTableViewCell: SHOReusableIdentifier where Self:UITableViewCell {
    init(style: UITableViewCellStyle, reuseIdentifier: String?)
}

public extension SHOReusableTableViewCell {
    static func reusableCell<T: SHOReusableTableViewCell>(from tableView: UITableView,
                                                          withStyle style: UITableViewCellStyle = .default,
                                                          reuseId: String? = nil,
                                                          initialConfig: ((T) -> Void)? = nil) -> T {
        let reuseIdentifier = reuseId ?? T.reuseIdentifier
        
        guard let cell: T = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? T else {
            let cell = T(style: style, reuseIdentifier: reuseIdentifier)
            initialConfig?(cell)
            return cell
        }
        return cell
    }
}
