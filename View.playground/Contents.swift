//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MiniView: UIView {
    override func updateConstraints() {
        FakeConsole.print("\(type(of: self)): \(#function)")
        super.updateConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        FakeConsole.print("\(type(of: self)): \(#function)")
    }
}
class SimpleView: UIView {
    override func updateConstraints() {
        FakeConsole.print("\(type(of: self)): \(#function)")
        print("update")
        super.updateConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layout")
        FakeConsole.print("\(type(of: self)): \(#function)")
    }
}

class MyViewController : UIViewController {
    var simpleView: SimpleView?
    var simpleViewTopConstrain: NSLayoutConstraint?
    var widthConstrains: NSLayoutConstraint?

    // ==== Changing the layout property =====

    // Change inner layout
    @objc func changeWidth() {
        FakeConsole.clear()
        FakeConsole.print("Change the width constant triggers the layoutSubView \n\n")



        widthConstrains?.constant = widthConstrains!.constant + 5
    }

    @objc func changeWidthWithSetNeed() {
        FakeConsole.clear()
        FakeConsole.print("setNeedsUpdateConstraints() makes the updateConstraint() called in the cycle    \n\n")



        widthConstrains!.constant += 10
        simpleView?.setNeedsUpdateConstraints()
    }

    // Change outer layout
    @objc func changeTopConstraint() {
        FakeConsole.clear()
        FakeConsole.print("Change top constraint won't trigger layout subview     \n\n")



        simpleViewTopConstrain!.constant += 10
    }

    @objc func changeTopConstraintWithSetNeed() {
        FakeConsole.clear()
        FakeConsole.print("Change top constraint won't trigger layout subview, the updateConstraint is called because the setNeedsUpdateConstraints()    \n\n")



        simpleViewTopConstrain!.constant += 10
        simpleView?.setNeedsUpdateConstraints()
    }

    @objc func callSetNeedLayout() {
        FakeConsole.clear()
        FakeConsole.print("Sometimes the system doesn't layoutSubview, we can call setNeedLayout for notifying the system to call the layoutSubview    \n\n")


        simpleView?.setNeedsLayout()
    }



    // ====  Setup only ====
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leftAnchor.constraint(equalTo: view.leftAnchor),
            label.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        FakeConsole.shared.label = label
        FakeConsole.print("The update pass always comes before layout pass in a single layout cycle \n\n")


        view.backgroundColor = .white

        makeBtn(title: "width constant + 10", action: #selector(changeWidth))
        makeBtn(title: "width constant + 10 w setNeedUpdateConstraint", action: #selector(changeWidthWithSetNeed))

        makeBtn(title: "top constant + 5", action: #selector(changeTopConstraint))
        makeBtn(title: "top constant + 5 w setNeedUpdateConstraint", action: #selector(changeTopConstraintWithSetNeed))

        makeBtn(title: "only setNeedLayout", action: #selector(callSetNeedLayout))
        let simpleView = SimpleView()
        simpleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(simpleView)
        let constrains = simpleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        constrains.isActive = true
        simpleView.backgroundColor = .gray
        NSLayoutConstraint.activate([
            simpleView.heightAnchor.constraint(equalToConstant: 50),

            simpleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20)
            ])
        self.simpleViewTopConstrain = constrains
        self.widthConstrains = simpleView.widthAnchor.constraint(equalToConstant: 50)
        widthConstrains?.isActive = true
        self.simpleView = simpleView


        let miniView = MiniView()
        miniView.translatesAutoresizingMaskIntoConstraints = false
        simpleView.addSubview(miniView)
        miniView.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            miniView.widthAnchor.constraint(equalToConstant: 10),
            miniView.heightAnchor.constraint(equalToConstant: 10),
            miniView.centerXAnchor.constraint(equalTo: simpleView.centerXAnchor),
            miniView.centerYAnchor.constraint(equalTo: simpleView.centerYAnchor)
            ])


    }

}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
