import Foundation
import UIKit
import Network

class ConnectivityService {

    static func ensureInternetConnection(viewController: UIViewController) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var connected = false

            _Concurrency.Task {
                repeat {
                    connected = await isConnected()

                    if connected {
                        continuation.resume()
                        return
                    }

                    await showNoInternetDialog(viewController: viewController)

                    try? await _Concurrency.Task.sleep(for: .seconds(2))

                } while !connected

                continuation.resume()
            }
        }
    }



    

    static func isConnected() async -> Bool {
        return await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue.global(qos: .background)

            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
                monitor.cancel()
            }

            monitor.start(queue: queue)
        }
    }


    static func showNoInternetDialog(viewController: UIViewController) async {
        await MainActor.run {
            let alert = UIAlertController(
                title: "No Internet Connection",
                message: "Please check your internet connection.",
                preferredStyle: .alert
            )
            viewController.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true)
            }
        }
        
        try? await _Concurrency.Task.sleep(for: .seconds(2))
    }

    static func checkConnectionAndInitialize(uid: String) async -> String? {
        let startTime = Date()
        //print("🌐 [CONNECTIVITY] checkConnectionAndInitialize начало: \(Date())")
        
        let connectionCheckTime = Date()
        let connected = await isConnected()
        //print("✅ [CONNECTIVITY] isConnected(\(connected)) за: \(Date().timeIntervalSince(connectionCheckTime))s")
        
        if connected {
            let authTime = Date()
            //print("🔒 [CONNECTIVITY] Запрашиваем авторизацию push notifications: \(Date())")
            let granted = await PushNotificationManager.shared.requestAuthorization()
            //print("✅ [CONNECTIVITY] requestAuthorization(\(granted)) за: \(Date().timeIntervalSince(authTime))s")
            
            if granted {
                let tokenTime = Date()
                //print("🎫 [CONNECTIVITY] Ждем device token: \(Date())")
                if let token = await waitForDeviceToken() {
                   //print("✅ [CONNECTIVITY] Device token получен за: \(Date().timeIntervalSince(tokenTime))s")
                    //print("🏁 [CONNECTIVITY] checkConnectionAndInitialize завершен за: \(Date().timeIntervalSince(startTime))s")
                    return token
                } else {
                    //print("❌ [CONNECTIVITY] Device token не получен за: \(Date().timeIntervalSince(tokenTime))s")
                    return nil
                }
            } else {
               // print("❌ [CONNECTIVITY] Push notifications не разрешены")
                return nil
            }
        } else {
            //print("❌ [CONNECTIVITY] Нет интернет соединения")
            return nil
        }
    }

    private static func waitForDeviceToken() async -> String? {
        await withCheckedContinuation { continuation in
            _Concurrency.Task {
                //print("🎫 [TOKEN] Начинаем ожидание device token (макс 10 попыток по 500мс)")
                var attempts = 0
                let startTime = Date()
                while attempts < 10 {
                    //print("🔄 [TOKEN] Попытка \(attempts + 1)/10: \(Date())")
                    if let token = PushNotificationManager.shared.deviceToken {
                        //print("✅ [TOKEN] Device token найден на попытке \(attempts + 1) за: \(Date().timeIntervalSince(startTime))s")
                        continuation.resume(returning: token)
                        return
                    }
                    attempts += 1
                    try? await _Concurrency.Task.sleep(for: .milliseconds(500))
                }
                //print("❌ [TOKEN] Device token не получен после 10 попыток за: \(Date().timeIntervalSince(startTime))s")
                continuation.resume(returning: nil)
            }
        }
    }

}
