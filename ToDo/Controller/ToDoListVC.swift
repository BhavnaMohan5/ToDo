//
//  ViewController.swift
//  ToDo
//
//  Created by Bhavna Mohan on 05/02/19.
//  Copyright © 2019 Bhavna Mohan. All rights reserved.
//

import UIKit
import CoreData
class ToDoListVC: UITableViewController{
    //IBActions,Constants and Variables :
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
   // let defaults = UserDefaults.standard
    //let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        if itemArray[indexPath.row].done == true {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done.toggle()
       // context.delete(itemArray[indexPath.row])
       // itemArray.remove(at: indexPath.row)
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
             let newItem = Item(context: self.context)
             newItem.title = textField.text!
             newItem.done = false
             newItem.parentCategory = self.selectedCategory
             self.itemArray.append(newItem)
             self.saveItems()

        }
         alert.addTextField(configurationHandler: { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        })
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func saveItems() {
       
        do {
           try context.save()
        }
        catch {
            print("Error saving data to core data")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),predicate : NSPredicate? = nil){
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
             let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
              request.predicate = compoundPredicate
        }
        else {
            request.predicate = categoryPredicate
        }
            do {
              itemArray = try context.fetch(request)
                
            }
            catch {
                print("Error fetching request from Core Data")
            }
        tableView.reloadData()
        }
    //encoder :
//    func saveItems() {
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(itemArray)
//            try data.write(to : filePath!)
//        }
//        catch {
//            print("Error encoding item array")
//        }
//        tableView.reloadData()
//    }

//    func loadItems() {
//            if let data = try? Data.init(contentsOf: filePath!) {
//                let decoder = PropertyListDecoder()
//                do {
//                    itemArray = try decoder.decode([Item].self, from: data)
//                }
//
//                catch {
//                    print("Error loading data : \(error)")
//                }
//            }
//    }
    
}

extension ToDoListVC : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with : request, predicate: predicate)
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

