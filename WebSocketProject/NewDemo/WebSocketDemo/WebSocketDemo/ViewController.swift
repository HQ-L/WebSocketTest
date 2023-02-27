//
//  ViewController.swift
//  WebSocketDemo
//
//  Created by hq on 2023/2/20.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    private let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))

    private var webSocket: URLSessionWebSocketTask?
    private var url: URL?
    private var sendMessage = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        button.center = view.center
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.accessibilityLabel = "testButton"
        view.accessibilityLabel = "testView"
        view.addSubview(button)

        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )

        url = URL(string: "ws://192.168.1.139:8823")

        guard let url = url else { return }

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }


}

extension ViewController: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("connect")
        ping()
        recive()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}

private extension ViewController {
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error as? NSError {
                print(error.code)
            }
        })
    }

    @objc func send() {
        webSocket?.send(.string(sendMessage), completionHandler: { error in
            if let error = error as? NSError {
                print(error.code)
            }
        })
    }

    func recive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("data: \(data)")
                case .string(let string):
                    print("string: \(string)")
                    let stringJson = JSON(parseJSON: string)
                    if stringJson["type"] == "click" {
                        self?.sendMessage = TestTool.generateCodeForAllViewsWithAccessibilityLabel()
                    }
                    self?.send()
                    print("success")
                @unknown default:
                    break
                }
            case .failure(_):
                print("recive error")
            }
            self?.recive()
        })
    }

    func close() {
        webSocket?.cancel(with: .goingAway, reason: "end".data(using: .utf8))
    }
}
