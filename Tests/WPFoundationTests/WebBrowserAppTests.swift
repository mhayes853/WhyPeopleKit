import Testing
import WPFoundation

@Suite("WebBrowserApp tests")
struct WebBrowserAppTests {
  @Test(
    "Deep Link URL",
    arguments: [
      (WebBrowserApp.inAppSafari, nil),
      (WebBrowserApp.systemDefault, URL(string: "https://www.google.com")!),
      (WebBrowserApp.firefox, URL(string: "firefox://open-url?url=https://www.google.com")!),
      (
        WebBrowserApp.firefoxFocus,
        URL(string: "firefox-focus://open-url?url=https://www.google.com")!
      ),
      (WebBrowserApp.opera, URL(string: "touch-https://www.google.com")!),
      (WebBrowserApp.operaGX, URL(string: "opera-gx://open-url?url=https://www.google.com")!),
      (WebBrowserApp.brave, URL(string: "brave://open-url?url=https://www.google.com")!),
      (WebBrowserApp.chrome, URL(string: "googlechrome://www.google.com")!),
      (WebBrowserApp.duckDuckGo, URL(string: "ddgQuickLink://www.google.com")!),
      (WebBrowserApp.edge, URL(string: "microsoft-edge-https://www.google.com")!),
      (WebBrowserApp.arcSearch, URL(string: "arcmobile2://goto?url=https://www.google.com")!)
    ]
  )
  func deepLinkURL(app: WebBrowserApp, googleURL: URL?) async throws {
    let url = URL(string: "https://www.google.com")!
    #expect(app.deepLinkURL(for: url) == googleURL)
  }
}
