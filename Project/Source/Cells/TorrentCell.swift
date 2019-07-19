//
//  TorrentCell.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 19.07.2019.
//

import UIKit

@objc
class TorrentCell: _TorrentCell {
    override class func cellFromNib() -> Any! {
        let objects = Bundle.main.loadNibNamed("TorrentCell", owner: nil, options: nil)
        return objects!.first!
    }

    override func useGreenColor() {
        progressView.tintColor = UIColor(named: "progress-green")
    }

    override func useBlueColor() {
        progressView.tintColor = UIColor(named: "progress-blue")
    }

    override func pausedPressed(_ sender: Any!) {

    }

    func setProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
        setNeedsDisplay()
    }
}
