//
//  MainViewController.swift
//

import UIKit

class MainViewController: UIViewController {
    let weatherManager = WeatherManager()
    var currentTemp: Double?
    var currentHumidity: Double?
    var context: RecordContext!
    
    @IBOutlet weak var introTextView: UITextView!
    
    @IBOutlet weak var mainView: UITextView!
    @IBOutlet weak var beforeView: UIView!
    @IBOutlet weak var afterView: UIView!
    @IBOutlet weak var recordCheckView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 12
        mainView.clipsToBounds = true
        
        beforeView.layer.cornerRadius = 12
        beforeView.clipsToBounds = true

        afterView.layer.cornerRadius = 12
        afterView.clipsToBounds = true

        recordCheckView.layer.cornerRadius = 12
        recordCheckView.clipsToBounds = true
        
        let checkVC = CheckViewController()
        checkVC.context = RecordContext(mode: .before, category: .skincare)
        
        introTextView.font = UIFont.systemFont(ofSize: 15)
        introTextView.isEditable = false
        introTextView.isSelectable = false
        
        weatherManager.requestLocation { lat, lon in
            WeatherService.fetchWeather(lat: lat, lon: lon) { temp, humidity in
                DispatchQueue.main.async {
                    self.currentTemp = temp
                    self.currentHumidity = humidity
                    if let temp = self.currentTemp, let humidity = self.currentHumidity {
                        self.introTextView.text = "\n현재 기온은 \(temp)도, 습도는 \(humidity)%입니다.\n비슷한 날씨에 사용했던 제품을 확인해보시는 건 어떨까요?"
                    } else {
                        self.introTextView.text = "날씨 정보를 불러오는 중입니다..."
                    }

//                    print("날씨 정보 불러옴: temp = \(String(describing: temp)), humidity = \(String(describing: humidity))")
                }
            }
        }
    }
    
    // MARK: - 외출 전 버튼 액션
    @IBAction func skincareBeforeTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .before, category: .skincare))
    }

    @IBAction func baseBeforeTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .before, category: .base))
    }

    @IBAction func eyeBeforeTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .before, category: .eye))
    }

    @IBAction func lipBeforeTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .before, category: .lip))
    }
    
    // MARK: - 귀가 후 버튼 액션
    @IBAction func baseAfterTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .after, category: .base))
    }

    @IBAction func eyeAfterTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .after, category: .eye))
    }

    @IBAction func lipAfterTapped(_ sender: UIButton) {
        navigateToRecord(context: RecordContext(mode: .after, category: .lip))
    }
    
    @IBAction func dateCheckTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCheck", sender: Mode.date)
    }

    @IBAction func weatherCheckTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCheck", sender: Mode.weather)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCheck",
           let dest = segue.destination as? CheckViewController,
           let mode = sender as? Mode {
            dest.mode = mode
            dest.context = self.context // ✅ 여기에서 context도 같이 넘김
        }
    }



    // MARK: - 화면 전환 함수
    private func navigateToRecord(context: RecordContext) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let recordVC = storyboard.instantiateViewController(withIdentifier: "RecordViewController") as? RecordViewController {
            recordVC.context = context
            self.navigationController?.pushViewController(recordVC, animated: true)
        }
    }
}
