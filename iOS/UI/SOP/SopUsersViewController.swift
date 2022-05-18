import HSEUI
import HSEUIComponents
import UIKit

class SopUsersViewController: CollectionViewController {
    
    private lazy var usersService = RequestService<[Voting.UsersResponse]> { [weak self] in
        API.main.votingUsers(for: self?.me?.votingId ?? "")
    }
    
    private let me: Voting.MeResponse?
    
    init(me: Voting.MeResponse?) {
        self.me = me
        super.init(features: [.refresh])
        
        listeners.append(usersService.dataFetched.listen { [weak self] in
            self?.updateCollection()
        })
        title = "Участники"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchData() {
        usersService.fetch()
    }
    
    override func collectionViewModel() -> CollectionViewModelProtocol {
        if let error = usersService.serviceError {
            return CommonErrorCollectionViewModel(error: error.overflowData(), tapCallback: error.tapCallback(sender: { [unowned self] in return self }))
        } else {
            let users = usersService.data ?? []
            if users.isEmpty {
                return CommonErrorCollectionViewModel(error: .nobodyFound)
            } else {
                var cells: [CellViewModel] = []
                users.forEach { user in
                    cells += [
                        SearchResultViewModel(model: user.user.baseItem, tapCallback: nil),
                        TextViewModel(text: "Публичный ключ", style: .secondary),
                        TextViewModel(text: user.key ?? "Ключ не найден"),
                        PaddingViewModel(),
                        SeparatorViewModel()
                    ]
                }
                cells.removeLast()
                return CollectionViewModel(cells: cells)
            }
        }
    }
    
}

extension API {
    
    func votingUsers(for votingId: String) -> APIRequest {
        let data = [
            "voting_id": votingId
        ]
        return .make("\(host.rawValue)/voting/users", method: .post, body: data, headers: defaultAuthHeaders)
    }
    
}
