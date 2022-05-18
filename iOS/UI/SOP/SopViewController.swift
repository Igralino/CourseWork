import HSEUI
import HSEUIComponents
import UIKit

class SOPViewController: CollectionViewController {
    
    private let sopService = RequestService<Voting.MeResponse?> { API.main.votingMe }
    
    init() {
        super.init(features: [.bottomButton, .refresh])
        
        listeners.append(sopService.dataFetched.listen { [weak self] in
            self?.updateCollection()
            self?.setUpBottomButtonView()
            if let error = self?.sopService.serviceError {
                BottomSheetEvent.error.raise(data: error)
            }
        })
        title = "СОП"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchData() {
        sopService.fetch()
    }
    
    override func collectionViewModel() -> CollectionViewModelProtocol {
        return CollectionViewModel(cells: [
            ImageViewModel(source: UIImage(named: "sop")!, contentMode: .scaleAspectFit),
            PaddingViewModel(),
            TextViewModel(text: "Студенческая оценка преподавания", font: Font.main(weight: .semibold).withSize(20), preferredViewType: .label),
            PaddingViewModel(),
            TextViewModel(text: "Теперь пройти СОП можно и в HSE App X. Новая система построена на блокчейне, что обеспечивает прозрачность, безопасность и честность голосования.\n\nДо начала голосования, вы должны предварительно зарегистрироваться и сгенерировать публичный и приватный ключи для подписи голоса. Так что думайте о СОПе заранее!", font: Font.main.withSize(16), preferredViewType: .label),
            PaddingViewModel(padding: 12),
            ImageWithTextViewModel(image: #imageLiteral(resourceName: "icons20AccountCircle20"), text: "Анонимно: никто не увидит ваш голос", tintColor: Color.Base.brandTint),
            PaddingViewModel(padding: 12),
            ImageWithTextViewModel(image: #imageLiteral(resourceName: "interactive_panel"), text: "Безопасно: блокчейн + смартконтракты = ❤️", tintColor: Color.Base.brandTint),
            PaddingViewModel(padding: 12),
            ImageWithTextViewModel(image: #imageLiteral(resourceName: "icons24Email24"), text: "Надёжно: знаменитое качество продуктов ФКН", tintColor: Color.Base.brandTint),
            PaddingViewModel(padding: 12),
            ImageWithTextViewModel(image: #imageLiteral(resourceName: "projects24"), text: "Современно: лучшие технологии на проде", tintColor: Color.Base.brandTint),
            PaddingViewModel(padding: 12),
            ImageWithTextViewModel(image: #imageLiteral(resourceName: "iconsUnsortedCheckCircleOn24"), text: "Удобно: в привычном всем HSE App X", tintColor: Color.Base.brandTint)
        ])
    }
    
    override func setUpBottomButtonView() {
        guard let me = sopService.data, let me = me else {
            bottomButton.state = .disabled
            bottomButton.title = "Не сейчас"
            bottomButton.action = {}
            return
        }
        switch me.votingStatus {
        case .register:
            bottomButton.title = "Регистрация"
            bottomButton.state = .enabled
            bottomButton.action = {
                Navigator.main.showController(RegisterSopViewController(me: me, success: { [weak self] in
                    self?.fetchData()
                }))
            }
        case .prepare:
            bottomButton.state = .disabled
            bottomButton.title = "Не сейчас"
        case .active:
            bottomButton.state = .enabled
            bottomButton.title = "Пройти СОП"
            bottomButton.action = { [weak self] in
                Navigator.main.showController(SopFormViewController(me: me, success: { [weak self] in
                    self?.fetchData()
                }))
            }
        case .finished:
            bottomButton.state = .enabled
            bottomButton.title = "Результаты"
        }
    }
    
}

extension API {
    
    var votingMe: APIRequest {
        return .make("\(host.rawValue)/voting/me", headers: defaultAuthHeaders)
    }
    
}
