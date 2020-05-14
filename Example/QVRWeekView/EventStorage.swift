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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "EventArray", in: managedContext)!

        if let cEventArray = NSManagedObject(entity: userEntity, insertInto: managedContext) as? Events {
            cEventArray.setValue(EventDataArray(eventsData: events), forKey: "eventsDataArray")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save", error, error.userInfo)
            }
        }
    }

    static func getEvents() -> [EventData] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            let result = try managedContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "EventArray"))
            if  let data = result.first as? NSManagedObject,
                let eventDataArray = data.value(forKey: "eventsDataArray") as? EventDataArray {
                return eventDataArray.eventsData
            }
        } catch {
            print("Fetch Failed")
        }
        return []
    }
}
