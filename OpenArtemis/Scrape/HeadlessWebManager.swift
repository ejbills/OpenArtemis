//
//  HeadlessWebManager.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 4/10/24.
//

import Foundation
import WebKit
import Defaults

class HeadlessWebManager: NSObject, WKNavigationDelegate {
    private var webView: WKWebView!
    private var completion: ((Result<String, Error>) -> Void)?
    private var shouldAutoClickExpando: Bool = false
    
    @Default(.over18) var over18
    
    override init() {
        super.init()
        self.webView = WKWebView(frame: .zero)
        self.webView.navigationDelegate = self
    }
    
    // Adjusted to store the value of autoClickExpando
    func loadURLAndGetHTML(url: URL, autoClickExpando: Bool = false, preventCacheClear: Bool = false, completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        self.shouldAutoClickExpando = autoClickExpando  // Store the flag value
        
        let request = URLRequest(url: url)
        if !preventCacheClear {
            clearWebCache { [weak self] in
                guard let self = self else { return }
                self.webView.load(request)
            }
        } else {
            self.webView.load(request)
        }
    }
    
    // New function to clear the cache
    private func clearWebCache(completion: @escaping () -> Void) {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date, completionHandler: completion)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // If we're trying to access a page that has a known redirection pattern for age verification.
        if let currentURL = webView.url, currentURL.absoluteString.contains("over18?dest="), over18{
            self.allowMatureContent()
        } else {
            self.handleExpandoClicksIfNeeded(in: webView)
        }
    }

    private func allowMatureContent() {
        print("clicking that shit")
        let jsToClickOver18Confirmation = """
        document.querySelector('button.c-btn.c-btn-primary[type="submit"][name="over18"][value="yes"]').click();
        """
        
        webView.evaluateJavaScript(jsToClickOver18Confirmation) { result, error in
            if let error = error {
                print("Error clicking over18 confirmation: \(error)")
            }
        }
    }

    private func handleExpandoClicksIfNeeded(in webView: WKWebView) {
        // If auto-click is enabled, click expandos; otherwise, fetch outerHTML directly
        if shouldAutoClickExpando {
            let jsClickExpandos = """
            Array.from(document.querySelectorAll('div[class^="expando-button"]')).forEach(button => button.click());
            """
            webView.evaluateJavaScript(jsClickExpandos) { [weak self] _, _ in
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
