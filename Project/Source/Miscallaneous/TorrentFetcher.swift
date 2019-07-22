//
//  TorrentFetcher.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import Foundation

@objc protocol TorrentFetcherDelegate: NSObjectProtocol {
    @objc func torrentFetcher(_ fetcher: TorrentFetcher, fetchedTorrentContent data: Data, fromURL url: URL)
    @objc func torrentFetcher(_ fetcher: TorrentFetcher, failedToFetchFromURL url: URL, withError error: Error)
}

@objc class TorrentFetcher: NSObject {
    private weak var delegate: TorrentFetcherDelegate?
    private var url: URL

    @objc init?(urlString: String, delegate: TorrentFetcherDelegate) {
        guard let url = URL(string: urlString) else { return nil }
        self.url = url
        self.delegate = delegate
        super.init()
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, resposne, error) in
            self?.onRequestComplete(data, resposne, error)
        }
        task.resume()
    }

    private func onRequestComplete(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            delegate?.torrentFetcher(self, failedToFetchFromURL: url, withError: error)
        } else if let data = data, let response = response {
            if validateLength(response.expectedContentLength) {
                delegate?.torrentFetcher(self, fetchedTorrentContent: data, fromURL: url)
            } else {
                let error = NSError(domain: "TorrentFetcher", code: 1, userInfo: [NSLocalizedDescriptionKey:"File too large"])
                delegate?.torrentFetcher(self, failedToFetchFromURL: url, withError: error)
            }
        } else {
            let error = NSError(domain: "TorrentFetcher", code: 2, userInfo: [NSLocalizedDescriptionKey:"Unknown error"])
            delegate?.torrentFetcher(self, failedToFetchFromURL: url, withError: error)
        }
    }

    private func validateLength(_ length: Int64) -> Bool {
        if length == kNSURLResponseUnknownLength {
            return true
        }
        if length > kFetchSizeHardLimit {
            return false
        }
        return true
    }
}
