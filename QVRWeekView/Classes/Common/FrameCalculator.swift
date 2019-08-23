// swiftlint:disable private_over_fileprivate
//
//  EventFrameCalculator.swift
//  QVRWeekView
//
//  Created by Reinert Lemmens on 7/28/17.
//

import Foundation

/**
 FrameCalculator class is responsible for calculating event frames based on provided eventData.
 */
class FrameCalculator {
    // The date of the day view cell that is being analysed.
    let date: DayDate
    // Width of the current day view cell.
    var width: CGFloat {
        // Use default values as consistent value, this allows them to be resized easily.
        return LayoutDefaults.dayViewCellWidth
    }
    // Height of the current day view cells.
    var height: CGFloat {
        // Use default values as consistent value, this allows them to be resized easily.
        return LayoutDefaults.dayViewCellHeight
    }
    // Delegate
    weak var delegate: FrameCalculatorDelegate?
    // Constraint solution problem solver.
    private var csp: ConstraintSolver?
    // Bool used as a cancelation flag.
    private var cancelFlag: Bool = false

    // Variable returns if FrameCalculator is calculating.
    var isCalculating: Bool {
        return !cancelFlag
    }

    // Initialize with a date.
    init(date: DayDate) {
        self.date = date
    }

    // Calculate the solution.
    func calculate(withData eventsData: [String: EventData]?) {

        guard eventsData != nil else {
            self.delegate?.passSolution(fromCalculator: self, solution: [:])
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let n = eventsData!.count
            let endPoints = self.calculateEndPoints(for: eventsData!)
            var constraints: [[Bool]] = Array(repeating: Array(repeating: false, count: n), count: n)
            var domains: [Set<WidthPosValue>] = []

            var eventFrames: [EventFrame] = []
            var sweepState = Set<EventFrame>()
            var frameCollisions: [EventFrame: [EventFrame]] = [:]
            var collisionGroups: [[[EventFrame]]] = []
            var activeGroup: [[EventFrame]] = []

            var frameIndices: [EventFrame: Int] = [:]
            var areCollisions = false
            var index = 0

            // Sweep through all frames from top to bottom
            for point in endPoints {
                if point.isStart {
                    let newFrame = point.frame
                    // If collisions, resize and reposition the frames.
                    if !sweepState.isEmpty {
                        if !areCollisions { areCollisions = true }
                        // Calculate new width
                        var minWidth = CGFloat.infinity
                        for frame in sweepState {
                            minWidth = frame.width < minWidth ? frame.width : minWidth
                        }
                        var newWidth = self.width/CGFloat(sweepState.count+1)
                        newWidth = newWidth < minWidth ? newWidth : minWidth
                        for frame in sweepState {
                            frame.width = newWidth < frame.width ? newWidth : frame.width
                            if frameCollisions[point.frame] != nil { frameCollisions[point.frame]!.append(frame) }
                            else { frameCollisions[point.frame] = [frame] }
                            if frameCollisions[frame] != nil { frameCollisions[frame]!.append(point.frame) }
                            else { frameCollisions[frame] = [point.frame] }
                        }
                        point.frame.width = newWidth
                    }
                    if activeGroup.isEmpty {
                        activeGroup.append([point.frame])
                        for frame in sweepState {
                            activeGroup.append([frame])
                        }
                    }
                    else {
                        // Stores index of column to be added to
                        var addToIndex: Int?
                        // Counter keeps index of columns
                        var cIndex = 0
                        // Iterate through all columns in group
                        for column in activeGroup {
                            // Stores if this column is valid for the new frame
                            var validColumn = true
                            // If a frame in column is currently in the sweep state then the newframe might collide with it.
                            // So this column is not valid.
                            for frame in column where sweepState.contains(frame) {
                                validColumn = false
                            }
                            // If this column is valid store the addToIndex
                            if validColumn {
                                addToIndex = cIndex
                            }
                            // Increment counter
                            cIndex += 1
                        }
                        // If an index was found, add frame to column in that index
                        if let index1 = addToIndex {
                            var col = activeGroup[index1]
                            col.append(newFrame)
                            activeGroup[index1] = col
                        }
                            // If no index was found append a new column
                        else {
                            activeGroup.append([newFrame])
                        }
                    }
                    sweepState.insert(newFrame)
                }
                else {
                    // Remove from sweepingline and add to eventFrames
                    let frame = point.frame
                    sweepState.remove(frame)
                    // If sweepstate is now empty then the current active group is finished, append it to collisonGroups and reset active group.
                    if sweepState.isEmpty {
                        collisionGroups.append(activeGroup)
                        activeGroup.removeAll()
                    }
                    eventFrames.append(frame)
                    domains.append(self.domain(forFrame: frame, .subOptimal))
                    frameIndices[frame] = index
                    index += 1
                }
            }

            var frames: [String: CGRect]?
            if areCollisions {
                // Register possible collisions as constraints
                for (frame1, frameList) in frameCollisions {
                    let index1 = frameIndices[frame1]!
                    for frame2 in frameList {
                        let index2 = frameIndices[frame2]!
                        constraints[index1][index2] = true
                    }
                }

                // Create constraint solver and run backtracking algorithm
                self.csp = ConstraintSolver(domains: domains, constraints: constraints, variables: eventFrames, backup: collisionGroups, width: self.width)
                if !self.cancelFlag {
                    frames = self.csp?.backtrack()
                }
                DispatchQueue.main.sync {
                    self.delegate?.passSolution(fromCalculator: self, solution: frames)
                }
            }
            else {
                // If no collisions found, return the frames as they are
                if !self.cancelFlag {
                    frames = [:]
                    for frame in eventFrames {
                        frames![frame.id] = frame.cgRect
                    }
                }
                DispatchQueue.main.sync {
                    self.delegate?.passSolution(fromCalculator: self, solution: frames)
                }
            }
        }
    }

