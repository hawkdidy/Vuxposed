//
//  vuxObjectModel.swift
//  uxDataProcess
//
//  Created by Ivan on 18/03/16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import Foundation




class Session {
    var id: Int
    var logTasks    = [LogTask]()  // Not implemented
    var logEvents   = [LogEvent]()
    var excluded    = false
    init(sessionID: Int) {
        self.id = sessionID
    }
    func updateLogEventSequence() {
        if logEvents.count > 1 {
            logEvents.sortInPlace({$0.startTime < $1.startTime})
            logEvents[0].sequenceInSession = 0
            logEvents[0].duration = 0
            for i in 1..<logEvents.count {
                logEvents[i].sequenceInSession = i
                logEvents[i].duration = logEvents[i].startTime - logEvents[i-1].startTime
            }
        }
    }
}



class Task: Hashable {
    let id: Int
    let hashValue: Int
    let name: String
    var eventsSet = Set<Event>()
    var frequency = 0
    init(id: Int, name: String) {
        self.id = id
        self.hashValue = id
        self.name = name
    }
    func sortedEvents() -> [Event] {
        // Returns an array of events
        // TODO: implement a real sorting
        var array = [Event]()
        for event in eventsSet {
            array.append(event)
        }
        return array
    }
    func incrementFrequency(step: Int = 1) {
        frequency += step
    }
}


func ==(lhs: Task, rhs: Task) -> Bool {
    return lhs.hashValue == rhs.hashValue
}



class LogTask {
    let taskId: Int
    let taskType: Task
    init(id: Int, type: Task) {
        self.taskId = id
        self.taskType = type
    }
}


class Event: Hashable {
    let id: Int
    let hashValue: Int
    let eventType: EventType
    var task: Task?
    var tasksSet = Set<Task>()
    var name = String()
    var frequency = 0
    init(id: Int, name: String, eventType: EventType) {
        self.id = id
        self.hashValue = id
        self.name = name
        self.eventType = eventType
    }
    func incrementFrequency(step: Int = 1) {
        frequency += step
    }
}


func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.hashValue == rhs.hashValue
}



class LogEvent {
    let id: Int
    var session: Session
    var task:Task!
    var event: Event
    var eventType: EventType
    var startTime: Double
    var sequenceInSession   = 0
    var duration            = 0.0
    var description: String {
        var string = ""
        string += "LogEvent \(id), session: \(session.id), task: \(task.id) \(task.name), event: \(event.id) \(event.name), type: NA, time: \(startTime)"
        return string
    }

    init(id:Int, session: Session, task: Task!, event: Event, eventType: EventType, startTime: Double) {
        self.id = id
        self.session = session
        self.task = task
        self.event = event
        self.eventType = eventType
        self.startTime = startTime
    }
}



enum EventType: String {
    case Screen = "screen"
    case Error  = "error"
    case Event  = "event"
    case Task   = "tasks"
    case Type   = "type"
    case None   = ""
}



class User {
    let userId: Int
    let longId: String
    init(id: Int, longId: String) {
        self.userId = id
        self.longId = longId
    }
}





class Model {
    
    var sessions            = [Session]()
    var tasks               = [Task]()
    var events              = [Event]()
    var logEvents           = [LogEvent]()
    var environment         : Environment
    
    var stats: String {
        var text = ""
        text += "Model has \n\(sessions.count) sessions\n"
        text += "\(tasks.count) tasks\n"
        text += "\(events.count) events\n"
        text += "\(logEvents.count) logEvents\n"
        return text
    }
    
    init(dataset: RawDataset, environment: Environment) {
        self.environment = environment
        let modelBuilder = ModelBuilder(dataset: dataset)
        modelBuilder.build()
        sessions    = modelBuilder.sessions
        tasks       = modelBuilder.tasks
        events      = modelBuilder.events
        logEvents   = modelBuilder.logEvents
    }
    
    var string: String {
        var sessionText = ""
        sessionText += "session,sequence,startTime,duration,task,event,eventType"
        for session in sessions {
            for logEvent in session.logEvents {
                sessionText +=  "\n\(logEvent.session.id),\(logEvent.sequenceInSession),\(logEvent.startTime),"
                sessionText +=  "\(logEvent.duration),\(logEvent.task.name),\(logEvent.event.name),\(logEvent.eventType)"
            }
        }
        sessionText += "\n"
        return sessionText
    }
    
