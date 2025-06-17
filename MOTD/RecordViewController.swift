//
//  RecordViewController.swift
//

import UIKit
import FirebaseFirestore

class RecordViewController: UIViewController {

    // MARK: - 전달받은 정보
    var context: RecordContext!

    // MARK: - UI 요소들 (스토리보드에 연결)
    
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var productTextField: UITextField!
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var brandproductStackView: UIStackView!
    
    // 문항별 선택값 저장
    var answers: [String: String] = [:]
    var selectedAnswers: [Int] = [] // index는 질문 순서, 값은 선택된 옵션 인덱스
    
    var questionToButtons: [String: [UIButton]] = [:]
    
    // 브랜드, 제품명 텍스트 필드
    var brandSuggestions: [String] = []
    var productSuggestions: [String] = []

    var isSearchingBrand = false // 현재 어떤 필드를 검색 중인지 추적
    
    var selectedBrandName: String? // 브랜드 선택 시 이 변수에 저장
    
    var suggestionTableView: UITableView!
    
    var currentTemp: Double?
    var currentHumidity: Double?
    
    private var weatherManager = WeatherManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSuggestionTableView()
        suggestionTableView.isHidden = true
        view.bringSubviewToFront(suggestionTableView)
        
        self.title = "\(context.mode.displayName) \(context.category.displayName) 기록"
        setupQuestions()
        
        brandTextField.delegate = self
        productTextField.delegate = self
        
        brandTextField.addTarget(self, action: #selector(brandTextChanged(_:)), for: .editingChanged)
        productTextField.addTarget(self, action: #selector(productTextChanged(_:)), for: .editingChanged)
        
        weatherManager.requestLocation { lat, lon in
            WeatherService.fetchWeather(lat: lat, lon: lon) { temp, humidity in
                DispatchQueue.main.async {
                    self.currentTemp = temp
                    self.currentHumidity = humidity
                    print("날씨 정보 불러옴: temp = \(String(describing: temp)), humidity = \(String(describing: humidity))")
                }
            }
        }
    }
    
    func setupSuggestionTableView() {
            suggestionTableView = UITableView()
            suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
            suggestionTableView.rowHeight = UITableView.automaticDimension
            suggestionTableView.estimatedRowHeight = 44
            suggestionTableView.bounces = true

            suggestionTableView.delegate = self
            suggestionTableView.dataSource = self
        
            suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        
            suggestionTableView.isHidden = true
            view.addSubview(suggestionTableView)

            NSLayoutConstraint.activate([
                suggestionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                suggestionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                suggestionTableView.topAnchor.constraint(equalTo: brandproductStackView.bottomAnchor, constant: 4),
                suggestionTableView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
            ])
        }
    
//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {

    }
    
    @objc func brandTextChanged(_ textField: UITextField) {
        guard let keyword = textField.text?.lowercased(), !keyword.isEmpty else {
            brandSuggestions = []
            suggestionTableView.isHidden = true
            return
        }

        isSearchingBrand = true
        searchFirestore(for: "brand", matching: keyword)
    }

