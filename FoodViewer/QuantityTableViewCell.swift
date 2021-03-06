//
//  QuantityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class QuantityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.layer.borderWidth = 0.5
            textField.clearButtonMode = .whileEditing
            textField.delegate = delegate
            textField.tag = tag
            setTextFieldStyle()
        }
    }
    
    var tekst: String? = nil {
        didSet {
            textField.text = tekst
        }
    }
    
    var editMode: Bool = false {
        didSet {
            setTextFieldStyle()
        }
    }
    
    var delegate: IdentificationTableViewController? = nil {
        didSet {
            textField?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            textField?.tag = tag
        }
    }
    
    private func setTextFieldStyle() {
        if editMode {
            textField.backgroundColor = UIColor.groupTableViewBackground
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            textField.clipsToBounds = true
            
        } else {
            textField.borderStyle = .roundedRect
            textField.backgroundColor = UIColor.white
            textField.layer.borderColor = UIColor.white.cgColor
        }
    }
    
}

