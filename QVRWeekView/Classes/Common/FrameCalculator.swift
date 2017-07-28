//
//  EventFrameCalculator.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 7/28/17.
//

import Foundation

typealias WidthPosTuple = (width: CGFloat, x: CGFloat)

class FrameCalculator {

    init(withWidth width: CGFloat, andHeight height: CGFloat) {
        self.width = width
        self.height = height
    }

    let width: CGFloat
    let height: CGFloat

    func calculateEventFrames(withData eventsData: [Int: EventData]) -> [Int: CGRect] {
        let eventFrames = calculateStarterEventFrames(forData: Array(eventsData.values))
        let domains = calculateDomains(with: eventFrames)

        var totalDom = 0
        for (_, domain) in domains {
            totalDom += domain.count
        }
        let averageDomCount = totalDom/domains.count

        if averageDomCount + eventFrames.count <= 18 {
            return calclulateFramesWithConstraintOptimization(forFrames: eventFrames, withDomains: domains)
        }
        else {
            return calculateWithSweepingLine(forFrames: eventFrames)
        }
    }

    fileprivate func calculateStarterEventFrames(forData eventData: [EventData]) -> [EventFrame] {
        var eventFrames: [EventFrame] = []
        for data in eventData {
            eventFrames.append(getEventFrame(withData: data))
        }
        return eventFrames
    }

    fileprivate static func detectCollisions(`in` eventFrames: [EventFrame]) -> Bool {

        var sweepState: Heap<SweepNode> = Heap(sort: {(s1, s2) -> Bool in
            return s1.x < s2.x
        })

        let endPoints = calculateEndPoints(for: eventFrames)

        for point in endPoints {
            if !sweepState.isEmpty {
                let nodes = sweepState.elements
                var frames: [EventFrame] = []
                for node in nodes where node.frame != point.frame {
                    frames.append(node.frame)
                }
                if point.frame.intersects(withFrameFrom: frames) {
                    return true
                }
            }

            if point.isStart {
                sweepState.insert(SweepNode(x: point.frame.x, frame: point.frame))
                sweepState.insert(SweepNode(x: point.frame.x2, frame: point.frame))
            }
            else {
                _ = sweepState.removeAt(sweepState.index(of: SweepNode(x: point.frame.x, frame: point.frame))!)
                _ = sweepState.removeAt(sweepState.index(of: SweepNode(x: point.frame.x2, frame: point.frame))!)
            }
        }

        return false
    }

    fileprivate static func calculateEndPoints(`for` eventFrames: [EventFrame]) -> [EndPoint] {
        var endPoints: [EndPoint] = []
        for frame in eventFrames {
            endPoints.append(EndPoint(y: frame.y, id: frame.id, frame: frame, isStart: true))
            endPoints.append(EndPoint(y: frame.y2, id: frame.id, frame: frame, isStart: false))
        }

        endPoints.sort(by: {(e1, e2) -> Bool in
            if e1.y.isEqual(to: e2.y, decimalPlaces: 12) {
                if e1.isEnd && e2.isStart {
                    return true
                }
                else if e1.isStart && e2.isEnd {
                    return false
                }
            }
            return e1.y < e2.y
        })
        return endPoints
    }

    fileprivate func calculateDomains(with eventFrames: [EventFrame]) -> [EventFrame: [WidthPosTuple]] {
        var domains: [EventFrame: [WidthPosTuple]] = [:]
        var sweepState: [Int:EventFrame] = [:]

        let endPoints = FrameCalculator.calculateEndPoints(for: eventFrames)

        for point in endPoints {
            if point.isStart {
                sweepState[point.id] = point.frame
                if !sweepState.isEmpty {
                    let domain = calculateDomain(withMax: sweepState.count)
                    for (_, frame) in sweepState {
                        domains[frame] = domain
                    }
                }
            }
            else {
                sweepState.removeValue(forKey: point.id)
            }
        }
        return domains
    }

