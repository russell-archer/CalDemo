//
//  ViewController.swift
//  CalDemo
//
//  Created by Russell Archer on 25/07/2018.
//  Copyright © 2018 Russell Archer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate var calHelper = CalHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calHelper.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        calHelper.checkEventStoreAccess()
    }
}

extension ViewController: CalHelperDelegate {
    func storeAccessHasChanged(accessGranted: Bool) {
        guard accessGranted else {
            print("You have not granted access to calendars")
            return
        }

        calHelper.loadEvents()
    }
    
    func storeEventsAvailable(count: Int) {
        print("Found the following \(count) events in all calendars...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
        
        for event in calHelper.events! {
            print("\(event.calendar.title) \(dateFormatter.string(from: event.startDate!)) \(event.title!)")
        }
    }
}

