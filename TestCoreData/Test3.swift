//
//  Test3.swift
//  TestCoreData
//
//  Created by Sergey Garazha on 8/1/18.
//

import CoreData

class Test3 {
    let q1 = DispatchQueue(label: "com.test.db1", qos: DispatchQoS.default)
    let q2 = DispatchQueue(label: "com.test.db2", qos: DispatchQoS.default)
    
    let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var store1: NSPersistentStore?
    var store2: NSPersistentStore?
    
    lazy var coordinator1: NSPersistentStoreCoordinator = {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        let coordinator1 = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url1 = self.applicationDocumentsDirectory.appendingPathComponent("Yo1.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        store1 = try! coordinator1.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url1, options: options)
        return coordinator1
    }()
    lazy var coordinator2: NSPersistentStoreCoordinator = {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        let coordinator2 = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url2 = self.applicationDocumentsDirectory.appendingPathComponent("Yo2.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        store2 = try! coordinator2.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url2, options: options)
        return coordinator2
    }()
    
    var mocPrivate1: NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator1
        return managedObjectContext
    }
    var mocPrivate2: NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator2
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
    
    private func execute() -> Bool {
        var res1 = false
        var res2 = false
        
        q1.sync {
            let ctx = mocPrivate1
            let y = Yo(context: ctx)
            y.yo = "yo1 db"
            
            do {
                try ctx.save()
                res1 = true
            } catch {
                let nserror = error as NSError
                print("\(nserror)\n\n\(nserror.userInfo)")
                res1 = false
            }
        }
        
        q2.sync {
            let ctx = mocPrivate2
            let y2 = Yo(context: ctx)
            y2.yo = "yo2 db"
            
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
