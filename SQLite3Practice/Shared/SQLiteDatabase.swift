//
//  SQLiteDatabase.swift
//  SQLite3Practice
//
//  Created by 남기범 on 2021/09/26.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
        
    }
}

var path: String? {
    return try? FileManager.default
        .url(for: FileManager.SearchPathDirectory.documentDirectory,
             in: FileManager.SearchPathDomainMask.userDomainMask,
             appropriateFor: nil,
             create: false)
        .appendingPathComponent("mytopic.db")
        .path
}
let testDatabase = try! SQLiteDatabase.open(path: path!)
