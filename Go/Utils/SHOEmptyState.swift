//
//  NoResultsView.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 22/09/2017.
//
//

import Foundation
import UIKit

public protocol SHOEmptyState: class {
    var emptyStateView: UIView? { get }
    var isEmpty: Bool { get }
}

