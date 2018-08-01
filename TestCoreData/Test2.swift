//
//  Execute2.swift
//  TestCoreData
//
//  Created by Sergey Garazha on 8/1/18.
//

import UIKit
import CoreData

class Test2 {
    let q = DispatchQueue(label: "com.test.db", qos: DispatchQoS.default)
    let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var store1: NSPersistentStore?
    var store2: NSPersistentStore?
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let url1 = self.applicationDocumentsDirectory.appendingPathComponent("Yo1.sqlite")
        let url2 = self.applicationDocumentsDirectory.appendingPathComponent("Yo2.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        store1 = try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url1, options: options)
        store2 = try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url2, options: options)
        
        return coordinator
    }()
    
    lazy var moc: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    var mocPrivate: NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    func start() -> Bool {
        for _ in 1...10 {
            if !execute() {
                return false
            }
        }
        return true
    }
    
    func execute() -> Bool {
        var res1 = false
        var res2 = false
        
        q.sync {
            let ctx = mocPrivate
            let y = Yo(context: ctx)
            y.yo = "yo1 db"
            ctx.assign(y, to: store1!)
            
            do {
                try ctx.save()
                res1 = true
            } catch {
                let nserror = error as NSError
                print("\(nserror)\n\n\(nserror.userInfo)")
                res1 = false
            }
        }
        
        q.sync {
            let ctx = mocPrivate
            let y2 = Yo(context: ctx)
            y2.yo = "yo2 db"
            ctx.assign(y2, to: store2!)
            
            do {
                try ctx.save()
                res2 = true
            } catch {
                let nserror = error as NSError
                print("\(nserror)\n\n\(nserror.userInfo)")
                res2 = false
            }
        }
        
        return res1 && res2
    }
}
