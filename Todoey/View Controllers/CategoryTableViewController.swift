//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/18/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: SwipeTableViewController {
    
    //MARK: - Constants
    struct Storyboard {
        static let ItemSegueID = "goToItem"
    }

    
    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    //MARK: - Instance Variables
    private var currentCategories : Results<Category>?
    private var realmDatabase = try! Realm()

    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
   
    }
    
    //MARK: - Outlet actions

    @IBAction func addNewCategory(_ sender: Any) {
        //Add new category
        
        let newCategoryCreationAlertVC = UIAlertController(title: "What's the name of the category?", message: nil, preferredStyle: .alert)
        newCategoryCreationAlertVC.addTextField { (textfield) in
            textfield.placeholder = "Category name"
            textfield.delegate = self
        }
        
        newCategoryCreationAlertVC.addAction(UIAlertAction(title: "Done", style: .default, handler: { (alert) in
            guard let currentTextField = newCategoryCreationAlertVC.textFields?.first else {
                return
            }
            
            if let categoryName = currentTextField.text, categoryName.count > 0 {
                
                
                let newCategory = Category()
                newCategory.name = categoryName
                
                self.saveToRealm(objectToSave: newCategory)
                self.tableView.reloadData()
                
            } else {
                currentTextField.backgroundColor = UIColor.red.withAlphaComponent(0.1)
                return
            }
        }))
        
        newCategoryCreationAlertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(newCategoryCreationAlertVC, animated: true, completion: nil)
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentCategories?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let categoryAtIndexPath = currentCategories?[indexPath.row]
        
        cell.textLabel?.text = categoryAtIndexPath?.name ?? "No Categories"
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let currentIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentCategory = currentCategories?[currentIndexPath.row]
        
        let segueIdentifier = segue.identifier
        
        switch segueIdentifier {
        case Storyboard.ItemSegueID :
            if let todovc = segue.destination as? ToDoListTableViewController {
                todovc.currentCategory = currentCategory
            }
        default :
            break
        }
    }
    
    // MARK: - Data manipulation functions
    
    private func loadCategories() {
        
        currentCategories = realmDatabase.objects(Category.self)
 
        tableView.reloadData()
    }
    
    private func saveToRealm(objectToSave : Object) {
        
        do {
            try realmDatabase.write {
                realmDatabase.add(objectToSave)
            }
        } catch {
            print("Error saving items : \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath : IndexPath) {
                    if let currentItem = currentCategories?[indexPath.row] {
        
                        try! self.realmDatabase.write {
                            self.realmDatabase.delete(currentItem)
                        }
        
                    }
    }

}

//MARK: - Text field delegates
extension CategoryTableViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
}

//MARK: - Search bar delegates 
extension CategoryTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchText = searchBar.text else {
            return
        }
        
        if searchText.count > 0 {
            
            currentCategories = realmDatabase.objects(Category.self).filter("name CONTAINS[cd] %@", searchText)
            self.tableView.reloadData()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadCategories()
            searchBar.resignFirstResponder()
        }
    }

}
