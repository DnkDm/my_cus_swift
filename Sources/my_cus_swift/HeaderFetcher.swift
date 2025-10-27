import Foundation
class HeaderFetcher {

    static func fetchHeader(urlString: String, keyKey: String, completion: @escaping (String?) -> Void) {
        let startTime = Date()
        //print("📡 [HEADER] fetchHeader начало: \(Date())")
        //print("🔗 [HEADER] URL: \(urlString)")
        //print("🔑 [HEADER] Ищем ключ: \(keyKey)")
        
        guard let url = URL(string: urlString) else {
            //print("❌ [HEADER] Неверный URL за: \(Date().timeIntervalSince(startTime))s")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30 // Добавляем таймаут

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let requestTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                //print("❌ [HEADER] Ошибка запроса за: \(requestTime)s - \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ [HEADER] Не HTTP ответ за: \(requestTime)s")
                completion(nil)
                return
            }
            
            //print("✅ [HEADER] HTTP ответ получен за: \(requestTime)s, статус: \(httpResponse.statusCode)")
            //print("📋 [HEADER] Всего заголовков: \(httpResponse.allHeaderFields.count)")

            let headers = httpResponse.allHeaderFields
            for (key, value) in headers {
                if let keyString = key as? String,
                   keyString.lowercased().contains(keyKey.lowercased()),
                   let valueString = value as? String {
                    //print("✅ [HEADER] Найден заголовок '\(keyString)': '\(valueString)' за: \(requestTime)s")
                    completion(valueString)
                    return
                }
            }
            //print("❌ [HEADER] Заголовок с ключом '\(keyKey)' не найден за: \(requestTime)s")
            completion(nil)
        }
        task.resume()
    }

    static func decodeBase64(_ input: String) -> String {
        guard let data = Data(base64Encoded: input) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
