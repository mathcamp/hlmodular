//
//  DBTable.swift
//  HLModular
//
//  Created by Ben Garrett on 7/10/15.
//  Copyright (c) 2015 Mathcamp. All rights reserved.
//

import Foundation

public class HLDB {

  public class DB {
    var queue: FMDatabaseQueue?
    let fileName: String
    let dbPath: String
    
    public enum Result {
      case Success
      case Items([NSDictionary])
      case Error(Int, String)
    }
    
    public init(fileName: String) {
      self.fileName = fileName
      let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
      self.dbPath = documentsFolder.stringByAppendingPathComponent(self.fileName)
    }
    
    func getQueue() -> FMDatabaseQueue? {
      if queue == nil {
        queue = FMDatabaseQueue(path: self.dbPath)
      }
      return queue
    }
    
    // do a query that does not return results without using a transaction
    public func updateWithoutTx(query: String, args:NSArray = NSArray()) -> Future<Result> {
      let p = Promise<Result>()
      getQueue()?.inDatabase() {
        db in
        
        if !db.executeUpdate(query, withArgumentsInArray:args) {
          println("DB Query \(self.fileName) failed: \(db.lastErrorMessage())")
          p.success(Result.Error(Int(db.lastErrorCode()), db.lastErrorMessage()))
          return
        }
        p.success(Result.Success)
      }
      
      return p.future
    }
    
    // do a query that does not return result using a transaction and rollback upon failure
    public func update(query: String, args:NSArray = NSArray()) -> Future<Result> {
      let p = Promise<Result>()
      getQueue()?.inTransaction() {
        db, rollback in
        
        if !db.executeUpdate(query, withArgumentsInArray:args) {
          rollback.initialize(true)
          println("DB Query \(self.fileName) failed: \(db.lastErrorMessage())")
          p.success(Result.Error(Int(db.lastErrorCode()), db.lastErrorMessage()))
          return
        }
        p.success(Result.Success)
      }
      
      return p.future
    }
    
    // do a select style query that returns result
    public func query(query: String, args:NSArray = NSArray()) -> Future<Result> {
      let p = Promise<Result>()
      getQueue()?.inDatabase() {
        db in
        
        if let rs = db.executeQuery(query, withArgumentsInArray:args) {
          var items = [NSDictionary]()
          while rs.next() {
            items.append(rs.resultDictionary())
          }
          p.success(Result.Items(items))
        } else {
          println("DB Query \(self.fileName) failed: \(db.lastErrorMessage())")
          p.success(Result.Error(Int(db.lastErrorCode()), db.lastErrorMessage()))
        }
      }
      
      return p.future
    }
    
    func testDatabaseQueue() {
      
      
      
      queue?.inTransaction() {
        db, rollback in
        
        for i in 0 ..< 5 {
          if !db.executeUpdate("insert into test (a) values (?)", withArgumentsInArray: ["Row \(i)"]) {
            println("insert \(i) failure: \(db.lastErrorMessage())")
            rollback.initialize(true)
            return
          }
        }
      }
      
      // let's try inserting rows, but deliberately fail half way and make sure it rolls back correctly
      
      queue?.inTransaction() {
        db, rollback in
        
        for i in 5 ..< 10 {
          if !db.executeUpdate("insert into test (a) values (?)", withArgumentsInArray: ["Row \(i)"]) {
            println("insert \(i) failure: \(db.lastErrorMessage())")
            rollback.initialize(true)
            return
          }
          
          if (i == 7) {
            rollback.initialize(true)
          }
        }
      }
    }
    
  }

  public class Entity {
    let fields: [String: AnyObject] = [:]
    
    public init(fields: [String: AnyObject] = [:]) {
      self.fields = fields
    }

    public func toFields() -> [String: AnyObject] {
      // override this in subclass
      return [:]
    }
    
    func boolValue(fieldName: String, defaultValue: Bool = false) -> Bool {
      var outValue = defaultValue
      if let v = fields[fieldName] as? Bool {
        outValue = v
      }
      return outValue
    }
    
    func intValue(fieldName: String, defaultValue: Int = 0) -> Int {
      var outValue = defaultValue
      if let v = fields[fieldName] as? Int {
        outValue = v
      }
      return outValue
    }

    func floatValue(fieldName: String, defaultValue: Float = 0) -> Float {
      var outValue = defaultValue
      if let v = fields[fieldName] as? Float {
        outValue = v
      }
      return outValue
    }
    
    func doubleValue(fieldName: String, defaultValue: Double = 0) -> Double {
      var outValue = defaultValue
      if let v = fields[fieldName] as? Double {
        outValue = v
      }
      return outValue
    }
    
    func stringValue(fieldName: String, defaultValue: String = "") -> String {
      var outValue = defaultValue
      if let v = fields[fieldName] as? String {
        outValue = v
      }
      return outValue
    }
  }
  
