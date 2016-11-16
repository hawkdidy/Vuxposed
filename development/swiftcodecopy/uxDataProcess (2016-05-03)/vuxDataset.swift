//
//  vuxDataset.swift
//  uxDataProcess
//
//  Created by Ivan on 02/05/16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import Foundation


enum DelimiterString: String {
    case Tab = "\t"
    case LineFeed = "\n"
    case Comma = ","
    case Space = " "
}


enum EnvironmentType: String {
    case Production     = "Prod"
    case Development    = "Dev"
    case Test           = "Test"
}


struct Environment {
    var environmentType     : EnvironmentType
    var baseDirectoryURL    : NSURL
    var dataDirectoryURL    : NSURL {
        return baseDirectoryURL.URLByAppendingPathComponent("Data/" + environmentType.rawValue)
    }
    init(baseDirectoryURL: NSURL, environmentType: EnvironmentType) {
        self.baseDirectoryURL = baseDirectoryURL
        self.environmentType = environmentType
    }
    func URLForDataWithFileName(filename: String) -> NSURL {
        return baseDirectoryURL.URLByAppendingPathComponent("Data/" + environmentType.rawValue).URLByAppendingPathComponent(filename)
    }
    func saveDataString(string: String, withFilename filename: String) {
        let url = URLForDataWithFileName(filename)
        do {
            try string.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {print("error")}
    }
}



enum Field: Int {
    // Raw data file field identification, the cases must be in the same order as in the raw file (unless Int values are specified individually
    case session = 0    // 'sessionID' in raw file
    case id             // 'sequenceID' is a unique record identifier, it is not useful to keep it
    case task           // 'taskID'
    case event          // 'activityID'
    case user           // 'userID'
    case eventType      // 'type'
    case startTime      // 'startTime'
}



struct Record  {
    var session:    String = ""
    var task:       String = ""
    var event:      String = ""
    var eventType:  String = ""
    var user:       String = ""
    var startTime:  String = ""
    
    init(string: String) {
        let fields       = string.componentsSeparatedByString(",")
        self.session     = fields[Field.session.rawValue]
        self.task        = trimPrefix(fields[Field.task.rawValue])
        self.event       = fields[Field.eventType.rawValue] + "-" + trimPrefix(fields[Field.event.rawValue])
        self.user        = fields[Field.user.rawValue]
        self.eventType   = fields[Field.eventType.rawValue]
        self.startTime   = fields[Field.startTime.rawValue]
    }
    
    func trimPrefix(string: String) -> String {
        // Removes '(Driving) ' from the beginning of the string
        let firstCharacter: Character = "("
        let n = 10
        var newString = string
        if string != "" {
            if string[string.startIndex] == firstCharacter {
                newString = string.substringFromIndex(string.startIndex.advancedBy(n))
            }
        }
        return newString
    }
}



class RawDataset {
    var records = [Record]()
    var fileBaseName: String
    var fileExtension: String
    var numberOfFiles: Int
    var hasHeader: Bool
    let environment: Environment
    var maxNumberOfRecords = 500
    
    
    init(fileBaseName: String, fileExtension: String, numberOfFiles: Int, hasHeader: Bool, maxNumberOfRecords: Int, environment: Environment) {
        self.fileBaseName = fileBaseName
        self.fileExtension = fileExtension
        self.numberOfFiles = numberOfFiles
        self.hasHeader = hasHeader
        self.maxNumberOfRecords = maxNumberOfRecords
        self.environment = environment
    }
    func readRecords() {
        var currentNumberOfRecords = 0
        for index in 1...numberOfFiles {
            let rawData: String?
            let url = environment.dataDirectoryURL.URLByAppendingPathComponent(fileBaseName + String(index) + "." + fileExtension)
            do {
                rawData = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) as String
                var components = rawData!.componentsSeparatedByString("\n")
                if hasHeader {
                    components.removeFirst()
                }
                for component in components {
                    guard currentNumberOfRecords < maxNumberOfRecords else { continue }
                    if component != "" {
                        records.append(Record(string: component))
                        currentNumberOfRecords += 1
                    }
                }
            }
            catch {
                rawData = nil
                print("Error while reading raw data file:\n \(error)\n")}
        }
    }
}


