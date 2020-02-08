//
//  DetailViewController.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var caloriesValueLabel: UILabel!
	@IBOutlet weak var detailsValueLabel: UILabel!
	@IBOutlet weak var hasCheeseValueLabel: UILabel!
	@IBOutlet weak var hasLettuceValueLabel: UILabel!
	@IBOutlet weak var layersValueLabel: UILabel!
	@IBOutlet weak var meatValueLabel: UILabel!

    var detailItem: Taco? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
			if let caloriesLabel = self.caloriesValueLabel {
				caloriesLabel.text = detail.calories?.stringValue
			}
			if let detailsLabel = self.detailsValueLabel {
				detailsLabel.text = detail.details
			}
			if let hasCheeseLabel = self.hasCheeseValueLabel {
				if detail.hasCheese?.boolValue == true {
					hasCheeseLabel.text = "Yes"
				} else {
					hasCheeseLabel.text = "No"
				}
			}
			if let hasLettuceLabel = self.hasLettuceValueLabel {
				if detail.hasLettuce?.boolValue == true {
					hasLettuceLabel.text = "Yes"
				} else {
					hasLettuceLabel.text = "No"
				}
			}
			if let layersLabel = self.layersValueLabel {
				layersLabel.text = detail.layers?.stringValue
			}
			if let meatLabel = self.meatValueLabel {
				meatLabel.text = detail.meat
			}
            self.title = detail.value(forKey: "name") as? String;
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

