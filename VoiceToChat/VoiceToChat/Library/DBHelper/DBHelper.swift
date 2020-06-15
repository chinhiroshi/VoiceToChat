//
//  DBHelper.swift
//  VoiceToChat
//
//  Created by Shree on 01/04/20.
//  Copyright © 2020 Shree. All rights reserved.
//
//  https://medium.com/@imbilalhassan/saving-data-in-sqlite-db-in-ios-using-swift-4-76b743d3ce0e
//

import UIKit
import Foundation
import SQLite3

class DBHelper {
    
    init()
    {
        db = openDatabase()
        createUserInfoTable()
        createChatTable()
    }

    let dbPath: String = "VoiceToChat.sqlite"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer? {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
//MARK: - User Information
    func createUserInfoTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS UserInfo(userId INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("UserInfo table created.")
            } else {
                print("UserInfo table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertUserInfo(data:ModelUserList) {
        let insertStatementString = "INSERT INTO UserInfo (name) VALUES (?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            //sqlite3_bind_text(insertStatement, 1, (data.userId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 1, (data.strUserName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func readUserInfo() -> [ModelUserList] {
        let queryStatementString = "SELECT * FROM UserInfo;"
        var queryStatement: OpaquePointer? = nil
        var arrUserList : [ModelUserList] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                //let userId = sqlite3_column_int(queryStatement, 0)
                //let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let userId = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                
                arrUserList.append(ModelUserList.init(strUserName: name, userId: Int(userId)))
                print("Query Result:")
                print("\(userId) | \(name)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return arrUserList
    }
    
    func deleteUserByID(userId:Int) {
        let deleteStatementStirng = "DELETE FROM UserInfo WHERE userId = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, Int32(userId))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
//MARK: - Chat Information
    func createChatTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Chat(messageId INTEGER PRIMARY KEY AUTOINCREMENT,userId INTEGER,message TEXT,sendDate TEXT, sendTime TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Chat table created.")
            } else {
                print("Chat table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertChatInfo(data:ModelChat,userId:Int) {
        let insertStatementString = "INSERT INTO Chat (userId,message,sendDate,sendTime) VALUES (?,?,?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            //sqlite3_bind_text(insertStatement, 1, (data.userId as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 1, Int32(userId))
            sqlite3_bind_text(insertStatement, 2, (data.strMessage as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (data.strDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (data.strTime as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func readChat(userId:Int) -> [ModelChat] {
        let queryStatementString = "SELECT * FROM Chat WHERE userId=\(userId);"
        var queryStatement: OpaquePointer? = nil
        var arrChat : [ModelChat] = []
        print("Chat Query Result:")
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                //let userId = sqlite3_column_int(queryStatement, 0)
                //let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let messageId = sqlite3_column_int(queryStatement, 0)
                let strMessage = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let strDate = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let strTime = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))

                arrChat.append(ModelChat.init(messageId: Int(messageId), strMessage: strMessage,strDate: strDate,strTime: strTime))
                print("\(messageId) | \(strDate) | \(strTime) | \(strMessage)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return arrChat
    }
}
