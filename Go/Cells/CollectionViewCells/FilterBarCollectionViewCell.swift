//
//  FilterBarCollectionViewCell.swift
//  Go
//
//  Created by Lucky on 28/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol FilterBarCellDelegate: class {
    func didTapFilterButton(_ button: UIButton)
}

class FilterBarCollectionViewCell: BaseCollectionViewCell {
    
    var delegate: FilterBarCellDelegate?
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("FILTER".localized, for: .normal)
        button.setTitleColor(.darkText, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkText.cgColor
        
        return button
    }()
    
    override func setup() {
        super.setup()
        
        self.separatorView.isHidden = false
        self.addBottomShadow()
        
        self.contentView.addSubview(self.filterButton)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.filterButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview().inset(8)
            make.width.equalTo(50)
        }
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapFilterButton(sender)
    }
}
