import Foundation

enum Voting {
    
    class MeResponse: Codable {
        let votingStatus: VotingStatus
        let votingId: String
        let startDate: Date
        let finishDate: Date
        let title: String
        let contractTx: String
        let groupId: String
        let groupTitle: String
        let publicKey: String?
    }
    
    enum VotingStatus: String, Codable {
        case register = "REGISTER"
        case prepare = "PREPARE"
        case active = "ACTIVE"
        case finished = "FINISHED"
    }
    
    class UsersResponse: Codable {
        let key: String?
        let user: UserModel
    }
    
    class Form: Codable {
        var feedbacks: [Feedback]
        var comment: String?
        
        class Feedback: Codable {
            let theme: String
            var rating: Int?
            
            fileprivate init(theme: String) {
                self.theme = theme
                self.rating = nil
            }
        }
        
        private init() {
            self.feedbacks = [
                Feedback(theme: "Полезность курсов для Вашей будущей карьеры"),
                Feedback(theme: "Полезность курса для расширения кругозора и разностороннего развития"),
                Feedback(theme: "Новизна полученных знаний"),
                Feedback(theme: "Сложность курса для успешного прохождения")
            ]
            self.comment = nil
        }
        
        static var testForm: Form {
            return Form()
        }
    }
    
}
