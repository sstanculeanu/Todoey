//
//  ViewController.swift
//  Todoey
//
//  Created by Sorin Stanculeanu on 26/12/2017.
//  Copyright © 2017 Sorin Stanculeanu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDolistViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    
    var toDoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar setup methods
    func updateNavBar(withHexCode colourHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation bar does not exist.")}
        guard let navBarColor = UIColor(hexString: colourHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColor           //the background of navigationBar
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)   //the colour of the navigation elements(ex. back button, add button)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]                       //titles colour(ex. home)
        searchBar.barTintColor = navBarColor        //the background of searchbar
    }

    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row]{
        
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        }
        else{
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = toDoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("Error saving done status, \(error)")
            }
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Delete items
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.toDoItems?[indexPath.row]
        {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }
            catch
            {
                print("Error deleting item, \(error)")
            }
        }
    }
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //to get access to the local variable alertTextField from inside addtextfield outside
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen oance the user press additem button on uialert

            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("Errors saving new item, \(error)")
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
    
    //MARK - Model manipulation methods
    
    func loadItems()
    {

        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - SearchBar methods
extension ToDolistViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            loadItems()
            DispatchQueue.main.async { //foloseste threadul din background pentru a fqace asta
                searchBar.resignFirstResponder()
            }
        }
    }
}

