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
    @objc private (set) var status: PortStatus
    @objc private (set) var portNumber: Int

    private weak var delegate: PortCheckerDelegate?
    private var task: URLSessionDataTask?

    @objc init(port: Int, delay: Bool, delegate: PortCheckerDelegate) {
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

    private func startProbe() {
        let url = URL(string: "http://portcheck.transmissionbt.com/\(portNumber)")!
        let portProbeRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)

        let task = URLSession.shared.dataTask(with: portProbeRequest) { [weak self] (data, response, error) in
            self?.onProbeRequsetComplete(data, response, error)
        }

        task.resume()
        self.task = task
    }

    @objc func cancelProbe() {
        task?.cancel()
        task = nil
    }

    private func onProbeRequsetComplete(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        task = nil
        if let error = error {
            print("Unable to get port status: connection failed (\(error.localizedDescription))")
            callBackWithStatus(.error)
        } else if let data = data {
            guard let probeString = String(data: data, encoding: .utf8) else {
                print("Unable to get port status: invalid data received")
                callBackWithStatus(.error)
                return
            }

            switch probeString {
            case "1":
                callBackWithStatus(.open)
            case "0":
                callBackWithStatus(.closed)
            default:
                print("Unable to get port status: invalid response (\(probeString))")
                callBackWithStatus(.error)
            }
        } else {
            print("Unable to get port status: unknown error")
            callBackWithStatus(.error)
        }
    }

    private func callBackWithStatus(_ status: PortStatus) {
        self.status = status
        DispatchQueue.main.async {
            self.delegate?.portCheckerDidFinishProbing?(self)
        }
    }
}

