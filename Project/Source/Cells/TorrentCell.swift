//
//  TorrentCell.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 19.07.2019.
//

import UIKit

@objc
class TorrentCell: UITableViewCell {

    @objc static let identifier: String = "TorrentCellIdentifier"

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var upperDetailLabel: UILabel!
    @IBOutlet var lowerDetailLabel: UILabel!
    @IBOutlet var controlButton: ControlButton!

    @objc func useGreenColor() {
        progressView.tintColor = UIColor(named: "progress-green")
    }

    @objc func useBlueColor() {
        progressView.tintColor = UIColor(named: "progress-blue")
    }
}
