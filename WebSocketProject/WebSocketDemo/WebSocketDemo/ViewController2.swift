//
//  ViewController2.swift
//  WebSocketDemo
//
//  Created by hq on 2023/3/1.
//

import UIKit

class ViewController2: UIViewController {
    private let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    private let shared = WebSocketSingleton.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.center = view.center
        button.backgroundColor = .systemBlue
//        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.accessibilityLabel = "testButton"
        view.accessibilityLabel = "testView"
        view.addSubview(button)
    }

}
