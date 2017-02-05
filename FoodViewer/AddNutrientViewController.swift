//
//  AddNutrientViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddNutrientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var addedNutrientTuple: (String, String, NutritionFactUnit)? = nil
    
    var existingNutrients: [String]? = nil
    
    @IBOutlet weak var nutrientsPickerView: UIPickerView!
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return OFFplists.manager.nutrients.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return OFFplists.manager.nutrients[row].1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addedNutrientTuple = OFFplists.manager.nutrients[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Select Nutrient", comment: "Title of view controller, which allows the adding of a nutrient")

        nutrientsPickerView.delegate = self
        nutrientsPickerView.dataSource = self
        nutrientsPickerView.showsSelectionIndicator = true
    }    

}
