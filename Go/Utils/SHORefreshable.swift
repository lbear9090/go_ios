//
//  Refreshable.swift
//  SwiftTesting
//
//  Created by Lee Whelan on 26/09/2017.
//
//

import Foundation

public protocol SHORefreshable: class {
    func loadData()
    
    var paginatable: SHOPaginatable? { get }
}

public protocol SHOPaginatable: class { }

public extension SHORefreshable {
    public var paginatable: SHOPaginatable? { return nil }
}

public extension SHORefreshable where Self: SHOPaginatable {
    public var paginatable: SHOPaginatable? { return self }
}
