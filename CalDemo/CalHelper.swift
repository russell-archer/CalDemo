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
    func storeEventsAvailable(count: Int)
}

class CalHelper {
    fileprivate var store = EKEventStore()
    fileprivate var cals: [EKCalendar]?
    
    public var events: [EKEvent]?
    public var delegate: CalHelperDelegate?
    public var hasEventStoreAccess = false {
        didSet {
            delegate?.storeAccessHasChanged(accessGranted: hasEventStoreAccess)
        }
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
    
    public func loadEvents() {
        guard hasEventStoreAccess else { return }
        
        loadCalendars()
        guard cals != nil else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let startDate = Date()
        let endDate = dateFormatter.date(from: "31-12-2018")
        guard endDate != nil else { return }
        
        // A predicate (NSPredicate) is a filter: here we specify the criteria we want to match
        let eventsPredicate = store.predicateForEvents(withStart: startDate, end: endDate!, calendars: cals)

        events = store.events(matching: eventsPredicate)
        guard events != nil else { return }
        
        events!.sort(by: { (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        
        delegate?.storeEventsAvailable(count: events!.count)
    }
    
    public func addEvent() -> Bool {
        guard hasEventStoreAccess else { return false }
        guard cals != nil else { return false }
        
        let newEvent = EKEvent(eventStore: store)
        let cal = getDefaultCalendar()
        
        newEvent.title = "Auto-Event-Test3"
        newEvent.startDate = Date()
        newEvent.endDate = newEvent.startDate.addingTimeInterval(300)
        newEvent.calendar = cal
        
        do {
            try store.save(newEvent, span: .thisEvent)
        } catch {
            print("Error adding event")
            return false
        }
        
        return true
    }
    
    fileprivate func askPermission() {
        store.requestAccess(to: EKEntityType.event, completion: { (accessGranted: Bool, error: Error?) in
            DispatchQueue.main.async(execute: {
                self.hasEventStoreAccess = accessGranted
            })
        })
    }
    
    fileprivate func loadCalendars() {
        guard hasEventStoreAccess else { return }
        
        cals = store.calendars(for: EKEntityType.event)
    }
    
    fileprivate func getDefaultCalendar() -> EKCalendar? {
        guard hasEventStoreAccess else { return nil }
        guard cals != nil else { return nil }
        
        for cal in cals! {
            if cal.title == "Calendar" { return cal }
        }
        
        return nil
    }
}
