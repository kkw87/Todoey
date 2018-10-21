//
//  ToDoListTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/16/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController {
    
    //MARK: - Constants
    struct Storyboard {
        static let CellReuseID = "ToDoItemCell"
    }
    
    struct Constants {
        static let ListArrayKey = "ToDoList.plist"
        
    }
    
    struct CoreDataConstants {
        static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    //MARK: - Instance variables
    private var itemArray : [ToDoItem] = []
    var currentCategory : Category? {
        didSet {
            navigationItem.title = currentCategory!.name
            loadItems()
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Outlet Actions
    
    @IBAction func addActivity(_ sender: Any) {
        let addItemAlertController = UIAlertController(title: "Add Activity", message: "", preferredStyle: .alert)
        
        addItemAlertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }
        addItemAlertController.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            
            if let itemName = addItemAlertController.textFields?.first?.text {
                
                let newItem = ToDoItem(context: CoreDataConstants.context)
                newItem.activityName = itemName
                newItem.completed = false
                newItem.category = self.currentCategory!
                self.itemArray.append(newItem)
                self.saveItems()
                self.tableView.reloadData()
            }
            
        }))
        addItemAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(addItemAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseID, for: indexPath)
        
        let toDoItemAtLocation = itemArray[indexPath.row]
        
        cell.textLabel?.text = toDoItemAtLocation.activityName
        
        cell.accessoryType = toDoItemAtLocation.completed ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let toDoItemAtLocation = itemArray[indexPath.row]
        
        toDoItemAtLocation.completed = !toDoItemAtLocation.completed
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataConstants.context.delete(itemArray[indexPath.row])
            _ = itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveItems()
        }
    }
    
    // MARK: - Navigation
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func saveItems() {
        
        do {
            try CoreDataConstants.context.save()
        } catch {
            print("Error data locally : \(error.localizedDescription)")
        }
        
    }
    
    private func loadItems(with request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), withPredicate predicate : NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "category == %@", currentCategory!)
        
        if let userPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, userPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            itemArray = try CoreDataConstants.context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetchign data : \(error)")
        }
    }
}

//MARK: - Search Bar Delegates
extension ToDoListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        let fetchRequest : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "activityName", ascending: true)]
                
       loadItems(withPredicate: NSPredicate(format: "activityName CONTAINS[cd] %@", searchText))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {

            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
