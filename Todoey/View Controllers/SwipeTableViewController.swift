//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Kevin Wang on 10/25/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    struct Constants {
        static let CellHeight : CGFloat = 80.0
    }
    
    struct Storyboard {
        static let CellID = "swipeCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = Constants.CellHeight
        tableView.separatorStyle = .none
    }
    
    //MARK: - Tableview Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellID, for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
                
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (swipe, indexPath) in
            
            self.updateModel(at: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }

    func updateModel(at indexPath : IndexPath) {
        
    }


}
