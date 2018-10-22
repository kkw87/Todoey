//
//  ToDoListTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/16/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListTableViewController: UITableViewController {
    
    //MARK: - Constants
    struct Storyboard {
        static let CellReuseID = "ToDoItemCell"
    }
    
    struct Constants {
        static let ListArrayKey = "ToDoList.plist"
        
    }
//
//    struct CoreDataConstants {
//        static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
//
    //MARK: - Instance variables
    private var itemArray : Results<ToDoItem>?
    
    var currentCategory : Category? {
        didSet {
            navigationItem.title = currentCategory!.name
            loadItems(withPredicate: nil)
        }
    }
    
    private let realmDatabase = try! Realm()
    
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
                
                
                let newItem = ToDoItem()
                newItem.activityName = itemName
                newItem.completed = false
                self.saveToRealm(objectToSave: newItem)
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
        return itemArray?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseID, for: indexPath)
        
        let toDoItemAtLocation = itemArray?[indexPath.row]
        
        cell.textLabel?.text = toDoItemAtLocation?.activityName ?? "Add activities"
        
        
        if toDoItemAtLocation != nil {
        cell.accessoryType = toDoItemAtLocation!.completed ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let toDoItemAtLocation = itemArray?[indexPath.row] {
            
        try! realmDatabase.write {
            toDoItemAtLocation.completed = !toDoItemAtLocation.completed
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if itemArray != nil {
            return true
        } else {
            return false
        }

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            try! realmDatabase.write {
                realmDatabase.delete(itemArray![indexPath.row])

            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
    
    private func saveToRealm(objectToSave : ToDoItem) {
        
        do {
            try realmDatabase.write {
                realmDatabase.add(objectToSave)
                currentCategory!.items.append(objectToSave)
            }
        } catch {
            print("Error data locally : \(error.localizedDescription)")
        }
        
    }
    
    private func loadItems(withPredicate predicate : NSPredicate?) {

        if let userPredicate = predicate {
            itemArray = currentCategory?.items.sorted(byKeyPath: "activityName", ascending: true).filter(userPredicate)

        } else {
            itemArray = currentCategory?.items.sorted(byKeyPath: "activityName", ascending: true)

        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Delegates
extension ToDoListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        
       loadItems(withPredicate: NSPredicate(format: "activityName CONTAINS[cd] %@", searchText))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {

            loadItems(withPredicate: nil)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