    @objc func productTextChanged(_ textField: UITextField) {
        guard let keyword = textField.text?.lowercased(), !keyword.isEmpty else {
            productSuggestions = []
            suggestionTableView.isHidden = true
            return
        }

        guard let _ = selectedBrandName else {
            let alert = UIAlertController(title: "브랜드 선택", message: "브랜드를 먼저 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }


        isSearchingBrand = false
        searchFirestore(for: "product", matching: keyword)
    }

    
    func searchFirestore(for field: String, matching keyword: String) {
        let db = Firestore.firestore()
        let categoryKey = context.category.displayName

        var query: Query = db.collection("oliveyoung_products")
            .whereField("category", isEqualTo: categoryKey)

        if field == "product", let selectedBrand = selectedBrandName {
            query = query.whereField("brand", isEqualTo: selectedBrand)
        }

        query.getDocuments { snapshot, error in
            if let error = error as NSError? {
                print("Firestore 에러 코드: \(error.code), 설명: \(error.localizedDescription)")
            }

            guard let documents = snapshot?.documents else { return }

            let results = documents.compactMap { doc -> String? in
                let value = (doc.data()[field] as? String)?.lowercased() ?? ""
                return value.hasPrefix(keyword.lowercased()) ? doc.data()[field] as? String : nil
            }

            if field == "brand" {
                self.brandSuggestions = Array(Set(results)).sorted()
            } else {
                self.productSuggestions = Array(Set(results)).sorted()
            }

            self.suggestionTableView.reloadData()
            
            let isEmpty = self.isSearchingBrand ? self.brandSuggestions.isEmpty : self.productSuggestions.isEmpty
            self.suggestionTableView.isHidden = isEmpty
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            
            DispatchQueue.main.async {
              self.suggestionTableView.reloadData()
              
              let isEmpty = self.isSearchingBrand ? self.brandSuggestions.isEmpty : self.productSuggestions.isEmpty
              self.suggestionTableView.isHidden = isEmpty
              
              // 항상 위에 띄우기
              self.view.bringSubviewToFront(self.suggestionTableView)
              
              UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
              }
            }
        }
    }
    
    private func makeDivider(height: CGFloat = 1, color: UIColor = .lightGray) -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = color
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: height)
        ])
        return divider
    }

    // MARK: - 문항 UI 구성
    func setupQuestions() {
        guard let context = context else { return }
        
        selectedAnswers = Array(repeating: -1, count: context.questionItems.count)
        
        if !context.questionItems.isEmpty {
            // 질문1 위에 구분선 추가
            let firstDivider = makeDivider()
            questionStackView.addArrangedSubview(firstDivider)
            NSLayoutConstraint.activate([
                firstDivider.leadingAnchor.constraint(equalTo: questionStackView.leadingAnchor),
                firstDivider.trailingAnchor.constraint(equalTo: questionStackView.trailingAnchor)
            ])
        }
        
        for (index, item) in context.questionItems.enumerated() {
            let questionView = createQuestionView(title: item.title, options: item.options)
            questionStackView.addArrangedSubview(questionView)
            
            // 마지막 질문이 아니면 구분선 추가
            if index < context.questionItems.count - 1 {
                let divider = makeDivider()
                questionStackView.addArrangedSubview(divider)
            }
        }
    }

    // MARK: - 문항 생성 함수
    func createQuestionView(title: String, options: [String]) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 7
        container.alignment = .leading

        // 질문 제목
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0 // 여러 줄 허용
        container.addArrangedSubview(titleLabel)

        // 옵션 버튼들을 담을 수평 스택뷰
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.alignment = .leading
        buttonStack.distribution = .fill
        // 또는 균등하게 배분할 경우:
        // buttonStack.distribution = .equalSpacing
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.heightAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true

        container.addArrangedSubview(buttonStack)

        var optionButtons: [UIButton] = []

        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

            // 고유 태그 설정
            button.tag = uniqueTagForQuestionOption(title, option)

            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)

            optionButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
        questionToButtons[title] = optionButtons

        return container
    }

    // MARK: - 버튼 클릭 시 처리
    @objc func optionTapped(_ sender: UIButton) {
        let (question, option) = reverseTagToQuestionOption(tag: sender.tag)

        if let questionIndex = context.questionItems.firstIndex(where: { $0.title == question }),
           let optionIndex = context.questionItems[questionIndex].options.firstIndex(of: option) {
            
            selectedAnswers[questionIndex] = optionIndex

            // 버튼 UI 업데이트
            if let buttons = questionToButtons[question] {
                for (i, button) in buttons.enumerated() {
                    button.backgroundColor = i == optionIndex ? UIColor(red: 1.0, green: 0.8627, blue: 0.8627, alpha: 1.0) : .clear

//                    button.setTitleColor((i == optionIndex) ? .white : .black, for: .normal)
                }
            }
        }
    }

    // MARK: - 고유 태그 생성 및 해석
    func uniqueTagForQuestionOption(_ question: String, _ option: String) -> Int {
        // 고유 tag를 위해 question hash 앞 4자리 + option hash 뒷 4자리처럼 조합
        let qHash = abs(question.hashValue) % 10000
        let oHash = abs(option.hashValue) % 10000
        return qHash * 10000 + oHash
    }

    func reverseTagToQuestionOption(tag: Int) -> (String, String) {
        // 이건 정확히 복원할 수는 없지만, 실전에서는 버튼에 사용자 정의 속성이나 맵핑 테이블을 두는 게 좋습니다.
        // 임시로 추적된 질문 구조 사용
        for item in context.questionItems {
            for option in item.options {
                if uniqueTagForQuestionOption(item.title, option) == tag {
                    return (item.title, option)
                }
            }
        }
        return ("", "")
    }

    // MARK: - 저장 버튼 눌렀을 때
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("저장 시점 temp: \(String(describing: currentTemp)), humid: \(String(describing: currentHumidity))")

        guard let recordContext = context else { return }
        
        // temp 또는 humid가 아직 nil인 경우 저장 막기
        guard let temp = currentTemp, let humid = currentHumidity else {
            let alert = UIAlertController(title: "날씨 정보 로딩 중", message: "잠시 후 다시 시도해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        let db = Firestore.firestore()
            
        // selectedAnswers: [Int] → [String: Int] 변환
        var answerDict: [String: Int] = [:]
        for (index, value) in selectedAnswers.enumerated() where value >= 0 {
                answerDict["\(index)"] = value
        }
        
        // 날짜를 yyyy-MM-dd 문자열로 포맷팅
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let data: [String: Any] = [
            "id": 0, // 임시로 0 설정
            "mode": recordContext.mode == .before ? 0 : 1,
            "category": recordContext.category.rawValue == "skincare" ? 0 :
                            recordContext.category.rawValue == "base" ? 1 :
                            recordContext.category.rawValue == "eye" ? 2 : 3,
            "brand": brandTextField.text ?? "",
            "product": productTextField.text ?? "",
            "answer": answerDict,
            "date": Timestamp(date: Date()),
            "temp": temp,
            "humid": humid
        ]
        
        db.collection("motd_records").addDocument(data: data) { error in
            if let error = error {
                print("저장 실패: \(error)")
            } else {
                print("저장 성공")
                let alert = UIAlertController(title: "성공", message: "기록이 저장되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - 뒤로가기
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RecordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        suggestionTableView.isHidden = true
    }
}

extension RecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchingBrand ? brandSuggestions.count : productSuggestions.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "SuggestionCell"
        let cell = tv.dequeueReusableCell(withIdentifier: cellID) ??
            UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.textLabel?.text = isSearchingBrand ? brandSuggestions[indexPath.row] : productSuggestions[indexPath.row]
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = isSearchingBrand ? brandSuggestions[indexPath.row] : productSuggestions[indexPath.row]

        if isSearchingBrand {
            brandTextField.text = selected
            selectedBrandName = selected
        } else {
            productTextField.text = selected
        }
        tv.isHidden = true
    }
}
