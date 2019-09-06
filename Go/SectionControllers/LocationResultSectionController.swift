//
//  LocationResultSectionController.swift
//  Go
//
//  Created by Lucky on 28/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import IGListKit

enum LocationResultRow: Int {
    case map
    case filterBar
}

protocol LocationResultSectionControllerDelegate {
    func didTapFilterButton()
}

class LocationResultSectionController: ListSectionController, FilterBarCellDelegate {
    
    var delegate: LocationResultSectionControllerDelegate?
    private var locationResult: LocationResultModel!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    override func didUpdate(to object: Any) {
        self.locationResult = object as? LocationResultModel
    }
    
    override func numberOfItems() -> Int {
        return 2
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard
            let context = collectionContext,
            let rowType = LocationResultRow(rawValue: index) else {
            return UICollectionViewCell()
        }
        
        switch rowType {
        case .map:
            let cell = context.dequeueReusableCell(of: MapCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! MapCollectionViewCell
            cell.showLocation(self.locationResult)
            return cell
            
        case .filterBar:
            let cell = context.dequeueReusableCell(of: FilterBarCollectionViewCell.self,
                                                   for: self,
                                                   at: index) as! FilterBarCollectionViewCell
            cell.delegate = self
            return cell
        }
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard
            let context = collectionContext,
            let rowType = LocationResultRow(rawValue: index) else {
            return .zero
        }
        
        switch rowType {
        case .map:
            return CGSize(width: context.containerSize.width, height: 220)
        case .filterBar:
            return CGSize(width: context.containerSize.width, height: 44)
        }
    }
    
    //MARK: - FilterBarCellDelegate
    
    func didTapFilterButton(_ button: UIButton) {
        self.delegate?.didTapFilterButton()
    }
    
}
