//
// Project: AshteMobile
// Developer Telegram: https://t.me/ashtemobile
//

import UIKit
import WebKit

class ViewController: UIViewController {

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var errorView: UIView!
    private var errorLabel: UILabel!
    private var retryButton: UIButton!

    // بەستەری سەرەکی وێبسایتەکە
    private let targetURL = "https://signipa.vercel.app"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupWebView()
        setupProgressView()
        setupRefreshControl()
        setupErrorView()
        loadWebsite()
    }

    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    // MARK: - Setup

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        // Inline media & auto-play
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Persistent data store
        config.websiteDataStore = WKWebsiteDataStore.default()

        // ---------------------------------------------------------
        // کۆدی زیادکراو بۆ گۆڕینی ناو و دەقەکانی ناو وێبسایتەکە
        // ---------------------------------------------------------
        let jsString = """
        function replaceTextInDOM(node) {
            if (node.nodeType === 3) { // ئەگەر نۆدەکە دەق بێت
                var text = node.nodeValue;
                
                // گۆڕینی وشەکان لێرەدا دەکرێت
                text = text.replace(/iOS SignTool/gi, "AshteMobile");
                text = text.replace(/IOS DEVELOPER TOOLS/gi, "ASHTEMOBILE TOOLS");
                text = text.replace(/Sign IPAs, validate certificates, and rotate P12 passwords — a complete iOS certificate management workspace. No Mac needed./gi, "بەخێربێیت بۆ AshteMobile، لێرە دەتوانیت بەرنامەکان دابەزێنیت و واژۆیان بکەیت بەبێ پێویستی بە کۆمپیوتەر.");
                
                node.nodeValue = text;
            } else if (node.nodeType === 1 && node.nodeName !== "SCRIPT" && node.nodeName !== "STYLE") {
                for (let i = 0; i < node.childNodes.length; i++) {
                    replaceTextInDOM(node.childNodes[i]);
                }
            }
        }
        
        // کەمێک چاوەڕێ دەکات تا وێبسایتەکە لۆد دەبێت پاشان دەقەکان دەگۆڕێت
        setTimeout(function() {
            replaceTextInDOM(document.body);
        }, 500);
        setTimeout(function() {
            replaceTextInDOM(document.body);
        }, 1500);
        
        // چاودێری گۆڕانکارییەکان دەکات
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                mutation.addedNodes.forEach(function(node) {
                    if (node.nodeType === 1 || node.nodeType === 3) {
                        replaceTextInDOM(node);
                    }
                });
            });
        });
        observer.observe(document.body, { childList: true, subtree: true });
        """
        
        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        config.userContentController = userContentController
        // ---------------------------------------------------------

        // JavaScript enabled
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemBlue
        progressView.trackTintColor = .clear
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }

    private func setupErrorView() {
        errorView = UIView()
        errorView.backgroundColor = .systemBackground
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true

        errorLabel = UILabel()
        errorLabel.text = "Unable to connect.\nCheck your internet connection."
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .secondaryLabel
        errorLabel.font = .systemFont(ofSize: 16)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryLoad), for: .touchUpInside)

        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -32),

            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20)
        ])
    }

    private func loadWebsite() {
        guard let url = URL(string: targetURL) else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
        errorView.isHidden = true
    }

    // MARK: - Actions

    @objc private func refreshPage() {
        errorView.isHidden = true
        loadWebsite()
    }

    @objc private func retryLoad() {
        loadWebsite()
    }

    // MARK: - KVO

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == #keyPath(WKWebView.estimatedProgress) else { return }
        let progress = Float(webView.estimatedProgress)
        progressView.setProgress(progress, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.progressView.alpha = progress >= 1.0 ? 0 : 1
        }
    }
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1
        progressView.setProgress(0, animated: false)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        progressView.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.progressView.alpha = 0
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        progressView.alpha = 0
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            errorView.isHidden = false
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        progressView.alpha = 0
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            errorView.isHidden = false
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Pass through special schemes used by the web app
        if let scheme = url.scheme {
            let internalSchemes = ["https", "http", "about", "blob", "data"]
            if !internalSchemes.contains(scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
                return
            }
        }

        // Open new-tab links (target="_blank") in Safari
        if navigationAction.targetFrame == nil {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // Open external domains in Safari when user taps a link
        if let host = url.host,
           navigationAction.navigationType == .linkActivated,
           !host.contains("signipa.vercel.app"),
           !host.hasSuffix("vercel.app") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate

extension ViewController: WKUIDelegate {

    // Camera / microphone permission (iOS 15+)
    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.grant)
    }

    // Handle window.open() — open in Safari
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }

    // JavaScript alert
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }

    // JavaScript confirm
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        present(alert, animated: true)
    }

    // JavaScript prompt
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { tf in tf.text = defaultText }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        present(alert, animated: true)
    }
}
