//
//  TodoListViewController.swift
//  ListOfLists
//
//  Created by Anthony Wong on 2019-06-14.
//  Copyright © 2019 Anthony Wong. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selecedCateogry: Category? {
        didSet {
             loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selecedCateogry?.name
        
        guard let colorHex = selecedCateogry?.color else {
            fatalError()
        }
        updateNavbar(withHexColor: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavbar(withHexColor: "5654E8")
    }
    
    // MARK: - Navbar Setup
    func updateNavbar(withHexColor hexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("NO NAVBAR")
        }
        
        guard let navbarColor = UIColor(hexString: hexCode) else {
            fatalError()
        }
        
        searchBar.barTintColor = navbarColor
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navbarColor, returnFlat: true)]
        navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
        navBar.barTintColor = navbarColor
    }
    

    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selecedCateogry!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error checking off item: \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - ADD BUTTON
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new checklist item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What happens when user taps add button on UI Alert

            if let currentCategory = self.selecedCateogry {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        
                        if let newText = textField.text {
                            newItem.title = newText
                        }
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Model Manipulation methods
    func loadItems() {
        todoItems = selecedCateogry?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
    // MARK: - Delete data from swipe.
    override func updateModel(at indexPath: IndexPath) {
        if let todoDelete = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(todoDelete)
                }
            } catch {
                print("Error deleting category\(error)")
            }
        }
        tableView.reloadData()
    }
    
}


// MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