    func selectSessions(numberOfEvents n: Int = 1) {
        // Select subset of sessions
        for session in sessions {
            if session.logEvents.count <= n {
                session.excluded = true
            }
        }
    }
    
    func sortedTasks() -> [Task] {
        // Debug: no sorting at first
        var array = [Task]()
        for task in tasks {
            array.append(task)
        }
        return array
    }
    
    func writeStringToFile() {
        do {
            try string.writeToURL(environment.URLForDataWithFileName("dataLayer1main.txt"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}
    }
    func printTasksFrequencies() {
        print("\nModel: Tasks Frequencies:\n")
        for task in tasks {
            print("task:", task.name, task.frequency)
        }
        print("\n")
    }
    
    var eventsDescription: String {
        var string = "Model Events Description:\n"
        for event in events.sort({$0.name < $1.name}) {
            string += "\nEvent: \(event.id), \(event.name) belongs to: \(event.tasksSet.count) tasks"
            for task in event.tasksSet {
                string += "\n\t\(task.id) \t\t\(task.name)"
            }
        }
        return string
    }

    var tasksDescription: String {
        var string = "Model Tasks Description:\n"
        for task in tasks.sort({$0.name < $1.name}) {
            string += "\nTask: \(task.id), \(task.name) has: \(task.eventsSet.count) events"
            for event in task.eventsSet.sort({$0.name < $1.name}) {
                string += "\n\t\(event.id) \t\t\(event.name)"
            }
        }
        return string
    }

    
    func matrix() {
        // This matrix stores the network of events
        // Dimensions: number of events + 2: There is fictive start event, all the events, then the fictive end event
        // Tasks are not considered, only events within sessions
        
        // Prepare the matrix  : TRANSFERRED
        let numberOfEvents = events.count
        let matrixDim = numberOfEvents + 2
        let endEventId = numberOfEvents + 1 // TODO: verify the numbering of event, etc (1 based)
        var matrix = [[Int]](count: matrixDim, repeatedValue:[Int](count: matrixDim, repeatedValue:Int()))
        
        
        // Fill the matrix with event frequencies
        var i = 0, j = 0
        for session in sessions {
            i = 0
            for logEvent in session.logEvents {
                j = logEvent.event.id
                matrix[i][j] += 1
                i = j
            }
            // Last 'end' event
            matrix[i][endEventId] += 1
            
        }
       
        // Generate the row labels : TRANSFERRED
        var labels = [String]()
        labels.append("Start")
        for event in events {
            labels.append(event.name)
        }
        labels.append("End")
        
        // Generate the row labels CSV file : TRANSFERRED
        var labelsCSV = labels[0]
        for i in 1..<labels.count  {
            labelsCSV += ",\(labels[i])"
        }
        
        // Generates the matrix as CSV: : TRANSFERRED
        var matrixCSV = ""
        for i in 0..<matrixDim {
            matrixCSV += "\(matrix[i][0])"
            for j in 1..<matrixDim {
                matrixCSV += ",\(matrix[i][j])"
            }
            matrixCSV += "\n"
        }
        
        // Save matrix to disk  : TRANSFERRED
        do {
            try labelsCSV.writeToURL(environment.URLForDataWithFileName("dataLayer2labels.csv"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}

        do {
            try matrixCSV.writeToURL(environment.URLForDataWithFileName("dataLayer2matrix.csv"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}
        
        // Print matrix to console
        print(matrixCSV)
    }
}




class Matrix {
    // Draft... Logic is being moved from the model object
    let model: Model
    let matrixDim: Int // TODO: old name, for compatibility, consider changing to 'size'
    var tasks: [Task]
    var eventArrays: [[Event]]
    // var cellValues: [[Int]]
    var matrixEvents: [Event]
    var columnsPerTask = [Int]()

    var matrix = [[Int]]() // TODO: old name, for compatibility, consider changing to 'cellValues'
    var unsortedMatrix = [[Int]]() // TODO: old name, for compatibility, consider changing to 'cellValues'
    var numberOfEvents = 0
    var endEventId = 0
    
    
    var labels = [String]()
    
    /*
    var CSVString: String {
        var string = ""
        string += "To be developped: string representation of matrix"
        return string
    }
     */
    
    init (model: Model) {
        // TODO: This section needs cleanup
        self.model = model
        self.matrixDim = model.events.count + 2
        tasks = [Task]()
        eventArrays = [[Event]]()
        matrixEvents = [Event]()
        
        numberOfEvents = model.events.count
        endEventId = numberOfEvents + 1
        
        //cellValues = [[Int]](count: matrixDim, repeatedValue:[Int](count: matrixDim, repeatedValue:Int()))
        buildMatrixEvents()
        buildLabels()
        
        matrix = [[Int]](count: matrixDim, repeatedValue:[Int](count: matrixDim, repeatedValue:Int())) // TODO: move this
        unsortedMatrix = [[Int]](count: matrixDim, repeatedValue:[Int](count: matrixDim, repeatedValue:Int())) // TODO: move this
        buildMatrices()


        endEventId = numberOfEvents + 1 // TODO: verify the numbering of event, etc (1 based)
        numberOfEvents = matrixEvents.count
        
        saveCSVToFile()
    }
    
    func buildMatrices() {
        // Transferred from model object
        // Algorithm needs to be updated
        
        // Build unsorted matrix
        // i and j are the id's of the events
        // i=0 and i=number of events + 1 are 'start' and 'end' events
        
        //var unsortedMatrix = [[Int]]()
        unsortedMatrix = [[Int]](count: matrixDim, repeatedValue:[Int](count: matrixDim, repeatedValue:Int()))
        var i = 0, j = 0
        for session in model.sessions {
            i = 0
            for logEvent in session.logEvents {
                j = logEvent.event.id
                unsortedMatrix[i][j] += 1
                i = j
            }
            // Last 'end' event
            unsortedMatrix[i][endEventId] += 1
        }
        
        // Fill sorted matrix
        
        // newEventOrder represent the new position of an event of the unsorted matrix
        var newEventOrder = [Int]()
        
        // 'start' event does not move:
        newEventOrder.append(0)
        
        // k is the indice in the unsorted matrix
        for k in 0..<numberOfEvents {
            newEventOrder.append(matrixEvents[k].id)
        }
        
        // 'end' event doesn't move
        newEventOrder.append(numberOfEvents + 1)
        print(newEventOrder)
        
        // fill the sorted matrix
        for i in 0..<matrixDim {
            for j in 0..<matrixDim {
                let l = newEventOrder[i]
                let m = newEventOrder[j]
                matrix[i][j] = unsortedMatrix[l][m]
            }
        }
    }
    
    func buildLabels() {
        // Generate the row labels
        labels.append("Start")
        for event in matrixEvents {
            labels.append(event.task!.name + " | " + event.name)
        }
        labels.append("End")
    }
    
    var labelsCSV: String {
        var string = labels[0]
        for i in 1..<labels.count  {
            string += ",\(labels[i])"
        }
        return string
    }
    
    var matrixCSV: String {
        // Generates the matrix as CSV:
        var string = ""
        for i in 0..<matrixDim {
            string += "\(matrix[i][0])"
            for j in 1..<matrixDim {
                string += ",\(matrix[i][j])"
            }
            string += "\n"
        }
        return string
    }
    var unsortedMatrixCSV: String {
        // Generates the matrix as CSV:
        var string = ""
        for i in 0..<matrixDim {
            string += "\(unsortedMatrix[i][0])"
            for j in 1..<matrixDim {
                string += ",\(unsortedMatrix[i][j])"
            }
            string += "\n"
        }
        return string
    }
    
    func saveCSVToFile() {
        do {
            try labelsCSV.writeToURL(model.environment.URLForDataWithFileName("dataLayer2labels.csv"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}
        do {
            try matrixCSV.writeToURL(model.environment.URLForDataWithFileName("dataLayer2matrix.csv"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}
        do {
            try unsortedMatrixCSV.writeToURL(model.environment.URLForDataWithFileName("dataLayer2unsortedMatrix.csv"), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file: \n\(error)")}
    }
    
    private func buildMatrixEvents() {
        tasks = model.sortedTasks()
        for task in tasks {
            let events = task.sortedEvents()
            eventArrays.append(events)
            matrixEvents.appendContentsOf(events)
            columnsPerTask.append(events.count)
        }
    }
    var matrixEventsString: String {
        var string = "\nMatrix events:\n"
        for event in matrixEvents {
            string += "\n" + event.name
        }
        return string
    }
    var headerDescription: String {
        var string = "\nMatrix events:\n"
        for event in matrixEvents {
            string += "\nTask: (\(event.task!.id)) \(event.task!.name) | Event: \(event.name)"
            //print(event.task!.id, event.task!.hashValue ,"Task: ", event.task!.name, "| Event:", event.name)
        }
        string += "\nColumns per task: \(columnsPerTask)"
        //print("Columns per task: ", columnsPerTask)
        return string
    }
}




class ModelBuilder {
    // Object method to build the model from the environement
    
    var dataset: RawDataset
    let dateFormatter =  NSDateFormatter()

    var sessions            = [Session]()
    var events              = [Event]()
    var tasks               = [Task]()
    var logEvents           = [LogEvent]()
    
    var sessionDict = [String : Session]()
    var eventDict   = [String : Event]()
    var userDict    = [String : User]()
    var taskDict    = [String : Task]()
   
    init(dataset: RawDataset) {
        self.dataset = dataset
    }
    func build() {
        var currentRecordNumber = 0
        initializeDictionaries()
        initDateFormatter()
        for record in dataset.records {
            guard record.session != "" else { break }
            currentRecordNumber += 1 // Could by replaced by iterate to get the index and remove currentRecordNumber
            
            // Update dictionaries and create object instances
            
            if taskDict[record.task] == nil {
                taskDict[record.task] = Task(id: taskDict.count + 1,
                                             name: record.task)
            }
            
            // To solve the issue of events belonging to multiple tasks,
            // the key for event in the dictionary is obtained 
            //by concatenating the event field value with the task id
            
            let eventKey = record.event + String(taskDict[record.task]!.id)
            if eventDict[eventKey] == nil {
                eventDict[eventKey] = Event(id: eventDict.count + 1,
                                            name: record.event,
                                            eventType: EventType.None) // TODO: replace with actual event type
            }

            if sessionDict[record.session] == nil {
                sessionDict[record.session] = Session(sessionID: sessionDict.count+1)
            }
            if userDict[record.user] == nil {
                userDict[record.user] = User(id: userDict.count + 1,
                                             longId: record.user == "" ? "None" : record.user)
            }
            let newLogEvent = LogEvent( id:         currentRecordNumber,
                                        session:    sessionDict[record.session]!,
                                        task:       taskDict[record.task]!,
                                        event:      eventDict[eventKey]!,
                                        eventType:  EventType.None,
                                        startTime:  timeInSecondsFromString(record.startTime))
            
            newLogEvent.session.logEvents.append(newLogEvent)
            logEvents.append(newLogEvent)
            
            // Updates relation from task to events (n-n)
            newLogEvent.event.tasksSet.insert(newLogEvent.task)
            newLogEvent.task.eventsSet.insert(newLogEvent.event)

            // Updates relation from an event to a task (n-1)
            newLogEvent.event.task = newLogEvent.task
            if newLogEvent.event.task != nil {
                newLogEvent.event.task!.incrementFrequency()
            }
        }
        sessions += sessionDict.values
        tasks += taskDict.values
        events += eventDict.values
        updateSessions()
    }

    func updateSessions() {
        for session in sessions {
            session.updateLogEventSequence()
        }
    }
    
    func initializeDictionaries() {
        taskDict[""] = Task(id: 1, name: "None")
    }
    
    func initDateFormatter() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func timeInSecondsFromString(string: String) -> Double {
        var theString = string
        // ! Remove newline from the end of the string:
        theString.removeAtIndex(theString.endIndex.predecessor())
        if let startTime = dateFormatter.dateFromString(theString) {
            return startTime.timeIntervalSince1970
        } else {
            return 0
        }
    }
}


