//
//  SQLite3PracticeApp.swift
//  Shared
//
//  Created by 남기범 on 2021/09/25.
//

import SwiftUI

@main
struct SQLite3PracticeApp: App {
    var database: SQLiteDatabase? {
        guard let path = path
        else { return  nil }
        
        do {
            let sample = try SQLiteDatabase.open(path: path)
            print("Successfully opened connection to database.")
            return sample
        } catch SQLiteError.OpenDatabase(message: _) {
            print("Unable to open database.")
        } catch {
            print("another error.")
        }
        
        return nil
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(db: database)
        }
    }
}
