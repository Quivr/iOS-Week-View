//
//  EventFrameCalculator.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 7/28/17.
//

import Foundation

fileprivate typealias WidthPosTuple = (width: CGFloat, x: CGFloat)

class FrameCalculator {

    static var totalCalcs = 0
    static var totalCalcTime = 0.0

    init(withWidth width: CGFloat, andHeight height: CGFloat) {
        self.width = width
        self.height = height
    }

    let width: CGFloat
    let height: CGFloat

    func calculate(withData eventsData: [Int: EventData]) -> [Int: CGRect] {
        let time = Date.timeIntervalSinceReferenceDate
        var eventFrames = calculateStarterEventFrames(forData: Array(eventsData.values))
        let endPoints = FrameCalculator.calculateEndPoints(for: eventFrames)
        eventFrames.removeAll()

        var sweepState: [Int: EventFrame] = [:]
        var collisionConstraints = Set<ConstraintFlag>()
        var domains: [EventFrame: [WidthPosTuple]] = [:]
        var areCollisions = false

        for point in endPoints {

            if point.isStart {
                // If collisions, resize and reposition the frames.
                if !sweepState.isEmpty {
                    if !areCollisions { areCollisions = true }
                    // Calculate new width
                    let newWidth = self.width/CGFloat(sweepState.count+1)
                    for frame in Array(sweepState.values) {
                        frame.width = newWidth
                        let cFlag = ConstraintFlag(f1: point.frame, f2: frame)
                        collisionConstraints.insert(cFlag)
                    }
                    point.frame.width = newWidth
                }
                sweepState[point.id] = point.frame
            }
            else {
                // Remove from sweepingline and add to eventFrames
                sweepState[point.id] = nil
                eventFrames.append(point.frame)
                domains[point.frame] = domain(forFrame: point.frame)
            }
        }

        let csp = ConstraintSolver(domains: domains, constraints: collisionConstraints, variables: eventFrames)
//        csp.test()
        if areCollisions {
            let frames = csp.solveWithBacktracking()
//            print("Calc time: \(Date.timeIntervalSinceReferenceDate - time)")
            FrameCalculator.totalCalcs += 1
            FrameCalculator.totalCalcTime += (Date.timeIntervalSinceReferenceDate - time)
            print("Average time: \(FrameCalculator.totalCalcTime/Double(FrameCalculator.totalCalcs))")
            return frames
        }
        else {
            var frames: [Int: CGRect] = [:]
            for frame in eventFrames {
                frames[frame.id] = frame.cgRect
            }
//            print("Calc time: \(Date.timeIntervalSinceReferenceDate - time)")
            FrameCalculator.totalCalcs += 1
            FrameCalculator.totalCalcTime += (Date.timeIntervalSinceReferenceDate - time)
            print("Average time: \(FrameCalculator.totalCalcTime/Double(FrameCalculator.totalCalcs))")
            return frames
        }
    }

