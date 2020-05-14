//
//  EventStorage.swift
//  QVRWeekView_Example
//
//  Created by Reinert Lemmens on 14/05/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CoreData
import Foundation
import QVRWeekView

class EventStorage {
    static func storeEvents(events: [EventData]) {
        // First delete all previous stored event arays
        deleteEvents()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "EventArray", in: managedContext)!

        if let cEventArray = NSManagedObject(entity: userEntity, insertInto: managedContext) as? EventArray {
            cEventArray.setValue(EventDataArray(eventsData: events), forKey: "events")
            appDelegate.saveContext()
        }
    }

    static func getEvents() -> [EventData] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            if  let eventArray = try managedContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "EventArray")).first as? EventArray,
                let eventDataArray = eventArray.value(forKey: "events") as? EventDataArray {
                return eventDataArray.eventsData
            }
        } catch {
            print("Fetch Failed")
        }
        return []
    }

    static func deleteEvents() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "EventArray")))
        } catch {
            print("Delete Failed")
        }
    }
}
