//
//  vuxExtensions.swift
//  uxDataProcess
//
//  Created by Ivan on 02/05/16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import Foundation

/*
protocol FileSavable {
    var environment: Environment {get set}
    var string: String {get}
    func saveToFile(filename: String)
}

extension FileSavable {
    func saveToFile(filename: String) {
        environment.saveDataString(string, withFilename: filename)
    }
}
*/
protocol CSVRepresentable {
    var CSVString: String {get}
}

protocol CSVSavable: CSVRepresentable {
    func saveCSVToFile(url: NSURL)
}

extension CSVSavable {
    func saveCSVToFile(url: NSURL) {
        do {
            try CSVString.writeToURL(url, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {print("Error writing to file: \n\(error)")}
        
    }
}

