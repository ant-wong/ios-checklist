//
//  TodoListViewController.swift
//  ListOfLists
//
//  Created by Anthony Wong on 2019-06-14.
//  Copyright © 2019 Anthony Wong. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var checklistItems = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        loadItems()
        
    }
    

    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklistItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = checklistItems[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checklistItems[indexPath.row].done = !checklistItems[indexPath.row].done
        
        context.delete(checklistItems[indexPath.row])
        checklistItems.remove(at: indexPath.row)
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - ADD BUTTON
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new checklist item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What happens when user taps add button on UI Alert
            let newItem = Item(context: self.context)
            
            if let newText = textField.text {
                newItem.title = newText
            }
            
            newItem.done = false
            
            self.checklistItems.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Model Manipulation methods
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    func loadItems() {
        let request: NSFetchRequest = Item.fetchRequest()
        do {
            checklistItems = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
}

