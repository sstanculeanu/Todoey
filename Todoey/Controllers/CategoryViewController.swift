//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sorin Stanculeanu on 30/12/2017.
//  Copyright © 2017 Sorin Stanculeanu. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    
    var categoryArray = [Category]()
    
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
            
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //?? is the nil coalescing operator si in cazul in care categoryarray este null intotace 1, daca nu este null, e ok
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        
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
