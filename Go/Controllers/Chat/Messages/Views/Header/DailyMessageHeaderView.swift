//
//  DailyMessageHeaderView.swift
//  Go
//
//  Created by Lucky on 13/03/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import MessageKit

class DailyMessageHeaderView: MessageHeaderView {
    
    var shouldInstallConstraints: Bool = true
    
    let dateLabel: PaddedLabel = {
        let config = LabelConfig(textFont: Font.medium.withSize(.small),
                                 textAlignment: .center,
                                 textColor: .white,
                                 backgroundColor: .lightGray,
                                 numberOfLines: 1)
        let label = PaddedLabel(with: config)
        label.layer.cornerRadius = CornerRadius.large.rawValue
        label.clipsToBounds = true
        return label
    }()
    
    open override class func reuseIdentifier() -> String { return "messagekit.header.date" }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.dateLabel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if self.shouldInstallConstraints {
            self.dateLabel.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
            
            self.dateLabel.setContentHuggingPriority(.required, for: .horizontal)
            self.dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        super.updateConstraints()
    }
    
}
