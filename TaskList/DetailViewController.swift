//
//  DetailViewController.swift
//  TaskList
//
//  Created by Matthew Curran on 2/19/19.
//  Copyright © 2019 Matthew. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var task: Task!
    
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskDateCreated: UILabel!
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        taskDescription.text = task.description
        
        let dateString = Formatting.dateFormatter.string(from: task.dateCreated)
        taskDateCreated.text = "\(dateString)"
    }
    
    
}
