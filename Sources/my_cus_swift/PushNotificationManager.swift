import Foundation
import UserNotifications
import UIKit

public final class PushNotificationManager: NSObject, ObservableObject, @unchecked Sendable {
    public static let shared = PushNotificationManager()
    @Published var deviceToken: String?
    @Published var errorMessage: String?
    
    public func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    public func updateDeviceToken(_ token: Data) {
        let tokenParts = token.map { String(format: "%02.2hhx", $0) }
        self.deviceToken = tokenParts.joined()
        print("Device token: \(self.deviceToken ?? "None")")
    }

    public func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        print("Error: \(error.localizedDescription)")
    }
}
extension PushNotificationManager: UNUserNotificationCenterDelegate {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        updateDeviceToken(deviceToken)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handleError(error)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Получаем notification_id из userInfo или создаем временный
        let notificationId: String
        if let id = userInfo["notification_id"] as? String {
            notificationId = id
        } else {
            // Если нет notification_id, создаем временный
            notificationId = "manual_tap_\(Int(Date().timeIntervalSince1970))"
        }
        
        // Отправляем GET-запрос с параметрами push_opened
        Task {
            await MainActor.run {
                GPageNTW.handlePushNotification(notificationId: notificationId, cdUrl1NTW: "Z29tZXRlcnByby5zcGFjZQ==")
            }
        }
        
        completionHandler()
    }
}