    private static func heap(_ heap: Heap<SweepNode>, containsValueBetween val1: CGFloat, and val2: CGFloat) -> SweepNode? {
        for node in heap.elements where val1 <= node.x && node.x <= val2 {
            return node
        }
        return nil
    }

    private func calculateDomain(withMax max: Int) -> [WidthPosTuple] {
        var i = 1
        var domain: [WidthPosTuple] = []
        while i <= max {
            let domW = self.width/CGFloat(i)
            var c = 0
            while c < i {
                domain.append((width: domW, x: domW*CGFloat(c)))
                c += 1
            }
            i += 1
        }
        return domain
    }

    private func getEventFrame(withData data: EventData) -> EventFrame {
        let time = data.startDate.getTimeInHours()
        let duration = data.endDate.getTimeInHours() - time
        let hourHeight = self.height/DateSupport.hoursInDay
        return EventFrame(x: 0, y: hourHeight*CGFloat(time), width: self.width, height: hourHeight*CGFloat(duration), id: data.id)
    }

    fileprivate struct EndPoint: CustomStringConvertible {
        var y: CGFloat
        var id: Int
        var frame: EventFrame
        var isStart: Bool
        var isEnd: Bool {
            return !isStart
        }
        var description: String {
            return "{y: \(y), id: \(id), isStart: \(isStart)}\n"
        }
    }

    fileprivate struct SweepNode: Equatable, CustomStringConvertible {

        let x: CGFloat
        let frame: EventFrame

        var description: String {
            return "{\(x) - \(frame)}"
        }

        static func == (lhs: FrameCalculator.SweepNode, rhs: FrameCalculator.SweepNode) -> Bool {
            return lhs.frame.id == rhs.frame.id
        }
    }

    fileprivate class EventFrame: CustomStringConvertible, Hashable {

        init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, id: Int) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
            self.id = id
        }

        let id: Int
        var x: CGFloat
        var y: CGFloat
        var width: CGFloat
        var height: CGFloat
        var leftLimit: CGFloat?
        var rightLimit: CGFloat?

        var y2: CGFloat {
            return self.y + self.height
        }

        var x2: CGFloat {
            return self.x + self.width
        }

        var description: String {
            return "{x: \(x), y: \(y), width: \(width), height: \(height)}\n"
        }

        var cgRect: CGRect {
            return CGRect(x: self.x, y: self.y, width: self.width, height: self.height)
        }

        var hashValue: Int {
            return id
        }

        static func == (lhs: FrameCalculator.EventFrame, rhs: FrameCalculator.EventFrame) -> Bool {
            return lhs.id == rhs.id
        }

        func intersects(withFrameFrom eventFrames: [EventFrame]) -> Bool {
            for frame in eventFrames {
                if self.cgRect.intersects(frame.cgRect) {
                    return true
                }
            }
            return false
        }

        func swapPositions(withFrame eventFrame: EventFrame) {
            let oldX = self.x
            self.x = eventFrame.x
            eventFrame.x = oldX
        }
    }
}

// MARK: - Sweeping Line -

extension FrameCalculator {

    fileprivate func calculateWithSweepingLine(forFrames eventFrames: [EventFrame]) -> [Int: CGRect] {

        let endPoints = FrameCalculator.calculateEndPoints(for: eventFrames)
        var finalFrameState: [EventFrame] = []
        var sweepState: [Int: EventFrame] = [:]
        var frames: [Int: CGRect] = [:]

        for point in endPoints {
            if point.isStart {
                // If collisions, resize and reposition the frames.
                if !sweepState.isEmpty {
                    var frames = Array(sweepState.values)
                    frames.append(point.frame)
                    frames.sort(by: {(f1, f2) -> Bool in
                        return f1.x < f2.x
                    })
                    var i = CGFloat(0)
                    let newWidth = self.width/CGFloat(frames.count)
                    for frame in frames {
                        frame.x = newWidth*i
                        frame.width = newWidth
                        if frame.intersects(withFrameFrom: finalFrameState) {
                            frame.swapPositions(withFrame: point.frame)
                        }
                        i += 1
                    }
                }
                // Add to sweepingline
                sweepState[point.id] = point.frame
            }
            else {
                // Remove from sweepingline and add to eventFrames
                sweepState[point.id] = nil
                finalFrameState.append(point.frame)
                finalFrameState.sort(by: {(f1, f2) -> Bool in
                    return f1.x < f2.x
                })
                frames[point.id] = point.frame.cgRect
            }
        }
        return frames
    }

}

