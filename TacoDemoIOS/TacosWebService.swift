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

    func getTacos(moc: NSManagedObjectContext, completion: @escaping (_ result: Array<Taco>) -> Void) {

		let req = URLRequest(url: URL(string: "https://tacodemo.herokuapp.com/tacos.json")!)
        let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
			if (error != nil) {
                completion(Array())
			} else {
                DispatchQueue.global(qos: .background).async {
                    let child_moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
					child_moc.parent = moc
                    let results = self.parseTacosFromData(data: data!, moc: moc)
                    do {
                        try child_moc.save()
                        DispatchQueue.main.async {
                            completion(results)
                        }
                    } catch _ {
                        DispatchQueue.main.async {
                            completion(Array())
                        }
                    }
					
				}

			}
		});

		task.resume()
	}

    func destroyTaco(taco: Taco, completion: @escaping (_ error: Error?) -> Void) {
		if let tacoId = taco.remoteId {
            var req = URLRequest(url: URL(string: "https://tacodemo.herokuapp.com/tacos/\(tacoId.stringValue).json")!)
			req.httpMethod = "DELETE"
			req.allHTTPHeaderFields!["Content-Type"] = "application/json"
            let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
				if let err = error {
                    completion(err)
				} else {
                    completion(nil)
				}
			});

			task.resume()
		}
	}

    func createTaco(taco: Taco, moc: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) {
        var req = URLRequest(url: URL(string: "https://tacodemo.herokuapp.com/tacos.json")!)
		req.httpMethod = "POST"
		let payload = ["taco": taco.dictionaryRepresentation()]
		print("payload: \(payload)")
		do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
		} catch _ {
			return
		}
		req.allHTTPHeaderFields!["Content-Type"] = "application/json"
        let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
			do {
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
				print("response: \(jsonDict)")
                taco.updateWithDictionary(json: jsonDict)
				try moc.save()

			} catch _ {

			}

			if let err = error {
                completion(err)
			} else {
                completion(nil)
			}
		});

		task.resume()
	}

    func updateTaco(taco: Taco, completion: @escaping (_ error: Error?) -> Void) {
        var req = URLRequest(url: URL(string: "https://tacodemo.herokuapp.com/tacos.json")!)
		req.httpMethod = "PUT"
		let payload = ["taco": taco.dictionaryRepresentation()]
		print("payload: \(payload)")
		do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
		} catch _ {
			return
		}
		req.allHTTPHeaderFields!["Content-Type"] = "application/json"
        let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
            completion((error)!)
		});

		task.resume()
	}
	
	func parseTacosFromData(data: Data, moc: NSManagedObjectContext) -> Array<Taco> {

		var resultingTacos = Array<Taco> ()
		do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: AnyObject]]
			
			for tacoDict in jsonArray {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
				// Edit the entity name as appropriate.
                let entity = NSEntityDescription.entity(forEntityName: "Taco", in: moc)
				fetchRequest.entity = entity
				fetchRequest.predicate = NSPredicate.init(format: "remoteId = %@", argumentArray: [tacoDict["id"]!])
                let results = try! moc.fetch(fetchRequest)
				if results.count > 0 {
					let existingTaco = results.first as! Taco
                    existingTaco.updateWithDictionary(json: tacoDict)
					resultingTacos.append(existingTaco)
				} else {
                    let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Taco", into: moc) as! Taco
                    newManagedObject.updateWithDictionary(json: tacoDict)
					resultingTacos.append(newManagedObject)
				}

			}

		} catch let error {
			print("JSON Serialization failed. Error: \(error)")
		}

		return resultingTacos
	}
}
