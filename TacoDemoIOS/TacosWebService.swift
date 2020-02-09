//
//  TacosWebService.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//

import Foundation
import CoreData

// IMPORTANT: Create Endpoint.plist in your project, and define a string "url" at the root of the plist with your Firebase Realtime Database URL
// e.g., "https://tacodemo-12345.firebaseio.com" (no trailing slash)
// Don't commit this file in Git.
// Make sure read/writes are set to true in the Rules tab in Firebase. Auth isn't covered by this demo.

class TacosWebService {

    func endpointUrl() -> String {
        var format = PropertyListSerialization.PropertyListFormat.xml
        let url = Bundle.main.path(forResource: "Endpoint", ofType: "plist")
        var plistData: [String: AnyObject] = [:]
        do {
            plistData = try PropertyListSerialization.propertyList(from: FileManager.default.contents(atPath: url!)!, options: .mutableContainersAndLeaves, format: &format) as! [String: AnyObject]
        } catch {
            print("See instructions in code. Plist file is required. You need to set up Firebase.")
        }
        return plistData["url"] as! String
    }
    
    func getTacos(moc: NSManagedObjectContext, completion: @escaping (_ result: Array<Taco>) -> Void) {

		let req = URLRequest(url: URL(string: "\(endpointUrl())/tacos.json")!)
        let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
			if (error != nil) {
                completion(Array())
			} else {
                DispatchQueue.global(qos: .background).async {
                    let child_moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
					child_moc.parent = moc

                    let results = self.parseTacosFromData(data: data, moc: moc)
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
            var req = URLRequest(url: URL(string: "\(endpointUrl())/tacos/\(tacoId).json")!)
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
        var req = URLRequest(url: URL(string: "\(endpointUrl())/tacos.json")!)
		req.httpMethod = "POST"
		let payload = taco.dictionaryRepresentation()
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
                if let tacoRemoteId = jsonDict["name"] as? String {
                    taco.remoteId = tacoRemoteId
                }
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
        if let tacoId = taco.remoteId {
            var req = URLRequest(url: URL(string: "\(endpointUrl())/tacos/\(tacoId).json")!)
            req.httpMethod = "PUT"
            let payload = taco.dictionaryRepresentation()
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            } catch _ {
                return
            }
            req.allHTTPHeaderFields!["Content-Type"] = "application/json"
            let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) in
                if (error == nil) {
                    try! taco.managedObjectContext?.save()
                }
                completion(error)
            });

            task.resume()
        }
        
	}
	
    // MARK: - parsing
    
	private func parseTacosFromData(data: Data?, moc: NSManagedObjectContext) -> Array<Taco> {
		var resultingTacos = Array<Taco> ()
        if let tacoData = data {
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: tacoData, options: []) as? [String:AnyObject]
                
                if let keyedTacoItems = jsonArray {
                    for tacoId in keyedTacoItems.keys {
                        if let tacoPayload = keyedTacoItems[tacoId] as? [String:AnyObject] {
                            if let tacoResult = parseTacoFromPayload(payload: tacoPayload, tacoId: tacoId, moc: moc) {
                                resultingTacos.append(tacoResult)
                            }
                        }
                    }
                }
            } catch let error {
                print("JSON Serialization failed. Error: \(error)")
            }
        }
		return resultingTacos
	}
    
    private func parseTacoFromPayload(payload: [String:AnyObject], tacoId:String, moc: NSManagedObjectContext) -> Taco? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Taco", in: moc)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate.init(format: "remoteId = %@", argumentArray: [tacoId])
        let results = try! moc.fetch(fetchRequest)
        let resultingTaco: Taco?
        
        if results.count > 0 {
            resultingTaco = results.first as? Taco
            resultingTaco?.updateWithDictionary(json: payload)
        } else {
            resultingTaco = NSEntityDescription.insertNewObject(forEntityName: "Taco", into: moc) as? Taco
            resultingTaco?.remoteId = tacoId
            resultingTaco?.updateWithDictionary(json: payload)
        }
        
        return resultingTaco
    }
}
