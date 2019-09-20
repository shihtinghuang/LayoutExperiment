//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

protocol StateCoordinator: UIView {

    func stateChanged(at subView: UIView)
}
extension UIView: StateCoordinator {
    func stateChanged(at subView: UIView) {
        print("state changed")
    }
}

protocol Renderer: AnyObject {
    func render()
}

class StateStore: Hashable {
    var value: String {
        didSet {
            assert(renderer != nil)
            renderer?.render()
        }
    }

    private weak var renderer: Renderer?

    init(renderer: Renderer, value: String) {
        self.renderer = renderer
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    static func ==(lhs: StateStore, rhs: StateStore) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

struct Label: Hashable {
    var text: String
    weak var stateStore: StateStore?

    init(text: String) {
        self.text = text
    }

    init(stateStore: StateStore) {
        self.text = stateStore.value
        self.stateStore = stateStore
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

/*

class View {
    var text: String {
        didSet {
            render()
        }
    }
    var text2: String {
        didSet {
            render()
        }
    }
    func render() {
        stackView.render([
            Label(text),
            Label(text2)
        ])
    }
}


 */
class StackHost: UIStackView {
    var viewStore: [Int: UILabel] = [:]
    private var current: [Label] = []

    func render(updated: [Label]) {
        let diffs = updated.difference(from: current)
        for diff in diffs {
            switch diff {
            case .insert(let offset, let element, _):
                if let hostedView = viewStore[element.hashValue] {
                    hostedView.text = element.text
                    insertArrangedSubview(hostedView, at: offset)
                } else {
                    let hostedView = UILabel.createLabel()
                    hostedView.text = element.text
                    viewStore[element.hashValue] = hostedView
                    insertArrangedSubview(hostedView, at: offset)
                }

            case .remove(_ , let element, _):
                if let view = viewStore[element.hashValue] {
                    removeArrangedSubview(view)
                    viewStore.removeValue(forKey: element.hashValue)
                }
            }
        }
        current = updated
    }
}

extension UILabel {
    static func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 45))
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        return label
    }
}

class MyViewController : UIViewController, Renderer {
    lazy var stackView: StackHost = {
        let stackView = StackHost()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .leading
        return stackView
    }()

    var text1: String = "1" {
        didSet {
            render()
        }
    }

    var text2: String = "2" {
        didSet {
            render()
        }
    }

    lazy var text3: StateStore = {
        return StateStore(renderer: self, value: "test")
    }()

    func render() {

        stackView.render(updated: [
            Label(text: text1),
            Label(text: text2),
            Label(stateStore: text3)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])




        makeBtn(title: "Change value 1", action: #selector(changeValue1))
        makeBtn(title: "Change value 2", action: #selector(changeValue2))
        render()
    }

    @objc func changeValue1() {
        text3.value = "updated!"
        print("update")
    }
    @objc func changeValue2() {

    }

    func makeBtn(title: String, action: Selector) {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if let lastBtn = view.subviews.compactMap({ $0 as? UIButton }).last {
            view.addSubview(btn)
            btn.topAnchor.constraint(equalTo: lastBtn.bottomAnchor, constant: 20).isActive = true
        } else {
            view.addSubview(btn)
            btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        }
        btn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.setTitleColor(.black, for: .normal)
    }

}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
