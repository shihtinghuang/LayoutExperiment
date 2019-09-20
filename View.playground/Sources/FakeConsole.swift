import UIKit


public class FakeConsole {
    public weak var label: UILabel?
    private var texts: [String] = []

    public static var shared: FakeConsole = FakeConsole()

    private var timer: Timer?

    public static func print(_ text: String) {
        shared.texts.append(text)
        shared.timer?.invalidate()
        shared.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            self.shared.summery()
        })
    }

    func summery() {
        label?.text = texts.joined(separator: "\n")
        texts = []
    }

    public static func clear() {
        shared.label?.text = nil
    }
}