    fileprivate func calculateStarterEventFrames(forData eventData: [EventData]) -> [EventFrame] {
        var eventFrames: [EventFrame] = []
        for data in eventData {
            eventFrames.append(getEventFrame(withData: data))
        }
        return eventFrames
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

    fileprivate func domain(forFrame frame: EventFrame) -> [WidthPosTuple] {
        var domain: [WidthPosTuple] = []
        let count = Int(self.width/frame.width)
        var i = count <= 2 ? 1 : count-2
        while i <= count {
            let width = self.width/CGFloat(i)
            for a in 0...(i-1) {
                domain.append((width: width, x: CGFloat(a)*width))
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
}

// MARK: - Constraint Optimization -

fileprivate class ConstraintSolver {

    let domains: [EventFrame: [WidthPosTuple]]
    let constraints: Set<ConstraintFlag>
    let variables: [EventFrame]
    let n: Int

    var totalChecks = 0

    init (domains: [EventFrame: [WidthPosTuple]], constraints: Set<ConstraintFlag>, variables: [EventFrame]) {
        self.variables = variables
        self.constraints = constraints
        self.domains = domains
        self.n = variables.count
    }

//    func test() {
//
//        var totalTime = 0.0
//        for i in 1...10 {
//            totalChecks = 0
//            let time = Date.timeIntervalSinceReferenceDate
//            _ = backjump(depth: 0)
//            if i == 1 { print(totalChecks) }
//            totalTime += (Date.timeIntervalSinceReferenceDate-time)
//        }
//        print("Backjump average time: \(totalTime/10)")
//
//        totalTime = 0.0
//        for i in 1...10 {
//            totalChecks = 0
//            let time = Date.timeIntervalSinceReferenceDate
//            _ = backtrack(depth: 0)
//            if i == 1 { print(totalChecks) }
//            totalTime += (Date.timeIntervalSinceReferenceDate-time)
//        }
//        print("Backtrack average time: \(totalTime/10)")
//    }

//    func solveWithBackjumping() -> [Int: CGRect] {
//        if backjump(depth: 0) == -1 {
//            var frames: [Int: CGRect] = [:]
//            for vari in variables {
//                frames[vari.id] = vari.cgRect
//            }
//            return frames
//        }
//        else {
//            return [:]
//        }
//    }

    func solveWithBacktracking() -> [Int: CGRect] {
        if backtrack(depth: 0) {
            var frames: [Int: CGRect] = [:]
            for vari in variables {
                frames[vari.id] = vari.cgRect
            }
            return frames
        }
        else {
            return [:]
        }
    }

//    private func backjump(depth: Int) -> Int {
//
//        let nDepth = domains[variables[depth]]!.count
//        var maxCheckdepth = 0
//
//        for i in 0...(nDepth-1) {
//            let activeFrame = variables[depth]
//            let value = domains[activeFrame]![i]
//            activeFrame.applyValue(value)
////            print("Value \(i) assigned at depth \(depth): \(activeFrame)")
//            var noFails = true
//            var a = 0
//            while a < depth {
//                totalChecks += 1
////                print("Checking at depth \(depth) with upper level \(a)")
//                if !constraintIsSatsified(activeDepth: depth, checkDepth: a) {
////                    print("Failed at \(a)")
//                    noFails = false
//                    if a > maxCheckdepth {
//                        maxCheckdepth = a
//                    }
//                    break
//                }
//                a += 1
//            }
////            print("No fails: \(noFails)")
//            if noFails {
//                if depth == (n-1) {
////                    print("Return true at depth: \(depth)")
//                    return -1
//                }
//                else {
//                    let nextDepth = depth + 1
////                    print("Go next depth: \(nextDepth)")
//                    let jbDepth = backjump(depth: nextDepth)
//                    if  jbDepth < depth {
////                        print("Backjump to \(jbDepth)")
//                        return jbDepth
//                    }
////                    print("Depth \(jbDepth) reached, continue at level: \(depth)")
//                }
//            }
//        }
//        return maxCheckdepth
//    }

    private func backtrack(depth: Int) -> Bool {

        let nDepth = domains[variables[depth]]!.count

        for i in 0...(nDepth-1) {
            let activeFrame = variables[depth]
            let value = domains[activeFrame]![i]
            activeFrame.applyValue(value)
//            print("Value \(i) assigned at depth \(depth): \(activeFrame)")
            var noFails = true
            var a = 0
            while a < depth {
                totalChecks += 1
//                print("Checking at depth \(depth) with upper level \(a)")
                if !constraintIsSatsified(activeDepth: depth, checkDepth: a) {
//                    print("Failed")
                    noFails = false
                    break
                }
                a += 1
            }
//            print("No fails: \(noFails)")
            if noFails {
                if depth == (n-1) {
//                    print("Return true at depth: \(depth)")
                    return true
                }
                else {
                    let nextDepth = depth + 1
//                    print("Go next depth: \(nextDepth)")
                    if backtrack(depth: nextDepth) {
//                        print("True return received at depth \(depth)")
                        return true
                    }
//                    print("False return, continue at level: \(depth)")
                }
            }
        }
        return false
    }

    private func constraintIsSatsified(activeDepth d1: Int, checkDepth d2: Int) -> Bool {
        let f1 = variables[d1]
        let f2 = variables[d2]
        let flag = ConstraintFlag(f1: f1, f2: f2)
//        print("\(f1) \(f2)")
        if constraints.contains(flag) {
            if (f2.x <= f1.x && f1.x < f2.x2) || (f2.x < f1.x2 && f1.x2 <= f2.x2) {
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
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
        return "{x: \(x), y: \(y), width: \(width), height: \(height), id: \(id)}\n"
    }

    var cgRect: CGRect {
        return CGRect(x: self.x, y: self.y, width: self.width, height: self.height)
    }

    var hashValue: Int {
        return id
    }

    static func == (lhs: EventFrame, rhs: EventFrame) -> Bool {
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

    func getCGReact(withValue value: WidthPosTuple) -> CGRect {
        return CGRect(x: value.x, y: self.y, width: value.width, height: self.height)
    }

    func applyValue(_ value: WidthPosTuple) {
        self.width = value.width
        self.x = value.x
    }
}

fileprivate struct ConstraintFlag: Hashable, CustomStringConvertible {

    init(f1: EventFrame, f2: EventFrame) {
        guard f1.id != f2.id else {
            fatalError("Two frames with same id passed as constraint flag")
        }
        if f1.id < f2.id {
            self.f1 = f1
            self.f2 = f2
        }
        else {
            self.f2 = f1
            self.f1 = f2
        }
    }

    var hashValue: Int {
        let id1 = f1.id
        let id2 = f2.id
        let sub1 = (id1+id2)
        let sub2 = (id1+id2+1)
        return Int(0.5*Double(sub1)*Double(sub2))+id2
    }
    var description: String {
        return "[\(f1),\(f2)]"
    }
    let f1: EventFrame
    let f2: EventFrame

    static func == (lhs: ConstraintFlag, rhs: ConstraintFlag) -> Bool {
        return (lhs.f1 == rhs.f1 && lhs.f2 == rhs.f2) || (lhs.f1 == rhs.f2 && lhs.f2 == rhs.f1)
    }
}
