//
//  ToDoListTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/16/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController {
    
    //MARK: - Constants
    struct Storyboard {
        static let CellReuseID = "ToDoItemCell"
    }
    
    struct Constants {
        static let Defaults = UserDefaults.standard
        static let ListArrayKey = "ToDoList Key"
    }
    
    //MARK: - Instance variables
    private var itemArray : [ToDoItem] = []

    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //MARK: - Outlet Actions
    
    @IBAction func addActivity(_ sender: Any) {
        let addItemAlertController = UIAlertController(title: "Add Activity", message: "", preferredStyle: .alert)
        
        addItemAlertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }
        addItemAlertController.addAction(UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            
            if let itemName = addItemAlertController.textFields?.first?.text {
                let newItem = ToDoItem(activityName: itemName)
                self.itemArray.append(newItem)
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

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
