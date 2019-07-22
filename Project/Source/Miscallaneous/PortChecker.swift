//
//  PortChecker.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import Foundation

@objc enum PortStatus: Int {
    case checking
    case open
    case closed
    case error
}

@objc protocol PortCheckerDelegate: NSObjectProtocol {
    @objc optional func portCheckerDidFinishProbing(_ portChecker: PortChecker)
}

@objc class PortChecker: NSObject {
    @objc fileprivate (set) var status: PortStatus

    @objc fileprivate (set) var portNumber: Int
    fileprivate weak var delegate: PortCheckerDelegate?
    fileprivate var task: URLSessionDataTask?

    @objc init(port: Int, delay: Bool, delegate: PortCheckerDelegate? = nil) {
        self.portNumber = port
        self.delegate = delegate
        self.status = .checking
        super.init()

        if delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: startProbe)
        } else {
            startProbe()
        }
    }

    func startProbe() {
        let url = URL(string: "http://portcheck.transmissionbt.com/\(portNumber)")!
        let portProbeRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)

        let task = URLSession.shared.dataTask(with: portProbeRequest) { [weak self] (data, response, error) in
            if let error = error {
                print("Unable to get port status: connection failed (\(error.localizedDescription))")
                self?.callBackWithStatus(.error)
            } else if let data = data {
                guard let probeString = String(data: data, encoding: .utf8) else {
                    print("Unable to get port status: invalid data received")
                    self?.callBackWithStatus(.error)
                    return
                }

                switch probeString {
                case "1":
                    self?.callBackWithStatus(.open)
                case "0":
                    self?.callBackWithStatus(.closed)
                default:
                    print("Unable to get port status: invalid response (\(probeString))")
                    self?.callBackWithStatus(.error)
                }
            } else {
                print("Unable to get port status: unknown error")
                self?.callBackWithStatus(.error)
            }
        }

        task.resume()
        self.task = task
    }

    @objc func cancelProbe() {
        task?.cancel()
    }

    fileprivate func callBackWithStatus(_ status: PortStatus) {
        self.status = status
        DispatchQueue.main.async {
            self.delegate?.portCheckerDidFinishProbing?(self)
        }
    }
}