// MARK: - Constraint Optimization -

extension FrameCalculator {

    fileprivate func calclulateFramesWithConstraintOptimization(forFrames eventFrames: [EventFrame], withDomains domains: [EventFrame: [WidthPosTuple]]) -> [Int: CGRect] {

        var frames: [Int: CGRect] = [:]

        // Variables - of type : EventFrame
        // Domain - of type: WidthPodTuple
        // Constraint - of type: EventFrameConstraint: ListConstraint<EventFrame, WidthPosTuple>
        var constrainSatisfactionProblemSolver = CSP<EventFrame, WidthPosTuple>(variables: eventFrames, domains: domains)
        let constraint = EventFrameConstraint(variables: eventFrames)
        constrainSatisfactionProblemSolver.addConstraint(constraint: constraint)

        if let result = backtrackingSearch(csp: constrainSatisfactionProblemSolver) {
            for (frame, _) in result {
                frames[frame.id] = frame.cgRect
            }
        }
        return frames
    }

    private class EventFrameConstraint: ListConstraint<EventFrame, WidthPosTuple> {

        override func isSatisfied(assignment: [FrameCalculator.EventFrame: WidthPosTuple]) -> Bool {

            var eventFrames: [EventFrame] = []

            for (frame, value) in assignment {
                frame.x = value.x
                frame.width = value.width
                eventFrames.append(frame)
            }

            return !FrameCalculator.detectCollisions(in: eventFrames)
        }
    }
}

// MARK: - TESTS -

extension FrameCalculator {

    private func testCollisionAlgorithm() {
        let frameTest1: [EventFrame] = [EventFrame(x: 0, y: 0, width: 100, height: 100, id: 0 ),
                                        EventFrame(x: 100, y: 0, width: 100, height: 100, id: 1 ),
                                        EventFrame(x: 0, y: 150, width: 100, height: 100, id: 2 ),
                                        EventFrame(x: 100, y: 250, width: 100, height: 100, id: 3 ),
                                        EventFrame(x: 0, y: 400, width: 100, height: 100, id: 4 ),
                                        EventFrame(x: 0, y: 500, width: 100, height: 100, id: 5 )
        ]

        let frameTest2: [EventFrame] = [EventFrame(x: 0, y: 400, width: 100, height: 100, id: 6 ),
                                        EventFrame(x: 0, y: 450, width: 100, height: 100, id: 7 )
        ]

        let frameTest3: [EventFrame] = [EventFrame(x: 0, y: 400, width: 100, height: 100, id: 4 ),
                                        EventFrame(x: 50, y: 400, width: 100, height: 100, id: 5 )
        ]

        let frameTest4: [EventFrame] = [EventFrame(x: 0, y: 400, width: 100, height: 100, id: 0 ),
                                        EventFrame(x: 50, y: 450, width: 100, height: 100, id: 1 )
        ]

        let frameTest5: [EventFrame] = [EventFrame(x: 0, y: 700, width: 150, height: 100, id: 0 ),
                                        EventFrame(x: 0, y: 750, width: 100, height: 150, id: 1 )
        ]
        // false
        print(FrameCalculator.detectCollisions(in: frameTest1))
        // true
        print(FrameCalculator.detectCollisions(in: frameTest2))
        // true
        print(FrameCalculator.detectCollisions(in: frameTest3))
        // true
        print(FrameCalculator.detectCollisions(in: frameTest4))
        // true
        print(FrameCalculator.detectCollisions(in: frameTest5))
    }

}