  public class DBTable {
    public enum Type: String {
      case Integer = "INT"
      case Real = "REAL"
      case Text = "TEXT"
      case Blob = "BLOB"
    }
    
    public enum Index {
      case None
      case Primary
      case Unique
      case Index
      case Packed
      case Private
    }
    
    public enum Default {
      case None
      case NonNull
      case Value(AnyObject)
    }
    
    public struct Field {
      let name: String
      let type: Type
      let index: Index
      let defaultValue: Default
    }
    
    public struct Row {
      let fields: [String: AnyObject] = [:]
    }
    
    public let name: String
    public let primaryKey: String
    public let definition: [String: Field] = [:]
    public let db: DB
    
    lazy var fieldNames: [String] = self.definition.keys.array
    lazy var fieldNamesStr: String = ",".join(self.fieldNames)
    
    public init(db: DB, name: String, fields:[Field]) {
      self.db = db
      self.name = name
      
      var foundPrimaryKey = false
      primaryKey = ""
      for field in fields {
        definition[field.name] = field
        if !foundPrimaryKey && field.index == .Primary {
          primaryKey = field.name
          foundPrimaryKey = true
        }
      }
      let packedDataFieldName = "packeddata"
      definition[packedDataFieldName] = Field(name: packedDataFieldName, type: .Blob, index: .Private, defaultValue: .NonNull)
      
      // add a primary key if there wasn't one
      if !foundPrimaryKey {
        primaryKey = "id"
        definition[primaryKey] = Field(name: primaryKey, type: .Text, index: .Primary, defaultValue: .NonNull)
      }
    }
    
    var createTableQueryString: String {
      var fields: [String] = []
      for (name, field) in definition {
        let fieldType = field.type.rawValue
        var uniqueStr = ""
        switch field.index {
          case .Unique:
             uniqueStr = " UNIQUE"
          default:
            break
        }
        var fieldDefault = ""
        switch field.defaultValue {
          case .None:
            break
          case .NonNull:
            fieldDefault = " NOT NULL"
          case .Value(let v):
            fieldDefault = " DEFAULT \(v)"
        }
        fields.append("\(field.name) \(fieldType)\(uniqueStr)\(fieldDefault)")
      }
      let fieldsStr = ",".join(fields)
      return "CREATE TABLE \(name) (fieldsStr);"
    }
    
    public func create() {
      db.updateWithoutTx(createTableQueryString)
    }
    
    public func drop() {
      db.updateWithoutTx("DROP TABLE \(name)")
    }
    
    func rowFields(r: Row) -> String {
      // TODO: implement packed
      var fieldStrArr = [String]()
      for (fieldName, field) in definition {
        switch field.type {
          case .Integer:
            var value = 0
            if let v = r.fields[fieldName] as? Int {
              value = v
            } else {
              switch field.defaultValue {
                case .Value(let v):
                  if let v = v as? Int {
                    value = v
                  }
                default:
                  break
              }
            }
            fieldStrArr.append("\(value)")
          case .Real:
            var value: Double = 0.0
            if let v = r.fields[fieldName] as? Double {
              value = v
            } else {
              switch field.defaultValue {
              case .Value(let v):
                if let v = v as? Double {
                  value = v
                }
              default:
                break
              }
            }
            fieldStrArr.append("\(value)")
            break
          case .Text:
            var value = ""
            if let v = r.fields[fieldName] as? String {
              value = v
            } else {
              switch field.defaultValue {
              case .Value(let v):
                if let v = v as? String {
                  value = v
                }
              default:
                break
              }
            }
            fieldStrArr.append("\"\(value)\"")
            break
          case .Blob:
            // TODO: implement blobs
            fieldStrArr.append("\"NOBLOBS\"")
            break
        }
      }
      return ",".join(fieldStrArr)
    }
    
    public func insert(rows: [Row]) -> Future<DB.Result> {
      let query = "INSERT INTO \(name) (\(fieldNamesStr)) values (?)"
      var args = [String]()
      for row in rows {
        let rowFieldsStr = rowFields(row)
        args.append("(\(rowFieldsStr))")
      }
      return db.update(query, args:args)
    }
    
    public func update(rows: [Row]) -> Future<DB.Result> {
      // TODO: implement this!
      var query = "INSERT INTO \(name) (\(fieldNamesStr)) values (?)"
      var args = [String]()
      for row in rows {
        let rowFieldsStr = rowFields(row)
        args.append("(\(rowFieldsStr))")
      }
      return db.update(query, args:args)
    }
    
    public func select(whereStr: String) -> Future<DB.Result> {
      var finalWhereString = whereStr
      if countElements(finalWhereString) > 0 {
        finalWhereString = " WHERE \(whereStr)"
      }
      let query = "SELECT * FROM \(name)\(whereStr)"
      return db.query(query)
    }
  }
}
