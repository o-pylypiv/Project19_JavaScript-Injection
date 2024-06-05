//
//  ScriptsTableViewController.swift
//  Extension
//
//  Created by Olha Pylypiv on 24.04.2024.
//

import UIKit

class ScriptsTableViewController: UITableViewController {
    var pageURL = ""
    var scripts = [Script]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve scripts from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: "myScripts"),
           let decodedScripts = try? JSONDecoder().decode([Script].self, from: savedData) {
            scripts = decodedScripts
            print("Scripts loaded successfully: \(scripts)")
        } else {
            print("No scripts found in UserDefaults")
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        tableView.reloadData()
        
        // Register the custom cell class for the reuse identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Script")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)
        let script = scripts[indexPath.row]
        cell.textLabel?.text = script.name
        cell.detailTextLabel?.text = script.jsScript
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "View script", style: .default) { [weak self] _ in

            let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.selectedScript = self?.scripts[indexPath.row]
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                fatalError("Failed to load DetailViewController.")
            }
        })
        
//        ac.addAction(UIAlertAction(title: "Apply script", style: .default) { [weak self] _ in
//            let avc = ActionViewController()
//            
//            let selectedScript = self?.scripts[indexPath.row].jsScript
//            avc.script.text = selectedScript
//            self?.navigationController?.pushViewController(avc, animated: true)
//        })
        
        ac.addAction(UIAlertAction(title: "Apply script", style: .default) { [weak self] _ in
            guard let avc = UIStoryboard(name: "MainInterface", bundle: nil).instantiateViewController(withIdentifier: "ActionViewController") as? ActionViewController else {
                print("Failed to instantiate ActionViewController.")
                return
            }

            if let selectedScript = self?.scripts[indexPath.row].jsScript {
                if let script = avc.script {
                    script.text.append(selectedScript)
                } else {
                    print("Script is nil")
                    UserDefaults.standard.set(selectedScript, forKey: "scriptToInsert")
                }
            } else {
                print("Selected script is nil")
            }

            self?.navigationController?.pushViewController(avc, animated: true)
        })

        ac.addAction(UIAlertAction(title: "Delete script", style: .default) {_ in 
            let ac1 = UIAlertController(title: "Delete this script?", message: nil, preferredStyle: .alert)
            ac1.addAction(UIAlertAction(title: "Delete", style: .default) {[weak self] _ in
                if (self?.scripts[indexPath.row].jsScript) != nil {
                    self?.scripts.remove(at: indexPath.row)
                    self?.tableView.reloadData()
                }
            })
            ac1.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(ac1, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addScript() {
        let ac = UIAlertController(title: "Add new script", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitScriptAction = UIAlertAction(title: "Add", style: .default) {
            [weak self, weak ac] _ in
            guard let script = ac?.textFields?[0].text else {return}
            self?.submitScript(script)
        }
        ac.addAction(submitScriptAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func submitScript(_ script: String) {
        guard !script.isEmpty else {return}
        
        let ac = UIAlertController(title: "Add name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitNameAction = UIAlertAction(title: "Save", style: .default) {
            [weak self, weak ac] action in
            guard let name = ac?.textFields?[0].text else {return}
            let newScript = Script(name: name, jsScript: script)
            self?.scripts.insert(newScript, at: 0)
            // Save scripts to UserDefaults
            let encoder = JSONEncoder()
            do {
                let encodedData = try encoder.encode(self?.scripts)
                UserDefaults.standard.set(encodedData, forKey: "myScripts")
                print("Scripts saved successfully: \(self?.scripts ?? [Script]())")
            } catch {
                print("Error encoding scripts: \(error)")
            }

            let indexPath = IndexPath(row: 0, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .automatic)
            print("UIAlertController presented for adding name")
        }
        ac.addAction(submitNameAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
        // Save scripts to UserDefaults
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(scripts) {
            UserDefaults.standard.set(encodedData, forKey: "myScripts")
        }
    }
}
