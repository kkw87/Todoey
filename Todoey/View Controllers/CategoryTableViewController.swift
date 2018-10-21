//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/18/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    //MARK: - Constants
    struct Storyboard {
        static let ItemSegueID = "goToItem"
        static let CellID = "categoryCell"
    }
    
    struct Constants {
        
    }
    
    struct CoreDataConstants {
        static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    //MARK: - Instance Variables
    private var currentCategories : [Category] = []

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
                
                let newCategory = Category(context: CoreDataConstants.context)
                newCategory.name = categoryName
                
                self.saveCategory()
                self.currentCategories.append(newCategory)
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
        return currentCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellID, for: indexPath)

        let categoryAtIndexPath = currentCategories[indexPath.row]
        
        cell.textLabel?.text = categoryAtIndexPath.name
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let currentIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentCategory = currentCategories[currentIndexPath.row]
        
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
    
    // MARK: - Core Data loading functions
    
    private func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let savedCategories = try CoreDataConstants.context.fetch(request)
            currentCategories = savedCategories
            tableView.reloadData()
            
        } catch {
            print("Error loading itmes : \(error.localizedDescription)")
        }
        
    }
    
    private func saveCategory() {
        
        do {
            try CoreDataConstants.context.save()
        } catch {
            print("Error saving items : \(error.localizedDescription)")
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
            
            let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            loadCategories(with: fetchRequest)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadCategories()
            searchBar.resignFirstResponder()
        }
    }

}
