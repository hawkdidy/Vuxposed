//
//  AppDelegate.swift
//  uxDataProcess
//
//  Created by Ivan on 10/03/16.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Insert code here to initialize your application
        
        // PROGRAM STARTS HERE. TODO: consider creating an object and moving the code
        
        // These debug variables allow to run the processing on a limited numbers of records
        var debugCounter = 0
        let debugMaxRecords = 10000000
        let processStartTime = NSDate()
        var saveDataToProduction = true
        //let saveDataToDevelopment = true TODO: implement this later, currently only one environment saved at a time
        
        
        // Raw data file field identification, the cases must be in the same order as in the raw file (unless Int values are specified individually
        enum Field: Int {
            case session = 0    // 'sessionID' in raw file
            case sequence       // 'sequenceID' is a unique record identifier, it is not useful to keep it
            case task           // 'taskID'
            case event          // 'activityID'
            case user           // 'userID'
            case eventType      // 'type'
            case startTime      // 'startTime'
        }

        
        // File locations
        var dataDirectory = String()
        if saveDataToProduction == true {
            dataDirectory   = "/Users/ivan/Dropbox/Shared/Visual/development/dataPro/"
        } else {
            dataDirectory   = "/Users/ivan/Dropbox/Shared/Visual/development/dataDev/"
        }

        let inputFile   = "sequence1.csv"
        let inputFile2   = "sequence2.csv"
        let outputFile  = "dataLayer1.txt"
        let reportFile  = "dataLayer1report.txt"
        
        let inputPath       = dataDirectory + inputFile
        let inputPath2       = dataDirectory + inputFile2
        let outputPath      = dataDirectory + outputFile
        let reportPath      = dataDirectory + reportFile
        
        // Data Strings
        var uxRawText   = String()
        var reportText  = String()
        var outputText  = String()
        
        // Variables for recoding
        var recordNr = 1
        var lastSessionNr   = 0
        var lastTaskNr      = 0
        var lastEventNr     = 0
        var lastEventTypeNr = 0
        var lastUserNr      = 0
        
        // These are dictionraies that contain the unique field values as keys, and the integer code as value
        var sessions    = [String : Int]()
        var tasks       = [String : Int]()
        var events      = [String : Int]()
        var users       = [String : Int]()
        var eventTypes  = [String : Int]()
       

        // Internal representation of logs
        struct Log {
            var id          = 0
            var session     = 0
            var task        = 0
            var event       = 0
            var user        = 0
            var eventType   = 0
            var startTime   = NSDate()
        }
        
        // Complete logs (contains the recoded dataset)
        var logs    = [Log]()

        
        // Prepare date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"


        // MAIN PROCESSING *****************************************************************************
        
        // Read the file from disk
        do {
            uxRawText = try NSString(contentsOfFile: inputPath, encoding: NSUTF8StringEncoding) as String
            uxRawText += try NSString(contentsOfFile: inputPath2, encoding: NSUTF8StringEncoding) as String
        }
        catch {print("Error reading from file")}
        
        // Parse the file into an array of records
        let records = uxRawText.componentsSeparatedByString("\n")

        // Loop through records
        for record in records {
            if debugCounter > debugMaxRecords {break} // TODO: Remove or transform as feature
            debugCounter += 1
            if record != "" {
                // Parse records into fields
                let field = record.componentsSeparatedByString(",")
                // Ignore the first row because it contains the headers TODO: improve this
                if recordNr == 1 {
                    print(record)
                } else {
                    
                    // Create a new log
                    var newLog = Log()
                    newLog.id = recordNr - 1
                    
                    // Encode Session
                    if let session = sessions[field[Field.session.rawValue]] {
                        newLog.session = session
                    } else {
                        lastSessionNr += 1
                        sessions[field[Field.session.rawValue]] = lastSessionNr
                        newLog.session = lastSessionNr
                    }
                    
                    
                    // Encode task
                    if let task = tasks[field[Field.task.rawValue]] {
                        newLog.task = task
                    } else {
                        lastTaskNr += 1
                        tasks[field[Field.task.rawValue]] = lastTaskNr
                        newLog.task = lastTaskNr
                    }
                    /*
                    //Debug code:
                    if row <= 20 {
                        print("task: \(field[Field.task.rawValue]) -> \(newLog.task)")
                    }
                    */
                    
                    // Encode activity
                    if let activity = events[field[Field.event.rawValue]] {
                        newLog.event = activity
                    } else {
                        lastEventNr += 1
                        events[field[Field.event.rawValue]] = lastEventNr
                        newLog.event = lastEventNr
                    }
                    
                    // Encode user
                    if let user = users[field[Field.user.rawValue]] {
                        newLog.user = user
                    } else {
                        lastUserNr += 1
                        users[field[Field.user.rawValue]] = lastUserNr
                        newLog.user = lastUserNr
                    }
                    
                    // Encode type
                    if let type = eventTypes[field[Field.eventType.rawValue]] {
                        newLog.eventType = type
                    } else {
                        lastEventTypeNr += 1
                        eventTypes[field[Field.eventType.rawValue]] = lastEventTypeNr
                        newLog.eventType = lastEventTypeNr
                    }


                    // Encode date
                    var dateField = field[Field.startTime.rawValue]
                    // ! Remove newline from the end of the string
                    dateField.removeAtIndex(dateField.endIndex.predecessor())
                    if let startTime = dateFormatter.dateFromString(dateField) {
                        newLog.startTime = startTime
                    } else {
                    }

                    /*/ Start debug
                    if row <= 20 {
                    print("date: \(dateField) -> \(newLog.startTime) -> \(newLog.startTime.timeIntervalSince1970)")
                    }
                    // End debug */
                    
                    
                    // Add recoded log to the logs array
                    
                    logs.append(newLog)
                }
            }
            recordNr  += 1
        }
        
        
        // Make data layer String
        outputText += "session, task, event, eventType, user, startTime"
        for log in logs {
            outputText = outputText + "\n\(log.session)" + ",\(log.task)" + ",\(log.event)" + ",\(log.eventType)" + ",\(log.user)" + ",\(log.startTime.timeIntervalSince1970)"
        }
        
        
        // Make report String
        reportText = "Report for the generation of the data layer 1 "
        if saveDataToProduction == true {
            reportText += " (productive)\n"
        } else {
            reportText += " (development)\n"
        }
        reportText += "Completed: \(NSDate())"
        reportText += "\nNumber of processed records: \(records.count)"
        reportText += "\nNumber of different sessions: \(sessions.count)"
        reportText += "\nNumber of different tasks: \(tasks.count)"
        reportText += "\nNumber of different events: \(events.count)"
        reportText += "\nNumber of different users: \(users.count)"
        reportText += "\nNumber of different event types: \(eventTypes.count)"
        reportText += "\n\nDEBUGGING: number of records processed is limited to max: \(debugMaxRecords - 1) records"
        reportText += "\nTotal processing time (including file operations, excluding app launch and GUI): \(NSDate().timeIntervalSince1970 - processStartTime.timeIntervalSince1970) seconds"

        
        // Write strings to disk
        do {
            try reportText.writeToFile(reportPath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file")}

        do {
            try outputText.writeToFile(outputPath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("error writing to file")}

        
        // Write to console
        print("Input path: \(inputPath)")
        print("Output path: \(outputPath)\n")
        print(reportText)
        /*
        print("")
        for (taskID, taskNr) in tasks {
            print("\(taskNr) \t \(taskID)")
        }
        */
    }

    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}


/*
if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
let inputPath   = dir.stringByAppendingPathComponent(inputFile);
let outputPath  = dir.stringByAppendingPathComponent(outputFile)
*/

/*
print("\nMax size of UInt8 = \(UInt8.max)")
print("\nMax size of UInt16 = \(UInt16.max)")
print("\nMax size of UInt32 = \(UInt32.max)")
print("\nMax size of UInt64 = \(UInt64.max)")
print("\nMax size of Int = \(Int.max)")
*/


