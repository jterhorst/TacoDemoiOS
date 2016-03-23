//
//  Taco.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//

import Foundation
import CoreData


class Taco: NSManagedObject {

	func updateWithDictionary(json: Dictionary<String, AnyObject>) {
		if let newId = json["id"] as? NSNumber {
			self.remoteId = newId
		}
		if let newName = json["name"] as? String {
			self.name = newName
		}
		if let newMeat = json["meat"] as? String {
			self.meat = newMeat
		}
		if let newLayers = json["layers"] as? NSNumber {
			self.layers = newLayers
		}
		if let newCalories = json["calories"] as? NSNumber {
			self.calories = newCalories
		}
		if let newCheese = json["has_cheese"] as? NSNumber {
			self.hasCheese = newCheese
		}
		if let newLettuce = json["has_lettuce"] as? NSNumber {
			self.hasLettuce = newLettuce
		}
		if let newDetails = json["details"] as? String {
			self.details = newDetails
		}
	}

}