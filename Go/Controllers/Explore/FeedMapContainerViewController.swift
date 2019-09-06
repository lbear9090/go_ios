//
//  FeedMapContainerViewController.swift
//  Go
//
//  Created by Lucky on 16/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit

protocol Filterable {
    var filters: [String] { get set }
    
    var request: FeedDataRequestModel { get set }
}

private enum ControllerType {
    case feed
    case map
    
    mutating func toggleType() {
        switch self {
        case .feed:
            self = .map
        case .map:
            self = .feed
        }
    }
    
    func buttonImage() -> UIImage {
        switch self {
        case .feed:
            return .feedActiveButton
        case .map:
            return .mapActiveButton
        }
    }
}

class FeedMapContainerViewController: SHOParentViewController {
    
    //MARK: - Properties

    fileprivate var activeControllerType: ControllerType = .feed

    private let toolbarView = UIView()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("FILTER".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tableViewCellSeparator
        return view
    }()
    
    private var feedController: UIViewController & Filterable
    private var mapController: UIViewController & Filterable
    private let segmentTitleString: String

    init(feedController: UIViewController & Filterable, mapController: UIViewController & Filterable, segmentTitle: String) {
        self.feedController = feedController
        self.mapController = mapController
        self.segmentTitleString = segmentTitle
        
        super.init(nibName: nil, bundle: nil)
        
        self.setButtonState()
        self.setChildController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View setup
    
    override func setup() {
        super.setup()
        self.view.addSubview(self.toolbarView)
        self.toolbarView.backgroundColor = .green
        
        self.toolbarView.addSubview(self.dividerView)
        self.toolbarView.addSubview(self.toggleButton)
        self.toolbarView.addSubview(self.filterButton)
    }
    
    override func applyConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(self.toolbarView.snp.bottom)
        }
        
        self.toolbarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.dividerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.toggleButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(8)
        }
        
        self.filterButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview().inset(8)
            make.width.equalTo(50)
        }
    }

    //MARK: - User interaction
    
    @objc private func toggleButtonTapped() {
        self.activeControllerType.toggleType()
        setChildController()
        setButtonState()
    }
    
    @objc private func filterButtonTapped() {
        var requestingController = self.activeController as? Filterable
        if let controller = requestingController {
            let filterController = FiltersViewController(with: controller.request)
            filterController.selectionHandler = { (selectedParams) in
                requestingController?.request = selectedParams
            }
            let navController = UINavigationController.init(rootViewController: filterController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    private func setButtonState() {
        self.toggleButton.setImage(self.activeControllerType.buttonImage(),
                                   for: .normal)
    }
    
    private func setChildController() {
        switch self.activeControllerType {
        case .feed:
            self.removeController(self.mapController)
            self.addController(self.feedController)
        case .map:
            self.removeController(self.feedController)
            self.addController(self.mapController)
        }
    }
    
}

//MARK: - SegmentController

extension FeedMapContainerViewController: SegmentController {
    var segmentTitle: String {
        return self.segmentTitleString
    }
}

//MARK: - FilterViewControllerDelegate

extension FeedMapContainerViewController: CategoriesSelectionControllerDelegate {
    
    func didUpdateFilters(to filters: [String]) {
        self.mapController.filters = filters
        self.feedController.filters = filters
    }
    
}
