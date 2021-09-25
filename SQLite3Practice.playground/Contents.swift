import UIKit
import SQLite3

var dbPath: String? {
    return try? FileManager.default
        .url(for: FileManager.SearchPathDirectory.documentDirectory,
             in: FileManager.SearchPathDomainMask.userDomainMask,
             appropriateFor: nil,
             create: false)
        .appendingPathComponent("mytopic.db")
        .path
}

func openDatabase() -> OpaquePointer? {
    var db: OpaquePointer?
    guard let path = dbPath else {
        return nil
    }
    
    if sqlite3_open(path, &db) == SQLITE_OK {
        return db
    }
    
    return nil
}

let createTableString = """
    CREATE TABLE Contact(
    Id INT PRIMARY KEY NOT NULL,
    Name CHAR(255));
    """

func createTable() {
    var createTableStatement: OpaquePointer?
    guard let db = openDatabase() else { return }
    
    if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
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

let db = openDatabase()
createTable()
