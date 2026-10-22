import Foundation
import CoreData

/// Core Data manager for persisting Expert / Hair Specialist local attributes (such as Specialization)
/// without requiring backend API changes or modifying the remote database schema.
final class CoreDataExpertManager {
    static let shared = CoreDataExpertManager()
    
    private let container: NSPersistentContainer
    
    private init() {
        // Build managed object model programmatically so no external .xcdatamodeld file is required
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "ExpertSpecializationEntity"
        entity.managedObjectClassName = "NSManagedObject"
        
        let emailAttribute = NSAttributeDescription()
        emailAttribute.name = "email"
        emailAttribute.attributeType = .stringAttributeType
        emailAttribute.isOptional = false
        
        let specAttribute = NSAttributeDescription()
        specAttribute.name = "specialization"
        specAttribute.attributeType = .stringAttributeType
        specAttribute.isOptional = false
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = true
        
        entity.properties = [emailAttribute, specAttribute, createdAtAttribute]
        model.entities = [entity]
        
        container = NSPersistentContainer(name: "HairJourneyCoreData", managedObjectModel: model)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("⚠️ [CoreDataExpertManager] Failed to load store: \(error.localizedDescription)")
            } else {
                print("✅ [CoreDataExpertManager] Core Data store ready: \(description.url?.absoluteString ?? "")")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Save or update an expert's specialization in Core Data
    func saveSpecialization(email: String, specialization: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanEmail.isEmpty else { return }
        
        let context = container.viewContext
        context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "ExpertSpecializationEntity")
            request.predicate = NSPredicate(format: "email ==[c] %@", cleanEmail)
            
            do {
                let matches = try context.fetch(request)
                let entityObject = matches.first ?? NSEntityDescription.insertNewObject(forEntityName: "ExpertSpecializationEntity", into: context)
                entityObject.setValue(cleanEmail, forKey: "email")
                entityObject.setValue(specialization, forKey: "specialization")
                entityObject.setValue(Date(), forKey: "createdAt")
                
                try context.save()
                print("✅ [CoreData] Saved specialization '\(specialization)' for \(cleanEmail)")
            } catch {
                print("❌ [CoreData] Save error: \(error.localizedDescription)")
            }
        }
        
        // Also sync to ExpertSpecializationManager for instant UI reflection across views
        ExpertSpecializationManager.shared.setSpecialization(for: cleanEmail, specialization: specialization)
        UserDefaults.standard.set(specialization, forKey: "expert_spec_email_\(cleanEmail)")
    }
    
    /// Retrieve specialization from Core Data by expert email
    func getSpecialization(email: String) -> String? {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanEmail.isEmpty else { return nil }
        
        let context = container.viewContext
        var result: String?
        context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "ExpertSpecializationEntity")
            request.predicate = NSPredicate(format: "email ==[c] %@", cleanEmail)
            request.fetchLimit = 1
            if let match = try? context.fetch(request).first {
                result = match.value(forKey: "specialization") as? String
            }
        }
        return result
    }
}
