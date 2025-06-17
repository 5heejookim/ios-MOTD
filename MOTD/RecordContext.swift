//
//  RecordContext.swift

import Foundation

struct RecordContext {
    enum Mode: String {
        case before, after
        var displayName: String {
            switch self {
            case .before: return "외출 전"
            case .after: return "귀가 후"
            }
        }
    }

    enum Category: String {
        case skincare, base, eye, lip
        var displayName: String {
            switch self {
            case .skincare: return "기초"
            case .base: return "베이스"
            case .eye: return "아이"
            case .lip: return "립"
            }
        }
    }

    var mode: Mode
    var category: Category

    var questionItems: [QuestionItem] {
        switch (mode, category) {
        case (.before, .skincare):
            return [
                QuestionItem(title: "수분감", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "유분감", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "마무리감", options: ["매우 매트", "매트", "보통", "글로우", "매우 글로우"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
            ]
        case (.before, .base):
            return [
                QuestionItem(title: "밀착력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "모공&요철 커버", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "잡티 커버", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "마무리감", options: ["매우 매트", "매트", "보통", "글로우", "매우 글로우"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
            ]
        case (.before, .eye):
            return[
                QuestionItem(title: "밀착력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "뭉침(끼임) 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "처짐 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
            ]
        case (.before, .lip):
            return[
                QuestionItem(title: "밀착력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "뭉침(끼임) 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
                ]
        case (.after, .base):
            return [
                QuestionItem(title: "지속력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "수분감", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "유분감", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "무너짐", options: ["매우 매트", "매트", "보통", "글로우", "매우 글로우"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
            ]
        case (.after, .eye):
            return[
                QuestionItem(title: "번짐 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "처짐 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "유지력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
            ]
        case (.after, .lip):
            return[
                QuestionItem(title: "뭉침(끼임) 정도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "지속력", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "수분감", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"]),
                QuestionItem(title: "전체적인 만족도", options: ["매우 불만족", "불만족", "보통", "만족", "매우 만족"])
                ]
            
        default:
            return []
        }
    }
}

struct QuestionItem {
    let title: String
    let options: [String]
}
