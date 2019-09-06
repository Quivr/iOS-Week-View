@testable import QVRWeekView
import XCTest

class QVRWeekViewTests: XCTestCase {

    var weekView: WeekView!
    var eventIdCounter: Int!
    var startOffset: Double!
    var endOffset: Double!

    override func setUp() {
        super.setUp()
        startOffset = 0.0
        endOffset = 1.0
        eventIdCounter = 0
        weekView = WeekView()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func generateValidEventData() -> EventData {
        let event = EventData(id: eventIdCounter,
                              title: "Test-\(eventIdCounter!)",
                              startDate: Date().getStartOfDay().applyTimeInHours(hourTime: startOffset),
                              endDate: Date().getStartOfDay().applyTimeInHours(hourTime: endOffset),
                              color: UIColor.black)
        eventIdCounter += 1
        startOffset += 1.0
        endOffset += 1.0
        if endOffset >= 23.0 {
            startOffset = 0.0
            endOffset = 1.0
        }
        return event
    }

    private func AssertEventsLoaded(events: [EventData]?) {
        guard let checkEvents = events else {
            XCTFail("Passed events are nil")
            return
        }
        var allLoaded = true
        for event in checkEvents {
            allLoaded = allLoaded && weekView.allVisibleEvents.contains(event)
        }
        XCTAssertTrue(allLoaded)
    }

    func testSingleEventLoad() {
        let event = generateValidEventData()
        let events: [EventData] = [event]

        weekView.loadEvents(withData: events)

        XCTAssertEqual(weekView.allVisibleEvents.count, 1)
        AssertEventsLoaded(events: events)
    }

    func testMultipleEventsLoad() {
        let n = 1000
        var events: [EventData] = []
        for _ in 1...n {
            events.append(generateValidEventData())
        }
        weekView.loadEvents(withData: events)
        XCTAssertEqual(weekView.allVisibleEvents.count, n)
        AssertEventsLoaded(events: events)
    }

    func testEventLoadingInLoop() {
        var eventsArray: [[EventData]] = []
        for _ in 1...100 {
            var events: [EventData] = []
            for _ in 1...500 {
                events.append(generateValidEventData())
            }
            eventsArray.append(events)
        }

        for events in eventsArray {
            weekView.loadEvents(withData: events)
        }

        AssertEventsLoaded(events: eventsArray.last)
    }
}
