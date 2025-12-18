//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Musab Mondal on 2025-12-16.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: SwipeTableViewController{
     
    let realm = try! Realm()
    
    var categoryArray : Results<CategoryItem>?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        title = "Todoey"
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories added yet"
        if let hex = categoryArray?[indexPath.row].colorHex,
           let color = UIColor(hex: hex) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = color.contrastTextColor()
        } else {
            cell.backgroundColor = .systemBlue
        }

        
        return cell
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addCatergoryPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //CoreData implemetation
//            let newCatergoryItem = CategoryItem(context: self.context)
            
            let newCategoryItem = CategoryItem()
            newCategoryItem.name = textField.text!
            newCategoryItem.colorHex = randomHexColor()
            
            
            //Results autoupdates without needing to append
/*            self.categoryArray.append(newCategoryItem*/
            
            self.saveData(with: newCategoryItem)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add new Category"
            textField = alertTextField
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil )
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveData(with category_item: CategoryItem){
        do{
            //CoreData Implementation
//            try context.save()
            try realm.write {
                realm.add(category_item)
            }
        } catch {
            print("error saving data in context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    //CoreDate implentation of fetching data
//    func loadData(with request: NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()){
////        let request : NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()
//        
//        do{
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("error fetching data from context, \(error)")
//        }
//        
//    }
    
    func loadData() {
        categoryArray = realm.objects(CategoryItem.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("error deleting category item, \(error)")
            }
        }
    }
    
}



