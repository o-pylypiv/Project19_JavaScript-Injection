//
//  ActionViewController.swift
//  Extension
//
//  Created by Olha Pylypiv on 22.04.2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inpuItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inpuItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier as String) {
                    [weak self] (dict, error) in
                    // do stuff
                    guard let itemDictionary = dict as? NSDictionary else {return}
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else {return}
                    print(javaScriptValues)
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
            
            let scriptToInsert = UserDefaults.standard.string(forKey: "scriptToInsert")
            script.text = scriptToInsert
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(selectOption))
            //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openMyScripts))
        }
    }

    @IBAction func done() {
        saveScript(script: script.text)
        UserDefaults.standard.set("", forKey: "scriptToInsert")
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
        
        item.attachments = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func selectOption() {
        let ac = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Select scripts", style: .default, handler: selectScripts))
        ac.addAction(UIAlertAction(title: "My scripts", style: .default, handler: openMyScripts))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func selectScripts(action: UIAlertAction) {
        let ac = UIAlertController(title: "Select script to run", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Show the title", style: .default) {_ in
            self.script.text = "alert(document.title);"
            self.done()
        })
        ac.addAction(UIAlertAction(title: "Style background", style: .default) {_ in
            self.script.text = """
            document.body.style.backgroundColor = 'blue';
            """
            self.done()
        })
        ac.addAction(UIAlertAction(title: "Highlight the links", style: .default) {_ in
            self.script.text = """
            Array.from(document.querySelectorAll('a')).forEach(link => link.style.backgroundColor = 'yellow');
            """
            self.done()
        })
        ac.addAction(UIAlertAction(title: "Count paragraphs", style: .default) {_ in
            self.script.text = """
            alert(document.querySelectorAll('p').length);
            """
            self.done()
        })
        ac.addAction(UIAlertAction(title: "Display page information", style: .default) {_ in
            self.script.text = """
            alert('Description: ' + document.querySelector('meta[name="description"]').content);
            """
            self.done()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func openMyScripts(action: UIAlertAction) {
        let vc = ScriptsTableViewController()
        vc.pageURL = pageURL
        
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    func saveScript(script: String) {
        let url = URL(string: pageURL)
        
        let defaults = UserDefaults.standard
        if let urlHost = url?.host() {
            var scriptArray = defaults.object(forKey: urlHost) as? [String] ?? [String]()
            scriptArray.append(script)
            defaults.set(scriptArray, forKey: urlHost)
        }
        return
    }
}
