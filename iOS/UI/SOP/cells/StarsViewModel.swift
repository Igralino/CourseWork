import HSEUI
import HSEUIComponents
import UIKit

class StarsViewModel: CellViewModel {
    
    init(value: Int, onChange: @escaping (Int) -> ()) {
        super.init(view: StarsView.self, configureView: { view in
            view.onChange = onChange
            view.update(newValue: value)
        })
    }
    
}

class StarsView: CellView {
    
    var onChange: ((Int) -> ())?
    
    private var stars: [StarView] = []
    
    override func commonInit() {
        let stack = UIStackView()
        addSubview(stack)
        stack.stickToSuperviewEdges(.all, insets: UIEdgeInsets(top: 4, left: 20, bottom: 12, right: 20))
        for i in 1...5 {
            let starView = StarView { [weak self] in
                self?.update(newValue: i)
                self?.onChange?(i)
            }
            stars.append(starView)
            stack.addArrangedSubview(starView)
        }
        stack.spacing = 20
        stack.distribution = .fillEqually
    }
    
    func update(newValue: Int) {
        for j in 0..<5 {
            stars[j].isEnabled = j < newValue
        }
    }
    
}

fileprivate class StarView: CellView {
    
    init(onTap: @escaping Action) {
        super.init()
        configureTap(callback: onTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView = UIImageView()
    
    override func commonInit() {
        super.commonInit()
        addSubview(imageView)
        imageView.stickToSuperviewEdges(.all, insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        imageView.aspectRatio()
    }
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                imageView.image = sfSymbol("star.fill")?.withTintColor(Color.Base.brandTint)
            } else {
                imageView.image = sfSymbol("star")?.withTintColor(Color.Base.brandTint)
            }
        }
    }
    
}
