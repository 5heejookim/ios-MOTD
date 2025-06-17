//  CheckViewController.swift

import UIKit
import FSCalendar
import FirebaseFirestore

enum Mode { case date, weather }

class CheckViewController: UIViewController {
    private let recordDetailView = RecordDetailView()
    
    let weatherManager = WeatherManager()
    
    var context: RecordContext!
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var mode: Mode = .date  // 전달받아서 설정
    private let db = Firestore.firestore()
    
    // UI
    private var calendar: FSCalendar!
    private var tempPicker = UIPickerView()
    private var humidPicker = UIPickerView()
    
    private let tempValues = Array(-20...40)
    private let humidValues = Array(0...100)
    private var selectedDate = Date()
    private var selectedTemp: Int?
    private var selectedHumid: Int?
    
    private let beforeTitles = ["기초", "베이스", "아이", "립"]
    private let afterTitles = ["베이스", "아이", "립"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .weather {
            selectedDate = Date()
            requestWeather()
        }
        
        title = "기록 조회"
        view.backgroundColor = UIColor(red: 1.0, green: 0.949, blue: 0.922, alpha: 1.0)
        setupModeUI()
        setupCategoryButtons()
        
        view.addSubview(recordDetailView)
        recordDetailView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recordDetailView.heightAnchor.constraint(equalToConstant: 650),
            recordDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // 필요에 따라 조정
        ])

        recordDetailView.isHidden = true  // 초기에는 숨김
    }
    
    private func requestWeather() {
        weatherManager.requestLocation { lat, lon in
            WeatherService.fetchWeather(lat: lat, lon: lon) { temp, humid in
                guard let temp = temp, let humid = humid else {
                    print("날씨 정보 없음")
                    return
                }

                DispatchQueue.main.async {
                    self.selectedTemp = Int(temp)
                    self.selectedHumid = Int(humid)

                    // 피커뷰에서 가장 가까운 값의 row 선택
                    if let tempIndex = self.tempValues.firstIndex(of: Int(temp)) {
                        self.tempPicker.selectRow(tempIndex, inComponent: 0, animated: true)
                    }

                    if let humidIndex = self.humidValues.firstIndex(of: Int(humid)) {
                        self.humidPicker.selectRow(humidIndex, inComponent: 0, animated: true)
                    }
                }
            }
        }
    }
    
    private func setupModeUI() {
        switch mode {
        case .date:
            calendar = FSCalendar()
            calendar.delegate = self
            calendar.appearance.weekdayTextColor = UIColor.black
            calendar.appearance.headerTitleColor = .black
            calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16)

            view.addSubview(calendar)
            calendar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                calendar.heightAnchor.constraint(equalToConstant: 300),

            ])
        case .weather:
            // 기온 뷰 구성
            let tempLabel = UILabel()
            tempLabel.text = "기온"
            tempLabel.textAlignment = .center
            tempLabel.font = UIFont.boldSystemFont(ofSize: 19)

            let tempStack = UIStackView(arrangedSubviews: [tempLabel, tempPicker])
            tempStack.axis = .horizontal
            tempStack.alignment = .center
            tempStack.spacing = 4

            // 습도 뷰 구성
            let humidLabel = UILabel()
            humidLabel.text = "습도"
            humidLabel.textAlignment = .center
            humidLabel.font = UIFont.boldSystemFont(ofSize: 19)

            let humidStack = UIStackView(arrangedSubviews: [humidLabel, humidPicker])
            humidStack.axis = .horizontal
            humidStack.alignment = .center
            humidStack.spacing = 4

            // 가로 스택 구성
            let horizontalStack = UIStackView(arrangedSubviews: [tempStack, humidStack])
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .center
            horizontalStack.spacing = 35
            horizontalStack.distribution = .equalSpacing

            view.addSubview(horizontalStack)
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                horizontalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                horizontalStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                // tempPicker 너비/높이 설정
                tempPicker.widthAnchor.constraint(equalToConstant: 100),
                tempPicker.heightAnchor.constraint(equalToConstant: 130),

                // humidPicker 너비/높이 설정
                humidPicker.widthAnchor.constraint(equalToConstant: 100),
                humidPicker.heightAnchor.constraint(equalToConstant: 130)
            ])


            // 피커 delegate/dataSource 설정
            tempPicker.dataSource = self
            tempPicker.delegate = self
            humidPicker.dataSource = self
            humidPicker.delegate = self

        }
    }
    
    private func makeCategoryButton(title: String, imageName: String, tag: Int, mode: RecordContext.Mode) -> UIButton {
        let button = UIButton(type: .custom)
        
        // 이미지 및 타이틀 설정
        button.setImage(UIImage(named: imageName) ?? UIImage(systemName: "questionmark.circle"), for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        
        button.tag = tag
        button.accessibilityHint = (mode == .before) ? "before" : "after"

        // 이미지와 타이틀 위치 조정
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit

        // 간격 조정
        let spacing: CGFloat = 4
        if let imageSize = button.imageView?.intrinsicContentSize,
           let titleSize = button.titleLabel?.intrinsicContentSize {
            button.titleEdgeInsets = UIEdgeInsets(
                top: imageSize.height + spacing,
                left: -imageSize.width,
                bottom: 0,
                right: 0
            )
            button.imageEdgeInsets = UIEdgeInsets(
                top: 0,
                left: (titleSize.width / 2),
                bottom: titleSize.height + spacing,
                right: -(titleSize.width / 2)
            )
        }

        // 크기 제한
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 90)
        ])

        // 액션 추가
        button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupCategoryButtons() {
        let beforeLabel = UILabel()
        beforeLabel.text = "외출 전"
        beforeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        beforeLabel.textAlignment = .left
        
        let beforeStack = UIStackView()
        beforeStack.axis = .horizontal
        beforeStack.spacing = 15
        beforeStack.alignment = .center
        beforeStack.distribution = .equalSpacing
        beforeStack.backgroundColor = UIColor(red: 1.0, green: 0.86, blue: 0.86, alpha: 1.0)  // #FFDCDC
        beforeStack.layer.cornerRadius = 12
        beforeStack.isLayoutMarginsRelativeArrangement = true
        beforeStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        let beforeTitles = ["기초", "베이스", "아이", "립"]
        let beforeImages = ["icon_기초", "icon_베이스", "icon_아이", "icon_립"]  // Assets에 있는 이미지 이름

        beforeTitles.enumerated().forEach { index, title in
            let imageName = beforeImages[index]
            let btn = makeCategoryButton(title: title, imageName: imageName, tag: 100 + index, mode: .before)
            beforeStack.addArrangedSubview(btn)
        }
        
        let afterLabel = UILabel()
        afterLabel.text = "귀가 후"
        afterLabel.font = UIFont.boldSystemFont(ofSize: 18)
        afterLabel.textAlignment = .left

        let afterStack = UIStackView()
        afterStack.axis = .horizontal
        afterStack.spacing = 15
        afterStack.alignment = .center
        afterStack.distribution = .equalSpacing
        afterStack.backgroundColor = UIColor(red: 1.0, green: 0.86, blue: 0.86, alpha: 1.0)  // #FFDCDC
        afterStack.layer.cornerRadius = 12
        afterStack.isLayoutMarginsRelativeArrangement = true
        afterStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        let afterTitles = ["베이스", "아이", "립"]
        let afterImages = ["icon_베이스", "icon_아이", "icon_립"]

        afterTitles.enumerated().forEach { index, title in
            let imageName = afterImages[index]
            let btn = makeCategoryButton(title: title, imageName: imageName, tag: 200 + index, mode: .after)
            afterStack.addArrangedSubview(btn)
        }

        let mainStack = UIStackView(arrangedSubviews: [
            beforeLabel, beforeStack,
            afterLabel, afterStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center

        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: mode == .date ? calendar.bottomAnchor : tempPicker.bottomAnchor, constant: 20),
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    
    private func makeButton(_ title: String, tag: Int, mode: RecordContext.Mode) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.tag = tag
        btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        
        btn.accessibilityHint = mode == .before ? "before" : "after"
        return btn
    }

    
    @objc private func categoryTapped(_ sender: UIButton) {
        
        // 버튼 제목(한글)
        guard let korCategory = sender.title(for: .normal),
              let modeHint = sender.accessibilityHint else {
              print("❗️버튼 정보 없음")
              return
        }
            
        // 버튼에서 전달된 모드를 사용
        let selectedMode: RecordContext.Mode = (modeHint == "before") ? .before : .after

        let categoryToRaw: [String: String] = [
            "기초": "skincare", "베이스": "base", "아이": "eye", "립": "lip"
        ]
        let categoryToInt: [String: Int] = [
            "skincare": 0, "base": 1, "eye": 2, "lip": 3
        ]
        
        guard let rawCategory = categoryToRaw[korCategory],
              let categoryInt = categoryToInt[rawCategory],
              let category = RecordContext.Category(rawValue: rawCategory) else {
            print("❗️카테고리 매핑 실패")
            return
        }
        
        // context 업데이트
        if context != nil {
            context?.mode = selectedMode   // 만약 mode가 var라면
            context?.category = category
        } else {
            context = RecordContext(mode: selectedMode, category: category)
        }

        
        print("context 설정 완료: \(context.mode), \(context.category)")
        print("질문 수: \(context.questionItems.count)")
        
        // 디버깅 로그
        print("선택된 카테고리: \(korCategory) → raw: \(rawCategory), int: \(categoryInt)")
        print("선택된 날짜: \(selectedDate)")
        print("선택된 기온: \(selectedTemp ?? -999), 습도: \(selectedHumid ?? -999)")
        //

        // 날짜/날씨 범위 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        print("formatted selectedDate: \(formatter.string(from: selectedDate))")
        let selectedDateString = formatter.string(from: selectedDate)
        
        var dateFrom: Date, dateTo: Date
        var tempRange: (Double, Double)?
        var humidRange: (Double, Double)?
        
        switch mode {
        case .date:
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
            dateFrom = calendar.startOfDay(for: selectedDate)
            dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)!

            
            // 온도/습도 필터 제거
            tempRange = nil
            humidRange = nil
            
        case .weather:
            if let t = selectedTemp, t != -999,
                let h = selectedHumid, h != -999 {
                let temp = Double(t)
                let humid = Double(h)
                tempRange = (temp - 2, temp + 2)
                humidRange = (humid - 5, humid + 5)
            }
            
            // .weather 모드에서는 모든 기록 다 조회
            dateFrom = Date(timeIntervalSince1970: 0)
            dateTo = Date()
        }
        
        fetchRecord(
            mode: selectedMode,
            categoryInt: categoryInt,
            dateFrom: dateFrom,
            dateTo: dateTo,
            tempRange: tempRange,
            humidRange: humidRange
        ) { doc in
            if let doc = doc {
                DispatchQueue.main.async {
                    print("doc loaded: \(doc.documentID)")
                    print("context.questionItems: \(self.context.questionItems.count)")
                    print("recordDetailView: \(self.recordDetailView != nil)")
                            
                    self.recordDetailView.configure(with: doc, context: self.context)
                    self.recordDetailView.isHidden = false
                    

                }
            } else {
                DispatchQueue.main.async {
                    self.recordDetailView.isHidden = true
                    let alert = UIAlertController(title: "알림", message: "기록이 없습니다", preferredStyle: .alert)
                    alert.addAction(.init(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    
    private func fetchRecord(
        mode: RecordContext.Mode,
        categoryInt: Int,
        dateFrom: Date,
        dateTo: Date,
        tempRange: (Double, Double)?,
        humidRange: (Double, Double)?,
        completion: @escaping (QueryDocumentSnapshot?) -> Void
    ) {
        let modeInt = (mode == .before) ? 0 : 1
        
        // 디버깅 로그
        print("Querying with:")
        print(" - mode: \(mode)")
        print(" - categoryInt: \(categoryInt)")
        print(" - dateFrom: \(dateFrom), dateTo: \(dateTo)")
        if let tempRange = tempRange {
            print(" - tempRange: \(tempRange.0) ~ \(tempRange.1)")
        }
        if let humidRange = humidRange {
            print(" - humidRange: \(humidRange.0) ~ \(humidRange.1)")
        }
        //
        
        var q: Query = db.collection("motd_records")
            .whereField("mode", isEqualTo: modeInt)
            .whereField("category", isEqualTo: categoryInt)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: dateFrom))
            .whereField("date", isLessThan: Timestamp(date: dateTo))
        
        if let (minT, maxT) = tempRange {
            q = q.whereField("temp", isGreaterThanOrEqualTo: minT)
                 .whereField("temp", isLessThanOrEqualTo: maxT)
        }
        
        if let (minH, maxH) = humidRange {
            q = q.whereField("humid", isGreaterThanOrEqualTo: minH)
                 .whereField("humid", isLessThanOrEqualTo: maxH)
        }

        q.order(by: "date", descending: true)
         .limit(to: 1)
         .getDocuments { snap, error in
             if let error = error {
                print("Firestore 쿼리 에러: \(error.localizedDescription)")
                completion(nil)
                return
            }

            print("문서 개수: \(snap?.documents.count ?? 0)")
            snap?.documents.forEach { doc in
                print("문서: \(doc.data())")
            }
             completion(snap?.documents.first)
         }
    }
}

extension CheckViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if mode == .date {
            selectedDate = date
        }
    }
}

extension CheckViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent comp: Int) -> Int {
        pickerView == tempPicker ? tempValues.count : humidValues.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent comp: Int) -> String? {
        "\(pickerView == tempPicker ? tempValues[row] : humidValues[row])" + (pickerView == humidPicker ? "%" : "°")
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent comp: Int) {
        if pickerView == tempPicker { selectedTemp = tempValues[row] }
        else { selectedHumid = humidValues[row] }
    }
}

