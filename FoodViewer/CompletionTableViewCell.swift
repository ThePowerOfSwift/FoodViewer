//
//  CompletionTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionTableViewCell: UITableViewCell {

    private struct Constants {
        static let CompletePostText = "% complete"
    }
    var product: FoodProduct? = nil {
        didSet {
            if let percentage = product?.state.completionPercentage() {
                let percentageString = String(format: "%02d", arguments: [percentage])
                completionLabel?.text = "\(percentageString)" + Constants.CompletePostText
            }
        }
    }

    @IBOutlet weak var completionLabel: UILabel!
}
