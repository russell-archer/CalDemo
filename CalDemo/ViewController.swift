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
        
        guard calHelper.loadCalendars() else {
            print("No calendars found")
            return
        }

        let events = calHelper.loadEvents()
        guard events != nil else {
            print("No events found")
            return
        }
        
        print("Found the following events in all calendars...")
        for event in events! {
            print("\(event.startDate!) \(event.title!)")
        }
    }
}

