// WeatherService.swift

import Foundation

class WeatherService {
    
    private static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "PropertyList", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENWEATHERMAP_KEY"] as? String else {
            fatalError("OpenWeatherMap API 키를 불러올 수 없습니다.")
        }
        return key
    }

    static func fetchWeather(lat: Double, lon: Double, completion: @escaping (Double?, Double?) -> Void) {
        let apiKey = WeatherService.apiKey
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        print("API 호출 URL: URL 있음(보안 위해 숨김)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, nil); return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//                print("전체 JSON 응답: \(String(describing: json))")
                let main = json?["main"] as? [String: Any]
                let tempVal = main?["temp"]
                let humidVal = main?["humidity"]

                let temp = (tempVal as? NSNumber)?.doubleValue
                let humid = (humidVal as? NSNumber)?.doubleValue

//                print("디버깅 main[temp]=\(String(describing: tempVal)), main[humidity]=\(String(describing: humidVal))")
//                print("변환된 temp=\(String(describing: temp)), humid=\(String(describing: humid))")

                completion(temp, humid)
            } catch {
                print("JSON 파싱 에러: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
}
