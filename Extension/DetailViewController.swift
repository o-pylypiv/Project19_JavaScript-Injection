//
//  DetailViewController.swift
//  Extension
//
//  Created by Olha Pylypiv on 26.04.2024.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var scriptLabel: UILabel!
    var selectedScript: Script?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = selectedScript?.name
        scriptLabel.text = selectedScript?.jsScript
    }
    
    override func viewDidLayoutSubviews() {
        nameLabel.sizeToFit()
        scriptLabel.sizeToFit()
    }
}
