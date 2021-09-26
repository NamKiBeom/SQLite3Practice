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

// MARK: - CREATE

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

// MARK: - INSERT

let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"

func insert() {
    var insertStatement: OpaquePointer?
    
    if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
        let id: Int32 = 1
        let name: NSString = "Ray"
        
        sqlite3_bind_int(insertStatement, 1, id)
        sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
        
        if sqlite3_step(insertStatement) ==  SQLITE_DONE {
            print("\nSuccessfully inserted row.")
        } else {
            print("\nCould not insert row.")
        }
    } else {
        print("\nINSERT statement is not prepared.")
    }
    
    sqlite3_finalize(insertStatement)
}

// MARK: - SELECT

let queryStatementString = "SELECT * FROM Contact;"

func query() {
    var queryStatement: OpaquePointer?
    
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(queryStatement, 0)
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("query result is nil.")
                return
            }
            
            let name = String(cString: queryResultCol1)
            print("\nQuery Result: \(id) | \(name)")
        } else {
            print("\nQuery returned no results.")
        }
    } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("\nQuery is not prepared \(errorMessage)")
    }
    
    sqlite3_finalize(queryStatement)
}

let db = openDatabase()
createTable()
insert()
query()
