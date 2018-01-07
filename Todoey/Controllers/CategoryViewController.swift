//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sorin Stanculeanu on 30/12/2017.
//  Copyright © 2017 Sorin Stanculeanu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen oance the user press additem button on uialert
            
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row]
        {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }
            catch
            {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //?? is the nil coalescing operator si in cazul in care categoryarray este null intotace 1, daca nu este null, e ok
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{
            
            cell.textLabel?.text = category.name
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category)
    {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch
        {
            print("Error context saving, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories()
    {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destionationVC = segue.destination as! ToDolistViewController
        
        if let indexPath = tableView.indexPathForSelectedRow
        {
            destionationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
