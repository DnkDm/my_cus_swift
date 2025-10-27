import Foundation
import UIKit

class DeviceInfoService {
    static func fetch() async -> [String: String] {
        // Получаем данные из главного потока
        let systemVersion = await MainActor.run {
            UIDevice.current.systemVersion
        }
        
        // Остальные операции в фоновом потоке
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                var deviceInfo: [String: String] = [:]

                let model = getDeviceModel()
                let locale = Locale.current
                let lang = locale.languageCode ?? "Unknown"
                let region = locale.regionCode ?? "Unknown"

                deviceInfo["model"] = model
                deviceInfo["os"] = "iOS \(systemVersion)"
                deviceInfo["lang"] = lang
                deviceInfo["region"] = region

                let prefs = UserDefaults.standard
                prefs.set(model, forKey: "model")
                prefs.set("iOS \(systemVersion)", forKey: "os")
                prefs.set(lang, forKey: "lang")
                prefs.set(region, forKey: "rg")

                // Сохраняем build version
                let bld = getBuildVersion()
                prefs.set(bld, forKey: "bld")
                deviceInfo["bld"] = bld

                continuation.resume(returning: deviceInfo)
            }
        }
    }

    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
        return machine
    }

    // Получение build version (bld)
    private static func getBuildVersion() -> String {
        var size = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var build = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &build, &size, nil, 0)
        return String(cString: build)
    }
}
