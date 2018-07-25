//
//  CalHelper.swift
//  CalDemo
//
//  Created by Russell Archer on 25/07/2018.
//  Copyright © 2018 Russell Archer. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

/*
 
 You must add the NSCalendarsUsageDescription and NSRemindersUsageDescription
 keys to Info.plist or the app will crash
 
 */

protocol CalHelperDelegate {
    func storeAccessHasChanged(accessGranted: Bool)
}

class CalHelper {
    fileprivate var store: EKEventStore!
    fileprivate var cals: [EKCalendar]?
    fileprivate var events: [EKEvent]?
    
    public var delegate: CalHelperDelegate?
    
    public var hasEventStoreAccess = false {
        didSet {
            print("Event store access has changed from \(oldValue) to \(hasEventStoreAccess)")
            delegate?.storeAccessHasChanged(accessGranted: hasEventStoreAccess)
        }
    }
    
    init() {
        store = EKEventStore()
    }
    
    // Call from your view controller's viewWillAppear() method
    public func checkEventStoreAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined: askPermission()
        case .authorized: hasEventStoreAccess = true
        case .restricted: fallthrough
        case .denied: hasEventStoreAccess = false
        }
    }
    
    // Return the titles of the available calendars
    public func loadCalendars() -> Bool {
        guard hasEventStoreAccess else { return false }
        
        cals = store.calendars(for: EKEntityType.event)
        
        guard cals != nil else { return false }
        return true
    }
    
    public func loadEvents() -> [EKEvent]? {
        guard hasEventStoreAccess else { return nil }
        guard cals != nil else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = Date()
        let endDate = dateFormatter.date(from: "31-12-2018")
        guard endDate != nil else { return nil }
        
        let eventsPredicate = store.predicateForEvents(withStart: startDate, end: endDate!, calendars: cals)

        events = store.events(matching: eventsPredicate)
        guard events != nil else { return nil }

        return events
    }
    
    fileprivate func askPermission() {
        store.requestAccess(to: EKEntityType.event, completion: { (accessGranted: Bool, error: Error?) in
            DispatchQueue.main.async(execute: {
                self.hasEventStoreAccess = accessGranted
            })
        })
    }
}
