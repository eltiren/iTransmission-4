//
//  FlexibleLabelCell.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 22.07.2019.
//

import UIKit

@objc class FlexibleLabelCell: UITableViewCell {
    @IBOutlet var flexibleLabel: UILabel!

    @objc func resizeToFitText() {
        let constraint = CGSize(width: flexibleLabel.bounds.width, height: .greatestFiniteMagnitude)
        let text = NSAttributedString(string: flexibleLabel.text ?? "", attributes: [.font: flexibleLabel.font!])
        let textRect = text.boundingRect(with: constraint, options: .usesLineFragmentOrigin, context: nil)
        flexibleLabel.bounds = CGRect(origin: .zero, size: textRect.size)
        bounds = CGRect(x: 0, y: 0, width: bounds.width, height: max(textRect.height + 20, 44))
    }
}
