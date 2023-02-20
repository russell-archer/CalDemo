//
//  AddEventViewController.swift
//  CalDemo
//
//  Created by Russell Archer on 29/07/2018.
//  Copyright © 2018 Russell Archer. All rights reserved.
//

import UIKit

protocol AddEventDelegate {
    func eventAdded()
}

class AddEventViewController: UIViewController {
    public var calHelper: CalHelper?
    public var delegate:AddEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addEvent(_ sender: Any) {
        guard calHelper != nil else { return }
        
        if calHelper!.addEvent() {
            delegate?.eventAdded()  // Allows the main view controller to reload data
            navigationController?.popViewController(animated: true)  // Return to the main view controller
        }
    }
}
