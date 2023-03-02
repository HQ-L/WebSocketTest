//
//  ViewController3.swift
//  WebSocketDemo
//
//  Created by hq on 2023/3/2.
//

import UIKit

class ViewController3: UIViewController {

    private let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.center = view.center
        button.backgroundColor = .systemBlue
//        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.accessibilityLabel = "testButton"
        view.accessibilityLabel = "testView"
        view.backgroundColor = .systemRed
        view.addSubview(button)
    }

}
