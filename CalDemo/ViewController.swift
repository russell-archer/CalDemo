//
//  ViewController.swift
//  CalDemo
//
//  Created by Russell Archer on 25/07/2018.
//  Copyright © 2018 Russell Archer. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    fileprivate var calHelper = CalHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calHelper.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        calHelper.checkEventStoreAccess()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier, segueId == "Events2AddEvent" {
            if let destVc = segue.destination as? AddEventViewController {
                destVc.calHelper = calHelper
            }
        }
    }
}

extension ViewController: CalHelperDelegate {
    func storeAccessHasChanged(accessGranted: Bool) {
        guard accessGranted else { return }

        calHelper.loadEvents()
    }
    
    func storeEventsAvailable(count: Int) {
        tableView.reloadData()
    }
}

extension ViewController: AddEventDelegate {
    func eventAdded() {
        calHelper.loadEvents()  // Causes events and the tableview to be reloaded
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        if calHelper.hasEventStoreAccess && calHelper.events != nil {
            cell.textLabel?.text = calHelper.events?[indexPath.row].title
            
            let calTitle = calHelper.events?[indexPath.row].calendar.title
            let startDate = dateFormatter.string(from: (calHelper.events?[indexPath.row].startDate!)!)
            
            cell.detailTextLabel?.text = calTitle! + ", " + startDate
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard calHelper.hasEventStoreAccess && calHelper.events != nil else { return 0 }
        return calHelper.events!.count
    }
}
