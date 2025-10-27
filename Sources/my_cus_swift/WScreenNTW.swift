import SwiftUI
import WebKit

struct WScreenNTW: View {
    let url: URL

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            WebView(url: url)
                .ignoresSafeArea(.container, edges: [])
        }.ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct WebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}

class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = WKWebView()
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .onDrag
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableKeyboardResizing()

        let request = URLRequest(url: url)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
    }

    private func disableKeyboardResizing() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let window = view.window else { return }
        window.frame.origin.y = 0
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let window = view.window else { return }
        window.frame.origin.y = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
