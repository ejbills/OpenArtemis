//
//  HeadlessWebManager.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 4/10/24.
//

import Foundation
import WebKit

class HeadlessWebManager: NSObject, WKNavigationDelegate {
    private var webView: WKWebView!
    private var completion: ((Result<String, Error>) -> Void)?
    private var shouldAutoClickExpando: Bool = false
    
    override init() {
        super.init()
        self.webView = WKWebView(frame: .zero)
        self.webView.navigationDelegate = self
    }
    
    // Adjusted to store the value of autoClickExpando
    func loadURLAndGetHTML(url: URL, autoClickExpando: Bool = false, completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        self.shouldAutoClickExpando = autoClickExpando  // Store the flag value
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if shouldAutoClickExpando {
            let clickExpandosJS = """
            Array.from(document.querySelectorAll('div[class^="expando-button"]')).forEach(button => button.click());
            """
            
            webView.evaluateJavaScript(clickExpandosJS) { [weak self] _, clickError in
                // Proceed to get the outerHTML after attempting to click expando-buttons, regardless of clickError.
                self?.fetchOuterHTML()
            }
        } else {
            // Directly fetch the HTML if no auto-click is needed
            fetchOuterHTML()
        }
    }
    
    private func fetchOuterHTML() {
        webView.evaluateJavaScript("document.documentElement.outerHTML") { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.completion?(.failure(error))
            } else if let htmlContent = result as? String {
                strongSelf.completion?(.success(htmlContent))
            } else {
                strongSelf.completion?(.failure(NSError(domain: "Invalid HTML content", code: 0, userInfo: nil)))
            }
        }
    }
}
