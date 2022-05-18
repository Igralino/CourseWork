import HSEUI
import HSEUIComponents
import UIKit
import WebKit
import JavaScriptCore


class RegisterSopViewController: CollectionViewController {
    
    private lazy var registerService = RequestService<BaseService.EmptyCodable> { [weak self] in
        return API.main.registerVoting(key: self?.publicKey ?? "", votingId: self?.me.votingId ?? "")
    }
    
    private let me: Voting.MeResponse
    
    private let service: SopService
    
    private var publicKey: String?
    
    init(me: Voting.MeResponse, success: Action? = nil) {
        self.me = me
        self.service = SopService(user: me)
        super.init(features: [.bottomButton])
        
        listeners.append(registerService.dataFetched.listen { [weak self] in
            self?.updateCollection()
            if let error = self?.registerService.serviceError {
                BottomSheetEvent.error.raise(data: error)
            } else {
                Navigator.main.pop()
                success?()
            }
        })
        title = "Регистрация"
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
            TextViewModel(text: "Дата начала", style: .secondary),
            TextViewModel(text: me.startDate.getFullDate(), font: Font.main.withSize(15)),
            TextViewModel(text: "Дата конца", style: .secondary),
            TextViewModel(text: me.finishDate.getFullDate(), font: Font.main.withSize(15)),
            PaddingViewModel(),
            TextViewModel(text: "Регистрация", font: Font.main(weight: .semibold).withSize(17), preferredViewType: .label),
        ]

        if me.publicKey != nil && self.publicKey == nil {
            cells += [
                TextViewModel(text: "Вы успешно зарегистрированы на СОП!\nВ момент начала открытия формы вы получите push уведомление. Для участия в оценке образования вам понадобится ваш приватный ключ подписи голоса.\n\nВ любой момент до начала голосования вы можете перегенерировать ключи при необходимости", preferredViewType: .label),
                TextViewModel(text: "Другие участники", tapCallback: { [weak self] in
                    Navigator.main.showController(SopUsersViewController(me: self?.me))
                }),
                PaddingViewModel()
            ]
        } else if me.publicKey == nil && self.publicKey == nil {
            cells += [
                TextViewModel(text: "Сгенерируйте ключи для регисрации в голосовании", preferredViewType: .label)
            ]
        } else {
            cells += [
                TextViewModel(text: "Ваши ключи сгенерированы. Вы можете зарегистрироваться на голосование", preferredViewType: .label),
                TextViewModel(text: self.publicKey)
            ]
        }
        return CollectionViewModel(cells: cells)
    }
    
    override func setUpBottomButtonView() {
        if self.publicKey != nil {
            bottomButton.state = .enabled
            bottomButton.title = me.publicKey == nil ? "Зарегистрироваться" : "Обновить ключи"
            bottomButton.action = { [weak self] in
                self?.showHSELoader()
                self?.registerService.fetch()
            }
        } else {
            bottomButton.state = .enabled
            bottomButton.title = "Сгенерировать ключи"
            bottomButton.action = { [weak self] in
                let vc = SopKeysGeneratorViewController { [weak self] publicKey, privateKey in
                    self?.publicKey = publicKey
                    self?.service.saveKeys(publicKey: publicKey, privateKey: privateKey)
                    Navigator.main.closeSheet()
                    self?.setUpBottomButtonView()
                    self?.updateCollection()
                }
                Navigator.main.showControllerAsBottomsheet(vc)
            }
        }
    }
    
}

extension API {
    
    func registerVoting(key: String, votingId: String) -> APIRequest {
        let data = [
            "key": key,
            "voting_id": votingId
        ]
        return .make("\(host.rawValue)/voting/key", method: .post, body: data, headers: defaultAuthHeaders)
    }
    
}

fileprivate class SopKeysGeneratorViewController: UIViewController {
    
    private let onGenerateKeys: (String, String) -> ()
    
    init(onGenerateKeys: @escaping (String, String) -> ()) {
        self.onGenerateKeys = onGenerateKeys
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let webView: WKWebView = WKWebView()

    override func loadView() {
        view = webView
        let myUrl = Bundle.main.url(forResource: "main", withExtension: "html")!
        webView.loadFileURL(myUrl,allowingReadAccessTo: myUrl)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var alice: Dictionary<String, String> = [:]
            self.webView.evaluateJavaScript("lrs.gen()") { (result, error) in
                if let error = error {
                    BottomSheetEvent.error.raise(data: ServiceError.init(message: error.localizedDescription))
                    return
                }
                guard let result = result as? Dictionary<String, String> else {
                    BottomSheetEvent.error.raise(data: ServiceError.init(name: ServiceError.Name.parseError.rawValue))
                    return
                }

                print("RES get \(result.debugDescription)")
                alice = result as! Dictionary
                if let publicKey = alice["publicKey"], let privateKey = alice["privateKey"] {
                    self.onGenerateKeys(publicKey, privateKey)
                } else {
                    BottomSheetEvent.error.raise(data: ServiceError.init(name: ServiceError.Name.parseError.rawValue))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHSELoader()
    }
    
}

