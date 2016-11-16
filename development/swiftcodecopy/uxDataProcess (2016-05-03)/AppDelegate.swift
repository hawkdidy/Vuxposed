//
//  AppDelegate.swift
//  uxDataProcess
//
//  Created by Ivan on 10/03/16.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let environment = Environment(baseDirectoryURL: NSURL(fileURLWithPath: "/Users/ivan/Dropbox/Shared/Visual/Development"),
                                      environmentType: EnvironmentType.Development)
        let rawDataset = RawDataset(fileBaseName: "sequence", fileExtension: "csv", numberOfFiles: 2, hasHeader: true, maxNumberOfRecords: 1000, environment: environment)
        rawDataset.readRecords()
        
        let model = Model(dataset: rawDataset, environment: environment)
        
        

        // Prints to console:
        model.printTasksFrequencies()
        //print(model.stats)
        //print(model.string)
        //print(model.eventsDescription)
        //print()
        //print(model.tasksDescription)
        
        //print("Model: number of events:" ,model.events.count)

        
        //model.writeStringToFile()
        //model.matrix()
        
        
        let matrix = Matrix(model: model)
        
        //print(matrix.matrixEventsString)
        
        print(matrix.headerDescription)
        
        print(matrix.unsortedMatrixCSV)
        
        //print(matrix.CSVString)
        //matrix.saveCSVToFile(environment.URLForDataWithFileName("matrixTestFile.txt"))

        environment.saveDataString(model.tasksDescription, withFilename: "tasksDescription.txt")
        environment.saveDataString(model.eventsDescription, withFilename: "eventsDescription.txt")
        environment.saveDataString(model.string, withFilename: "modelDescription.txt")
        environment.saveDataString(matrix.headerDescription, withFilename: "matrixHeaderDescription.txt")

        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
        // Insert code here to tear down your application
    }
}

