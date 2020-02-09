//
//  EditingViewController.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 2/8/20.
//  Copyright © 2020 Jason Terhorst. All rights reserved.
//

import UIKit

class EditingViewController: UIViewController {

    @IBOutlet weak var caloriesValueField: UITextField!
    @IBOutlet weak var detailsValueTextView: UITextView!
    @IBOutlet weak var hasCheeseValueSwitch: UISwitch!
    @IBOutlet weak var hasLettuceValueSwitch: UISwitch!
    @IBOutlet weak var layersValueField: UITextField!
    @IBOutlet weak var meatValueField: UITextField!
    
    var detailItem: Taco? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let caloriesLabel = self.caloriesValueField {
                caloriesLabel.text = detail.calories?.stringValue
            }
            if let detailsLabel = self.detailsValueTextView {
                detailsLabel.text = detail.details
            }
            if let hasCheeseLabel = self.hasCheeseValueSwitch {
                hasCheeseLabel.isOn = detail.hasCheese?.boolValue ?? false
            }
            if let hasLettuceLabel = self.hasLettuceValueSwitch {
                hasLettuceLabel.isOn = detail.hasLettuce?.boolValue ?? false
            }
            if let layersLabel = self.layersValueField {
                layersLabel.text = detail.layers?.stringValue
            }
            if let meatLabel = self.meatValueField {
                meatLabel.text = detail.meat
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    @IBAction func cancelEditing() {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func saveAndCloseEditing() {
        
        if let detail = self.detailItem {
            if let caloriesLabel = self.caloriesValueField {
                detail.calories = (caloriesLabel.text! as NSString).integerValue as NSNumber
            }
            if let detailsLabel = self.detailsValueTextView {
                detail.details = detailsLabel.text
            }
            if let hasCheeseLabel = self.hasCheeseValueSwitch {
                detail.hasCheese = hasCheeseLabel.isOn as NSNumber
            }
            if let hasLettuceLabel = self.hasLettuceValueSwitch {
                detail.hasLettuce = hasLettuceLabel.isOn as NSNumber
            }
            if let layersLabel = self.layersValueField {
                detail.layers = (layersLabel.text! as NSString).integerValue as NSNumber
            }
            if let meatLabel = self.meatValueField {
                detail.meat = meatLabel.text
            }
            
            let service = TacosWebService()
            service.updateTaco(taco: detail) {
                (error: Error?) in
                if (error != nil) {
                    print("error: \(String(describing: error))")
                } else {
                    self.navigationController?.dismiss(animated: true)
                }
            }
        }
        
        
    }

}
