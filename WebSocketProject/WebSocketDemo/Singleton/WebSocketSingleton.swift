//
//  WebSocketSingleton.swift
//  TestTool
//
//  Created by hq on 2023/3/3.
//

import Foundation
import SwiftyJSON

@available(iOS 13.0, *)
public class WebSocketSingleton: NSObject {

    public static let shared = WebSocketSingleton()
    private var webSocket: URLSessionWebSocketTask?
    private var url: URL?
    private var sendMessage: [String] = []

    public var codeStatus = false {
        didSet {
            self.sendMessage = [TestCodeGenerator.shared.code]
            self.send()
        }
    }

    private override init() {
        super.init()
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )

        // 部署websocket服务的地址
        url = URL(string: "ws://192.168.1.181:8823")

        guard let url = url else { return }

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
}

@available(iOS 13.0, *)
extension WebSocketSingleton: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("connect")
        ping()
        recive()
    }

    @available(iOS 13.0, *)
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}

@available(iOS 13.0, *)
private extension WebSocketSingleton {

    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error as? NSError {
                print(error.code)
            }
        })
    }

    @objc func send() {
        var send = sendMessage.joined(separator: "\n")

        do {
            let re = try NSRegularExpression(pattern: "\"", options: .caseInsensitive)
            send = re.stringByReplacingMatches(in: send, options: .reportProgress, range: NSRange(location: 0, length: send.count), withTemplate: "\\\\\"")
        } catch {

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
                    if stringJson["user"] != "ios" {
                        switch stringJson["type"] {
                        case "requireTestCode":
                            self?.sendMessage = [TestCodeGenerator.shared.flushCode()]
                            self?.send()
                        case "beginClass":
                            TestTool.beginClass(stringJson["message"].string ?? "")
                        case "beginFunction":
                            TestTool.beginFunction(stringJson["message"].string ?? "")
                        case "endFunction":
                            TestTool.endFunction()
                        case "endClass":
                            TestTool.endClass()
                        default:
                            break
                        }
                    }
                    print("success")
                @unknown default:
                    break
                }
            case .failure(_):
                print("recive error")
                self?.close()
                self?.webSocket = nil
            }
            self?.recive()
        })
    }

    func close() {
        webSocket?.cancel(with: .goingAway, reason: "end".data(using: .utf8))
    }
}
