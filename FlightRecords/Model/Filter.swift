//
//  Filter.swift
//  FlightRecords
//
//  Created by Martin Zid on 22/01/2018.
//  Copyright © 2018 Martin Zid. All rights reserved.
//

import Foundation
import RealmSwift

class Filter {
    var searchConfiguration: SearchConfiguration?
    
    func filterRecords(from records: Results<Record>?) -> Results<Record>? {
        var collection = records
        if let text = searchConfiguration?.searchText {
            if text.count > 0 {
                collection = collection?.filter("(from contains[c] %@) or (to contains[c] %@)", text, text)
            }
        }
        if searchConfiguration?.flightsSwitch == false {
            collection = collection?.filter("type == 1")
        }
        if searchConfiguration?.fstdSwitch == false {
            collection = collection?.filter("type == 0")
        }
        if let type = searchConfiguration?.planeType {
            if type.count > 0 {
                print(type)
                collection = collection?.filter("plane.type contains[c] %@", type)
            }
        }
        if let plane = searchConfiguration?.plane {
            collection = collection?.filter("plane == %@", plane)
        }
        if let fromDate = searchConfiguration?.fromDate {
            collection = collection?.filter("date > %@", Calendar.current.startOfDay(for: fromDate))
        }
        if let toDate = searchConfiguration?.toDate {
            collection = collection?.filter("date < %@", Calendar.current.startOfDay(for: toDate.addingTimeInterval(60 * 60 * 24)))
        }
        return collection
    }
}