import HSEUI
import HSEUIComponents
import UIKit

class SopFormViewController: CollectionViewController {
    
    private let serice: SopService
    
    private let me: Voting.MeResponse
    
    private var form: Voting.Form = Voting.Form.testForm // загрузить форму из web3
    
    init(me: Voting.MeResponse, success: Action? = nil) {
        self.me = me
        self.serice = SopService(user: me)
        super.init(features: [.bottomButton])
        title = "Форма"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionViewModel() -> CollectionViewModelProtocol {
        var cells = [
            TextViewModel(text: "Название голосования", style: .secondary),
            TextViewModel(text: me.title, font: Font.main.withSize(17)),
            TextViewModel(text: "Группа", style: .secondary),
            TextViewModel(text: me.groupTitle, font: Font.main.withSize(15)),
            PaddingViewModel(),
            TextViewModel(text: "Дата начала", style: .secondary),
            TextViewModel(text: me.startDate.getFullDate(), font: Font.main.withSize(15)),
            TextViewModel(text: "Дата конца", style: .secondary),
            TextViewModel(text: me.finishDate.getFullDate(), font: Font.main.withSize(15)),
            PaddingViewModel(),
            TextViewModel(text: "Оцените свои курсы:", font: Font.main(weight: .semibold).withSize(17), preferredViewType: .label),
        ]
        form.feedbacks.forEach({ fb in
            cells += [
                TextViewModel(text: fb.theme, font: Font.main(weight: .medium).withSize(16), preferredViewType: .label),
                StarsViewModel(value: fb.rating ?? 0, onChange: { [weak self] newValue in
                    fb.rating = newValue
                    self?.setUpBottomButtonView()
                })
            ]
        })
        
        cells.append(TextInputViewModel(value: form.comment, placeholder: "Комментарий", textChanged: { [weak self] newText in
            self?.form.comment = newText
            self?.setUpBottomButtonView()
        }, maxSymbols: 400))
        cells.append(TextInputViewModel(value: form.comment, placeholder: "Ключ от кошелька", textChanged: { [weak self] newText in
            self?.walletKey = newText
        }, maxSymbols: 400))
        return CollectionViewModel(cells: cells)
    }
    
    private var walletKey: String?
    
    override func setUpBottomButtonView() {
        bottomButton.title = "Отправить форму"
        bottomButton.action = { [weak self] in
            self?.showHSELoader()
            self?.serice.testGetVotingName(walletKey: self?.walletKey ?? "", completion: { resultFromWeb3 in
                print("success -> resultFromWeb3 Form name", resultFromWeb3)
                self?.removeOverflow()
            })
        }
    }
    
}

extension API {
    
    func postVotingFrom(form: Voting.Form, votingId: String) -> APIRequest {
        struct Payload: Codable {
            let form: Voting.Form
            let votingId: String
        }
        let data = Payload(form: form, votingId: votingId)
        return .make("\(host.rawValue)/voting/form", method: .post, body: data, headers: defaultAuthHeaders)
    }
    
}
