//
//  FileListCell.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import Foundation

@objc
class FileListCell: UITableViewCell {

    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var checkbox: CheckboxControl!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setColors(selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setColors(highlighted)
    }

    private func setColors(_ highlighted: Bool) {
        if highlighted {
            filenameLabel.textColor = .white
            progressLabel.textColor = .white
            sizeLabel.textColor = .white
        } else {
            filenameLabel.textColor = .black
            progressLabel.textColor = UIColor(named: "progress-selected")
            sizeLabel.textColor = UIColor(named: "progress-selected")
        }
    }

    @objc class func cellFromNib() -> Any! {
        let objects = Bundle.main.loadNibNamed("FileListCell", owner: nil, options: nil)
        return objects!.first!
    }
}
