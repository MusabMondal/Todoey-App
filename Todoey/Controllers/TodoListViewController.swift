//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.y
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var itemArray : Results<Item>?
    
    var selectedCategory: CategoryItem? {
        //only execute when selectedCategory is set
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
        searchBar.delegate = self
        
//        loadItems()
        
//        title = "Items"
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()        // solid background
//        appearance.backgroundColor = .systemBlue
//        appearance.titleTextAttributes = [
//            .foregroundColor: UIColor.white
//        ]
//        appearance.largeTitleTextAttributes = [
//            .foregroundColor: UIColor.white
//        ]
//        
//        // Apply to this navigation controller
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
//        
//        // Optional: tint color for bar button items
//        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let color = selectedCategory?.colorHex{
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else{fatalError("NavigationController does not exist")}
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()        // solid background
            appearance.backgroundColor = UIColor(hex: color)
        
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            
            searchBar.barTintColor = UIColor(hex: color)
            
        }
    }
    
    //MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        guard let item = itemArray?[indexPath.row] else {
            cell.textLabel?.text = "No Items Added"
            cell.backgroundColor = .systemBackground
            cell.accessoryType = .none
            return cell
        }

        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none

        // Background color based on category hex + row index
        if let hex = selectedCategory?.colorHex,
           let count = itemArray?.count,
           let colour = UIColor(
                hex: hex,
                alpha: max(0.2, min(1.0 - (CGFloat(indexPath.row) / CGFloat(count)), 1.0))
           ) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = colour.contrastTextColor()
        } else {
            cell.backgroundColor = .systemBackground
        }

        return cell
    }

    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRow = itemArray?[indexPath.row]{
            do {
                try realm.write {
                    /*realm.delete(selectedRow)*/
                    selectedRow.done = !selectedRow.done
                }
            }catch {
                print("error updating done status")
            }
        }
        tableView.reloadData()

//        Deleting from core data
//        context.delete(selectedRow)
//        itemArray.remove(at: indexPath.row)
        
        //CorDate Implementation
//        selectedRow.done = !selectedRow.done
//        
//        saveItems()
        
        //        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        //        } else {
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //CoreDate Implentation
//            let newItem = Item(context: self.context)
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        }
                    }catch{
                        print("Error saving new Item, \(error)")
                }
                
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
//    func saveItems(with item: Item){
//        
//        do {
////            try context.save()
//            try realm.write {
//                realm.add(item)
//            }
//        } catch{
//            print("error saving into realm, \(error)")
//        }
//        
//        self.tableView.reloadData()
//    }
    
   //CoreDate Implemntation
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//        
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
//        }else {
//            request.predicate = categoryPredicate
//        }
//        
//        
//        do{
//            itemArray = try context.fetch(request)
//        } catch {
//            print("error fetching data from context, \(error)")
//        }
//        
//        tableView.reloadData()
//    }
    
    func loadItems(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch{
                print("error deleting item, \(error)")
            }
        }
    }
    
}

//MARK: - SearchBar Delegate Methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        //CoreData Implementation
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        
//        request.sortDescriptors = [sortDescriptor]
//        
//        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

