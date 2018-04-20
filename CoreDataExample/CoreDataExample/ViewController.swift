//
//  ViewController.swift
//  CoreDataExample
//
//  Created by Douglas Alexander on 4/20/18.
//  Copyright © 2018 Douglas Alexander. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // decalre a variable to store a reference to managed object context
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCoreStack()
    }

    func initCoreStack() {
        // initialize persistent container
        let container = NSPersistentContainer(name: "CoreDataExample")
        
        // access the managed object context
        container.loadPersistentStores(completionHandler: {(description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            } else {
                self.managedObjectContext = container.viewContext
            }
        })
    }
    
    @IBAction func saveContact(_ sender: Any) {
        
        // use the managed object content to get the Contacts entity decription
        if let context = managedObjectContext, let entityDescription = NSEntityDescription.entity(forEntityName: "Contacts", in: context) {
            
            // create a contact managed object
            let contact = Contacts(entity: entityDescription, insertInto: managedObjectContext)
            
            // set the contact values to theuser entered values
            contact.name = name.text
            contact.address = address.text
            contact.phone = phone.text
            
            // attempt to save the contact info and report status
            do {
                try managedObjectContext?.save()
                name.text = ""
                address.text = ""
                phone.text = ""
                status.text = "Contact Saved!"
            } catch let error {
                status.text = error.localizedDescription
            }
        }
    }
    
    @IBAction func findContact(_ sender: Any) {
        // use the managed object content to get the Contacts entity decription
        if let context = managedObjectContext, let entityDescription = NSEntityDescription.entity(forEntityName: "Contacts", in: context) {
            
            // create a request for the Contacts
            let request: NSFetchRequest<Contacts> = Contacts.fetchRequest()
            request.entity = entityDescription
            
            // crate and populate the search predicate
            if let name = name.text {
                let pred = NSPredicate(format: "(name = %@)", name)
                request.predicate = pred
            }
            
            // perform the search and report the status
            do {
                var results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
                
                if results.count > 0 {
                    let match = results[0] as! NSManagedObject
                    
                    name.text = match.value(forKey: "name") as? String
                    address.text = match.value(forKey: "address") as? String
                    phone.text = match.value(forKey: "phone") as? String
                    status.text = "Matches found: \(results.count)"
                } else {
                    status.text = "No Match"
                }
            } catch let error {
                status.text = error.localizedDescription
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

