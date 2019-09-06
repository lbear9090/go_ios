//
//  SHOWebViewController.swift
//  Go
//
//  Created by Lee Whelan on 19/12/2017.
//  Copyright © 2017 Go. All rights reserved.
//

import UIKit
import DeviceKit

private let ToolbarHeight: CGFloat = Device().footerHeight()

class SHOWebViewController: SHOViewController {
    
    var webView: UIWebView!
    var urlString: String!
    var addAccessToken: Bool = false
    
    fileprivate var toolbar: UIToolbar!
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var forwardButton: UIBarButtonItem!
    
    convenience init(url: String) {
        self.init()
        
        self.urlString = url;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isModal() {
            let cancel = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissModal))
            self.navigationItem.leftBarButtonItem = cancel
        }
        
        guard let url = URL(string: self.urlString) else {
            return
        }
        
        let mutableRequest = NSMutableURLRequest(url: url)
        
        if let accessToken = SHOSessionManager.shared.bearerToken, self.addAccessToken {
            mutableRequest.setValue(accessToken, forHTTPHeaderField: APIConstants.authorization)
        }
        
        let urlRequest = mutableRequest as URLRequest
        self.webView.loadRequest(urlRequest)
    }
    
    override func setup() {
        self.webView = UIWebView()
        self.webView.backgroundColor = .white
        self.webView.scalesPageToFit = true;
        self.webView.delegate = self;
        
        self.backButton = UIBarButtonItem(image: .webNavBack,
                                          style: .plain,
                                          target: self,
                                          action: #selector(backButtonPressed))
        self.backButton.isEnabled = self.webView.canGoBack
        
        self.forwardButton = UIBarButtonItem(image: .webNavForward,
                                             style: .plain,
                                             target: self,
                                             action: #selector(forwardButtonPressed))
        self.forwardButton.isEnabled = self.webView.canGoForward
        
        self.toolbar = UIToolbar()
        self.toolbar.barTintColor = .white
        self.toolbar.tintColor = .black
        self.toolbar.setItems([self.backButton, self.forwardButton], animated: true)
        
        self.view.addSubview(self.webView)
        self.view.addSubview(self.toolbar)
    }
    
    override func loadView() {
        super.loadView()
        
        self.webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        self.toolbar.snp.makeConstraints { make in
            make.top.equalTo(self.webView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(ToolbarHeight)
        }
    }
    
    static func presentModally(withUrlString urlString: String,
                               fromController presentingController: UIViewController,
                               withTitle title: String? = nil,
                               withAccessToken: Bool = false) {
        
        let controller = SHOWebViewController(url: urlString)
        controller.title = title
        controller.addAccessToken = withAccessToken
        
        let navController = UINavigationController(rootViewController: controller)
        presentingController.present(navController, animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension SHOWebViewController {
    
    @objc func backButtonPressed() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @objc func forwardButtonPressed() {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
}

// MARK: - UIWebViewDelegate

extension SHOWebViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
}