    // Method will trigger the FrameCalculator to stop calculating and return nil.
    func cancelCalculation() {
        cancelFlag = true
        csp?.cancel()
    }

    // Generate end points used during sweep line phase.
    private func calculateEndPoints(`for` eventsData: [String: EventData]) -> [EndPoint] {
        var endPoints: [EndPoint] = []
        for (id, data) in eventsData {
            let frame = getEventFrame(withData: data)
            endPoints.append(EndPoint(y: frame.y, id: id, frame: frame, isStart: true))
            endPoints.append(EndPoint(y: frame.y2, id: id, frame: frame, isStart: false))
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

    // Generate domain of possible width and position values based on width of frame.
    private func domain(forFrame frame: EventFrame, _ choice: DomainChoice = .subOptimal) -> Set<WidthPosValue> {
        var domain = Set<WidthPosValue>()
        let count = Int(self.width/frame.width)
        var i = 0
        if choice == .optimal { i = 1 }
        else if choice == .subOptimal { i = count == 1 ? 1 : (count <= 6 ? 2 : (count <= 8 ? count-2 : (count <= 9 ? count-1 : count))) }
        else { i = count }

        while i <= count {
            let width = self.width/CGFloat(i)
            for a in 0...(i-1) {
                domain.insert(WidthPosValue(x: CGFloat(a)*width, width: width))
            }
            i += 1
        }
        return domain
    }

    // Domain choice enum.
    private enum DomainChoice {
        case optimal
        case subOptimal
        case singular
    }

    // Return event frame based on event data.
    private func getEventFrame(withData data: EventData) -> EventFrame {
        let time = data.startDate.getTimeInHours()
        let duration = data.endDate.getTimeInHours() - time
        let hourHeight = self.height/DateSupport.hoursInDay
        return EventFrame(x: 0,
                          y: hourHeight*CGFloat(time),
                          width: self.width,
                          height: hourHeight*CGFloat(duration),
                          id: data.id)
    }

    // Struct used for endpoints during sweep line phase.
    private struct EndPoint: CustomStringConvertible {
        var y: CGFloat
        var id: String
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

// MARK: - FrameCalculator Delegate -

// Protocol contains FrameCalculator delegate functions.
protocol FrameCalculatorDelegate: class {
    // Delegate function passes solution back to main thread
    func passSolution(fromCalculator calculator: FrameCalculator, solution: [String: CGRect]?)
}

// MARK: - Constraint Optimization -

/**
 ConstraintSolver class provided a CSP backtracking algorithm used by FrameCalculator to solve frames.
 */
fileprivate class ConstraintSolver {

    // All domains of each variables.
    let domains: [Set<WidthPosValue>]
    // All variables.
    let variables: [EventFrame]
    // Bool matrix storing which variables are linked by a constraint
    let constraints: [[Bool]]
    // Number of variables.
    let n: Int
    // Width of day
    let width: CGFloat
    // Backup collision groups
    let collisionGroups: [[[EventFrame]]]
    // Start time of the algorithm.
    let startTime: TimeInterval
    // Bool stores a cancellation flag.
    private var cancelled: Bool = false

    // Init with given domains, constraintsa and variables.
    init (domains: [Set<WidthPosValue>], constraints: [[Bool]], variables: [EventFrame], backup collisionGroups: [[[EventFrame]]], width: CGFloat) {
        self.variables = variables
        self.constraints = constraints
        self.domains = domains
        self.n = variables.count
        self.startTime = Date.timeIntervalSinceReferenceDate
        self.collisionGroups = collisionGroups
        self.width = width
    }

    // Trigger the backtrack algorithm and check if solution is valid.
    func backtrack() -> [String: CGRect]? {
        switch backtrack(depth: 0) {
        case .success:
            return exportSolution()
        case .cancelled:
            return nil
        case .running, .timeout:
            return backupAlgorithm()
        }
    }

    // Backtracking algorithm/
    private func backtrack(depth: Int) -> BacktrackState {

        let domain = domains[depth].sorted(by: { (v1, v2) -> Bool in
            if v1.width.isEqual(to: v2.width, decimalPlaces: 12) {
                return v1.x < v2.x
            } else { return v1.width > v2.width }
        })

        for value in domain {
            if Date.timeIntervalSinceReferenceDate-startTime > 0.75 {
                return .timeout
            }
            if cancelled {
                return .cancelled
            }

            let activeFrame = variables[depth]
            activeFrame.applyValue(value)
            var noFails = true
            var a = 0
            while a < depth {
                if !constraintIsSatsified(activeDepth: depth, checkDepth: a) {
                    noFails = false
                    break
                }
                a += 1
            }
            if noFails {
                if depth == (n-1) {
                    return .success
                }
                else {
                    let nextDepth = depth + 1
                    let result = backtrack(depth: nextDepth)
                    if result != .running {
                        return result
                    }
                }
            }
        }
        return .running
    }

    private func backupAlgorithm() -> [String: CGRect]? {
        var solution: [String: CGRect] = [:]
        for collisionGroup in collisionGroups where !cancelled {
            let colCount = CGFloat(collisionGroup.count)
            var maxColSize = 0
            for col in collisionGroup {
                maxColSize = col.count > maxColSize ? col.count : maxColSize
            }
            for i in 0...maxColSize {
                var colIndex = CGFloat(0)
                for col in collisionGroup {
                    if col.count >= i+1 {
                        let frame = col[i]
                        frame.width = width / colCount
                        frame.x = (colIndex*width) / colCount
                        solution[frame.id] = frame.cgRect
                    }
                    colIndex += 1
                }
            }
        }
        if cancelled {
            return nil
        }
        return solution
    }

    // Check if constraint is satisfied between two depths.
    private func constraintIsSatsified(activeDepth d1: Int, checkDepth d2: Int) -> Bool {

        if constraints[d1][d2] {
            let f1 = variables[d1]
            let f2 = variables[d2]

            // Check that left corner f1 is not inside f2 and right corner f1 is not inside f2.
            return  (
                    !((f2.x < f1.x || f1.x.isEqual(to: f2.x, decimalPlaces: 12)) && (f1.x < f2.x2)) &&
                    !((f2.x < f1.x2) && (f1.x2 < f2.x2 || f1.x2.isEqual(to: f2.x2, decimalPlaces: 12)))
                    ) &&
                    (
                    !((f1.x < f2.x || f2.x.isEqual(to: f1.x, decimalPlaces: 12)) && (f2.x < f1.x2)) &&
                    !((f1.x < f2.x2) && (f2.x2 < f1.x2 || f2.x2.isEqual(to: f1.x2, decimalPlaces: 12)))
                    )
        }
        else {
            return true
        }
    }

    // Method triggers thread cancellation
    fileprivate func cancel() {
        self.cancelled = true
    }

    private func exportSolution() -> [String: CGRect] {
        var solution: [String: CGRect] = [:]
        for vari in variables {
            solution[vari.id] = vari.cgRect
        }
        return solution
    }

    private enum BacktrackState {
        case running
        case timeout
        case cancelled
        case success
    }
}

/**
 EventFrame class provides a convenient way to store the frame of an event including the id.
 */
fileprivate class EventFrame: CustomStringConvertible, Hashable {

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, id: String) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.id = id
    }

    let id: String
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

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

    static func == (lhs: EventFrame, rhs: EventFrame) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

    func getCGReact(withValue value: WidthPosValue) -> CGRect {
        return CGRect(x: value.x, y: self.y, width: value.width, height: self.height)
    }

    func applyValue(_ value: WidthPosValue) {
        self.width = value.width
        self.x = value.x
    }
}

/**
 WidthPodValue struct is the type of object used as variable domain value used by ConstraintSolver.
 */
fileprivate struct WidthPosValue: Hashable, CustomStringConvertible {
    var x: CGFloat
    var width: CGFloat

    var description: String {
        return "\n{x: \(x), width: \(width)}"
    }

    static func == (lhs: WidthPosValue, rhs: WidthPosValue) -> Bool {
        return lhs.x.isEqual(to: rhs.x, decimalPlaces: 12) && lhs.width.isEqual(to: rhs.width, decimalPlaces: 12)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(width)
    }
}
