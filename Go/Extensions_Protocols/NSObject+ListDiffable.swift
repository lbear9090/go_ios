//
//  NSObject+ListDiffable.swift
//  Go
//
//  Created by Killian Kenny on 09/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation
import IGListKit

extension NSObject: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
    
}
