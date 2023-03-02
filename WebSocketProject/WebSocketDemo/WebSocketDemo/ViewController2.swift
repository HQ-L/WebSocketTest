//
//  ViewController2.swift
//  WebSocketDemo
//
//  Created by hq on 2023/3/1.
//

import UIKit

class ViewController2: UIViewController {
    private let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    private let button2 = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.center = view.center
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.accessibilityLabel = "testButton"
        button2.accessibilityLabel = "testButton2"
        view.accessibilityLabel = "testView"
        view.addSubview(button)
        view.addSubview(button2)
    }

    @objc func send() {
        let vc = ViewController3()
        navigationController?.pushViewController(vc, animated: true)
    }

}
