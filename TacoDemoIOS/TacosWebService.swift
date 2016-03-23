//
//  TacosWebService.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//

import Foundation
import CoreData

class TacosWebService {

	func getTacos(moc: NSManagedObjectContext, completion: (result: Array<Taco>) -> Void) {

		let req = NSURLRequest(URL: NSURL(string: "http://tacodemo.herokuapp.com/tacos.json")!)
		let session = NSURLSession.sharedSession()//(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.dataTaskWithRequest(req, completionHandler: {(data, response, error) in
			if (error != nil) {
				completion(result: Array())
			} else {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
					let child_moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
					child_moc.parentContext = moc
					let results = self.parseTacosFromData(data!, moc: moc)
					dispatch_async(dispatch_get_main_queue()) {
						completion(result: results)
					}
				}

			}
		});

		task.resume()
	}

	func parseTacosFromData(data: NSData, moc: NSManagedObjectContext) -> Array<Taco> {

		var resultingTacos = Array<Taco> ()
		do {
			let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [[String: AnyObject]]
			
			for tacoDict in jsonArray {
				let fetchRequest = NSFetchRequest()
				// Edit the entity name as appropriate.
				let entity = NSEntityDescription.entityForName("Taco", inManagedObjectContext: moc)
				fetchRequest.entity = entity
				fetchRequest.predicate = NSPredicate.init(format: "remoteId = %@", argumentArray: [tacoDict["id"]!])
				let results = try! moc.executeFetchRequest(fetchRequest)
				if results.count > 0 {
					let existingTaco = results.first as! Taco
					existingTaco.updateWithDictionary(tacoDict)
					resultingTacos.append(existingTaco)
				} else {
					let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Taco", inManagedObjectContext: moc) as! Taco
					newManagedObject.updateWithDictionary(tacoDict)
					resultingTacos.append(newManagedObject)
				}

			}

		} catch let error {
			print("JSON Serialization failed. Error: \(error)")
		}

		return resultingTacos
	}
}