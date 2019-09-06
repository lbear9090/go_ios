//
//  NameGroupDetailView.swift
//  Go
//
//  Created by Lee Whelan on 24/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

private let GroupImageDiameter: CGFloat = 45.0

protocol NameGroupDetailViewDelegate: class {
    func nameGroupDetailView(_ view: NameGroupDetailView, didSelectImageView imageView: UIImageView)
    func nameGroupDetailView(_ view: NameGroupDetailView, textDidChange text: String?)
}

class NameGroupDetailView: SHOView {
    
    weak var delegate: NameGroupDetailViewDelegate?
    
    lazy var groupImageView: UIImageView = {
        var view = UIImageView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: GroupImageDiameter, height: GroupImageDiameter)))
        view.image = .conversationPlaceholder
        view.backgroundColor = .lightGray
        view.isUserInteractionEnabled = true
        view.makeCircular(.scaleAspectFill)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectImageView))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    lazy var nameTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "CHAT_NEW_GROUP_SUBJECT".localized
        textField.tintColor = .black
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    var detailLabel: UILabel = {
        var label: UILabel = UILabel.newAutoLayout()
        label.font = Font.regular.withSize(.small)
        label.text = "CHAT_NEW_GROUP_SUBJECT_DETAIL".localized
        return label
    }()

    // MARK: Stack Views
    
    var stackView: UIStackView = {
        var view: UIStackView = UIStackView.newAutoLayout()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()
    
    var textStackView: UIStackView = {
        var view: UIStackView = UIStackView.newAutoLayout()
        view.axis = .vertical
        view.spacing = 5
        return view
    }()
    
    override func setup() {
        super.setup()
        
        self.layoutMargins = UIEdgeInsetsMake(10, 20, 10, 20)
        
        self.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.groupImageView)
        self.stackView.addArrangedSubview(self.textStackView)
        
        self.textStackView.addArrangedSubview(self.nameTextField)
        self.textStackView.addArrangedSubview(self.detailLabel)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        self.stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.margins)
        }
        
        self.groupImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: GroupImageDiameter, height: GroupImageDiameter))
        }
        
    }
    
    //MARK: - Actions
    
    @objc func didSelectImageView() {
        self.delegate?.nameGroupDetailView(self, didSelectImageView: self.groupImageView)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.nameGroupDetailView(self, textDidChange: textField.text)
    }
}

extension NameGroupDetailView: UITextFieldDelegate {
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
