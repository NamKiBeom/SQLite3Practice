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
    
    func createTable() {
        let createTableString = """
        CREATE TABLE Contact(
        Id INT PRIMARY KEY NOT NULL,
        Name CHAR(255));
        """

        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(dbPointer, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\nContact table created.")
            } else {
                print("\nContact table is not created.")
            }
        } else {
            print("\nCREATE TABLE statement is not prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func insert() {
        var insertStatement: OpaquePointer?
        let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"

        if sqlite3_prepare_v2(dbPointer, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let id: Int32 = 1
            let name: NSString = "Ray"
            sqlite3_bind_int(insertStatement, 1, id)
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func query() {
        var queryStatement: OpaquePointer?
        let queryStatementString = "SELECT * FROM Contact;"
        
        
        if sqlite3_prepare_v2(dbPointer, queryStatementString, -1, &queryStatement, nil) ==
            SQLITE_OK {
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                
                guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                    print("Query result is nil")
                    return
                }
                let name = String(cString: queryResultCol1)
                // 5
                print("\nQuery Result:")
                print("\(id) | \(name)")
            } else {
                print("\nQuery returned no results.")
            }
        } else {
            // 6
            let errorMessage = String(cString: sqlite3_errmsg(dbPointer))
            print("\nQuery is not prepared \(errorMessage)")
        }
        // 7
        sqlite3_finalize(queryStatement)
    }

    func update() {
        var updateStatement: OpaquePointer?
        let updateStatementString = "UPDATE Contact SET Name = 'Adam' WHERE Id = 1;"
        if sqlite3_prepare_v2(dbPointer, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\nSuccessfully updated row.")
            } else {
                print("\nCould not update row.")
            }
        } else {
            print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
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
