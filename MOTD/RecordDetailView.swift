// RecordDetailView.swift

import UIKit
import FirebaseFirestore

class RecordDetailView: UIView {

    private let brandLabel = UILabel()
    private let productLabel = UILabel()
    private let questionStackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func makeDivider(height: CGFloat = 1, color: UIColor = .lightGray) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: height)
        ])
        return divider
    }

    private func setupUI() {
        backgroundColor = UIColor(red: 1.0, green: 0.949, blue: 0.922, alpha: 1.0)
        
        brandLabel.font = .systemFont(ofSize: 17)
        productLabel.font = .systemFont(ofSize: 17)
        
        questionStackView.axis = .vertical
        questionStackView.spacing = 16
        questionStackView.alignment = .leading
        
        contentView.axis = .vertical
        contentView.spacing = 15
        contentView.alignment = .fill
        
        contentView.addArrangedSubview(brandLabel)
        contentView.addArrangedSubview(productLabel)
        contentView.addArrangedSubview(questionStackView)
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        productLabel.translatesAutoresizingMaskIntoConstraints = false
        questionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            questionStackView.topAnchor.constraint(equalTo: productLabel.bottomAnchor, constant: 30)
        ])
    }

    func configure(with recordDoc: QueryDocumentSnapshot, context: RecordContext) {
        print("configure() called!!!")
        questionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let data = recordDoc.data()
        print("recordDoc data exists: \(recordDoc.exists)")
        print("recordDoc data isEmpty: \(data.isEmpty)")
        print("recordDoc raw: \(data)")

        brandLabel.text = "브랜드: \(data["brand"] as? String ?? "-")"
        productLabel.text = "제품명: \(data["product"] as? String ?? "-")"

        let questions = context.questionItems
        if questions.isEmpty {
            print("context.questionItems is empty")
            return
        }

        // 🔧 수정된 부분: [String: Int] → [Int: Int]
        guard let answerDict = data["answer"] as? [String: Int] else {
            print("answer field missing or not [String: Int]")
            return
        }

        var rawAnswers: [Int: Int] = [:]
        for (key, value) in answerDict {
            if let intKey = Int(key) {
                rawAnswers[intKey] = value
            }
        }
        
        if !questions.isEmpty {
            // 질문1 위 구분선 추가
            let firstDivider = makeDivider()
            questionStackView.addArrangedSubview(firstDivider)
            NSLayoutConstraint.activate([
                firstDivider.leadingAnchor.constraint(equalTo: questionStackView.leadingAnchor),
                firstDivider.trailingAnchor.constraint(equalTo: questionStackView.trailingAnchor)
            ])
        }

        for (index, item) in questions.enumerated() {
            let selectedIdx = rawAnswers[index] ?? -1
            let qView = createQuestionView(title: item.title, options: item.options, selected: selectedIdx)
            questionStackView.addArrangedSubview(qView)
            
            if index < questions.count - 1 {
                let divider = makeDivider()
                questionStackView.addArrangedSubview(divider)
                // divider가 완전히 questionStackView에 추가된 이후에 제약 걸기
                NSLayoutConstraint.activate([
                    divider.leadingAnchor.constraint(equalTo: questionStackView.leadingAnchor),
                    divider.trailingAnchor.constraint(equalTo: questionStackView.trailingAnchor)
                ])
            }
        }
    }

    private func createQuestionView(title: String, options: [String], selected: Int) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 7
        container.alignment = .leading

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        container.addArrangedSubview(titleLabel)

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 9
        buttonStack.alignment = .leading
        buttonStack.distribution = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.heightAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true

        container.addArrangedSubview(buttonStack)

        for (idx, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(idx == selected ? .black : .black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            button.isUserInteractionEnabled = false
            button.backgroundColor = idx == selected ? UIColor(red: 1.0, green: 0.8627, blue: 0.8627, alpha: 1.0) : .clear

            buttonStack.addArrangedSubview(button)
        }

        return container
    }
}
