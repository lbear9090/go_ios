//
//  FilterableFeedViewController.swift
//  Go
//
//  Created by Lucky on 21/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import IGListKit

class FilterableFeedViewController: FeedViewController, Filterable {
    
    var filters: [String] = [] {
        didSet {
            self.request.tags = filters
        }
    }
    
}
