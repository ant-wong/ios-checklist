//
//  CategoryViewController.swift
//  ListOfLists
//
//  Created by Anthony Wong on 2019-06-15.
//  Copyright © 2019 Anthony Wong. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoriesList: Results<Category>?
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Categories.plist")
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }
    
    
    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoriesList?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.accessoryType = .disclosureIndicator
            
            guard let categoryColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            cell.backgroundColor = categoryColor
        }
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selecedCateogry = categoriesList?[indexPath.row]
        }
    }
    
    
    // MARK: - Data manipulation methods
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    func loadCategories() {
        categoriesList = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete data from swipe.
    override func updateModel(at indexPath: IndexPath) {
        if let categoryDelete = self.categoriesList?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryDelete)
                }
            } catch {
                print("Error deleting category\(error)")
            }
        }
        tableView.reloadData()
    }


    // MARK: - Handle Add Button
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            
            if let newText = textField.text {
                newCategory.name = newText
            }
            
            newCategory.color = UIColor.randomFlat.hexValue()
 
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
