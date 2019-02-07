//
//  ViewController.swift
//  ToDo
//
//  Created by Bhavna Mohan on 05/02/19.
//  Copyright © 2019 Bhavna Mohan. All rights reserved.
//

import UIKit

class ToDoListVC: UITableViewController {
    //IBActions,Constants and Variables :
    
    var itemArray = [Item]()
   // let defaults = UserDefaults.standard
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        loadItems()
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
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
             let newItem = Item()
             newItem.title = textField.text!
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to : filePath!)
        }
        catch {
            print("Error encoding item array")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
            if let data = try? Data.init(contentsOf: filePath!) {
                let decoder = PropertyListDecoder()
                do {
                    itemArray = try decoder.decode([Item].self, from: data)
                }
                
                catch {
                    print("Error loading data : \(error)")
                }
            }
        
    }
    
}

