//
//  CalendarManager.swift
//  Go
//
//  Created by Lucky on 24/04/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import UIKit
import EventKit

typealias CalendarAddEventHandler = () -> Void

class CalendarManager {
    
    private weak var controller: UIViewController?
    private var completionHandler: CalendarAddEventHandler?
    
    init(withController controller: SHOViewController) {
        self.controller = controller
    }
    
    public func handleEvent(_ event: EventModel, forUser user: UserModel?, completion: CalendarAddEventHandler? = nil) {
        
        if user == nil {
            CacheManager.getCurrentUser { (user, error) in
                if let user = user {
                    self.handleEvent(event, forUser: user, completion: completion)
                } else {
                    self.controller?.showErrorAlertWith(message: error?.localizedDescription) {
                        completion?()
                    }
                }
            }
            return
        }
        
        self.completionHandler = completion
        let promptAlreadyShown = UserDefaults.standard.bool(forKey: UserDefaultKey.calendarPromptShown)
    
        if promptAlreadyShown {
            if user!.saveEventsToCalendar {
                if let status = event.userAttendance?.status {
                    switch status {
                    case .going:
                        self.addEventToCalendar(event)
                    case .notGoing:
                        self.removeEventFromCalendar(event)
                    default:
                        break
                    }
                }
            } else {
                self.completionHandler?()
            }
        } else {
            self.showCalendarPrompt(forEvent: event)
        }
    }
    
    private func showCalendarPrompt(forEvent event: EventModel) {
        let yesAction = UIViewController.yesAction { action in
            if let status = event.userAttendance?.status {
                switch status {
                case .going:
                    self.addEventToCalendar(event)
                case .notGoing:
                    self.removeEventFromCalendar(event)
                default:
                    break
                }
            }
            let request = UserCalendarPrefsRequestModel(saveEventsToCalendar: true)
            SHOAPIClient.shared.updateMe(with: request) { (object, error, code) in
                if let error = error {
                    self.controller?.showErrorAlertWith(message: error.localizedDescription)
                }
            }
        }
        
        let noAction = UIViewController.noAction { action in
            let request = UserCalendarPrefsRequestModel(saveEventsToCalendar: false)
            SHOAPIClient.shared.updateMe(with: request) { (object, error, code) in
                if let error = error {
                    self.controller?.showErrorAlertWith(message: error.localizedDescription) {
                        self.completionHandler?()
                    }
                } else {
                    self.completionHandler?()
                }
            }
        }
        
        let alert = UIViewController.alertWith(title: "EVENT_ADD_TO_CALENDAR_TITLE".localized,
                                               message: "EVENT_ADD_TO_CALENDAR_MSG".localized,
                                               actions: [yesAction, noAction])
        self.controller?.present(alert, animated: true) {
            UserDefaults.standard.set(true, forKey: UserDefaultKey.calendarPromptShown)
        }
    }
    
    private func addEventToCalendar(_ goEvent: EventModel) {
        var eventStore = EKEventStore()
        
        let date = Date(timeIntervalSince1970: goEvent.date)
        let datePredicate = eventStore.predicateForEvents(withStart: date.startOfDay,
                                                          end: date.endOfDay,
                                                          calendars: nil)
        let existingEventPresent = eventStore.events(matching: datePredicate).contains { (event) -> Bool in
            event.title == goEvent.title
        }

        if existingEventPresent {
            self.completionHandler?()
            return
        }
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if granted && (error == nil) {
                
                eventStore = EKEventStore() //https://stackoverflow.com/a/44415132
                let event = EKEvent(eventStore: eventStore)
                event.title = goEvent.title
                event.notes = goEvent.description
                event.startDate = self.exactDate(forEvent: goEvent)
                event.endDate = self.exactDate(forEvent: goEvent)
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    self.completionHandler?()
                } catch let e as NSError {
                    self.controller?.showErrorAlertWith(message: e.localizedDescription) {
                        self.completionHandler?()
                    }
                }
                
            } else if let e = error {
                self.controller?.showErrorAlertWith(message: e.localizedDescription) {
                    self.completionHandler?()
                }
            }
        })
    }
    
    private func removeEventFromCalendar(_ event: EventModel) {
        let eventStore = EKEventStore()
        
        let date = Date(timeIntervalSince1970: event.date)
        let datePredicate = eventStore.predicateForEvents(withStart: date.startOfDay,
                                                          end: date.endOfDay,
                                                          calendars: nil)
        
        let matchingEvent = eventStore.events(matching: datePredicate).first(where: {
            $0.title == event.title
        })
        
        if let event = matchingEvent {
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted && (error == nil) {
                    do {
                        try eventStore.remove(event, span: .thisEvent)
                        self.completionHandler?()
                    } catch let e as NSError {
                        self.controller?.showErrorAlertWith(message: e.localizedDescription) {
                            self.completionHandler?()
                        }
                    }
                } else if let e = error {
                    self.controller?.showErrorAlertWith(message: e.localizedDescription) {
                        self.completionHandler?()
                    }
                }
            })
        } else {
            self.completionHandler?()
        }
    }
    
    private func exactDate(forEvent event: EventModel) -> Date? {
        let calendar = NSCalendar.current
        
        let date = Date(timeIntervalSince1970: event.date)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        let time = Date(timeIntervalSince1970: event.time)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        return calendar.date(from: mergedComponents)
    }
}
