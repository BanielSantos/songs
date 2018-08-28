/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment
 Author: Duong Huu Khang
 ID: s3635116
 Created date: 15/08/2018
 Acknowledgement:
 https://developer.apple.com/
 https://stackoverflow.com/questions/37206638/disable-button-in-uialertview-while-text-field-is-empty
 */

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext = PersistenceService.context //NSManagedObjectContext? = nil
    var editIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // insert a song through an alert
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        
        let alert = UIAlertController(title: "Add song", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Artist"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Year"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { (textField) in
            textField.placeholder = "URL"
        }

        let action1 = UIAlertAction(title: "OK", style: .default) { (_) in
            // create a song object
            let title = alert.textFields![0].text!
            let artist = alert.textFields![1].text!
            let year = alert.textFields![2].text!
            let url = alert.textFields![3].text!

            let song = Song(context: context)
            song.title = title
            song.artist = artist
            if(Int16(year) == nil){
                song.year = -1
            } else {
                song.year = Int16(year)!
            }
            song.url = url
            // default image
            song.image = UIImagePNGRepresentation(#imageLiteral(resourceName: "music"))
            
            // Save the context.
            PersistenceService.saveContext()
        }
        // The OK button is only enabled if title, artist and year fields are filled
        action1.isEnabled = false
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let title = alert.textFields![0].text!
            let artist = alert.textFields![1].text!
            let year = alert.textFields![2].text!
            if title != "" && artist != "" && year != "" {
                action1.isEnabled = true
            } else {
                action1.isEnabled = false
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object:alert.textFields?[1], queue: OperationQueue.main) { (notification) -> Void in
            let title = alert.textFields![0].text!
            let artist = alert.textFields![1].text!
            let year = alert.textFields![2].text!
            if title != "" && artist != "" && year != "" {
                action1.isEnabled = true
            } else {
                action1.isEnabled = false
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object:alert.textFields?[2], queue: OperationQueue.main) { (notification) -> Void in
            let title = alert.textFields![0].text!
            let artist = alert.textFields![1].text!
            let year = alert.textFields![2].text!
            if title != "" && artist != "" && year != "" {
                action1.isEnabled = true
            } else {
                action1.isEnabled = false
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object:alert.textFields?[3], queue: OperationQueue.main) { (notification) -> Void in
            let title = alert.textFields![0].text!
            let artist = alert.textFields![1].text!
            let year = alert.textFields![2].text!
            if title != "" && artist != "" && year != "" {
                action1.isEnabled = true
            } else {
                action1.isEnabled = false
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send the song object to the respective segue
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! DetailViewController
                controller.detailItem = object
            }
        }
        
        if segue.identifier == "edit" {
            let object = self.fetchedResultsController.object(at: editIndexPath)
            let controller = segue.destination as! EditViewController
            controller.editItem = object
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let song = self.fetchedResultsController.object(at: indexPath)
        configureCell(cell, withSong: song)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            PersistenceService.saveContext()
        }
    }
    
    // show edit and delete button when swipe left at a cell
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            PersistenceService.saveContext()
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // edit item at indexPath
            self.editIndexPath = indexPath
            self.performSegue(withIdentifier: "edit", sender: nil)
        }
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }

    // show data in cell
    func configureCell(_ cell: UITableViewCell, withSong song: Song) {
        cell.textLabel!.text = song.title
        cell.detailTextLabel!.text = song.artist! + ", " + String(song.year)
        cell.imageView!.image = UIImage(data: song.image!)
    }

    // MARK: - Fetched results controller

     var fetchedResultsController: NSFetchedResultsController<Song> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Song>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withSong: anObject as! Song)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withSong: anObject as! Song)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

