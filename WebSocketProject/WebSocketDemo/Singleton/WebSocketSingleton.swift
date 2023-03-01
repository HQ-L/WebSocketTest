//
//  WebSocketSingleton.swift
//  WebSocketDemo
//
//  Created by hq on 2023/3/1.
//

import Foundation
import SwiftyJSON

class WebSocketSingleton: NSObject {

    public static let shared = WebSocketSingleton()
    private var webSocket: URLSessionWebSocketTask?
    private var url: URL?
    private var sendMessage: [String] = []

    private override init() {
        super.init()
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )

        url = URL(string: "ws://127.0.0.1:8823")

        guard let url = url else { return }

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
}

extension WebSocketSingleton: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("connect")
        ping()
        recive()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}

private extension WebSocketSingleton {

    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error as? NSError {
                print(error.code)
            }
        })
    }

    @objc func send() {
//        sendMessage = "{ \"user\": \"ios\", \"message\": \(sendMessage)}"
        var send = ""

        for msg in sendMessage {
            send = send + msg + "\n"
        }

        send = "{ \"user\": \"ios\", \"message\": \"\(send)\"}"

        webSocket?.send(.string(send), completionHandler: { error in
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
                    if stringJson["type"] == "click" && stringJson["user"] != "ios" {
                        self?.sendMessage = [TestTool.generateCodeForAllViewsWithAccessibilityLabel()]
//                        self?.sendMessage = TestTool.printViewHierachy()
                        self?.send()
                    }
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
