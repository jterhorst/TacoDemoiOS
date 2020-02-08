//
//  MasterViewController.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext = TacosDAO.sharedInstance.managedObjectContext


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(sender:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        let service = TacosWebService()
        service.getTacos(moc: managedObjectContext) {
            (result: Array<Taco>) in
            print("got result: \(result)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func insertNewObject(sender: AnyObject) {
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: managedObjectContext) as! Taco
             
        newManagedObject.name = "Soft Taco"
        newManagedObject.layers = 2
        newManagedObject.meat = "beef"
        newManagedObject.calories = 150
        newManagedObject.details = "A simple soft taco"
        newManagedObject.hasCheese = true
        newManagedObject.hasLettuce = true
             
        // Save the context.
        do {
            try managedObjectContext.save()
            let service = TacosWebService()
            service.createTaco(taco: newManagedObject, moc: managedObjectContext) {
                (error: Error?) in
                if (error != nil) {
                    print("error: \(String(describing: error))")
                }
            };
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath) as! Taco
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        self.configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let service = TacosWebService()
            service.destroyTaco(taco: self.fetchedResultsController.object(at: indexPath) as! Taco) {
                (error: Error?) in
                if (error != nil) {
                    print("error: \(String(describing: error))")
                }
            };
            managedObjectContext.delete(self.fetchedResultsController.object(at: indexPath) as! Taco)
            
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = fetchedResultsController.object(at: indexPath) as? Taco
        cell.textLabel!.text = object?.name
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if _fetchedResultsController == nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            // Edit the entity name as appropriate.
            let entity = NSEntityDescription.entity(forEntityName: "Taco", in: managedObjectContext)
            fetchRequest.entity = entity
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            do {
                try _fetchedResultsController!.performFetch()
            } catch {
                 // Replace this implementation with code to handle the error appropriately.
                 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 //print("Unresolved error \(error), \(error.userInfo)")
                 abort()
            }
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
}

