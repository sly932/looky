import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    // 用于 SwiftUI 预览的内存数据存储
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 创建一些示例数据用于预览
        let samplePhoto = PhotoRecord(context: viewContext)
        samplePhoto.id = UUID()
        samplePhoto.textDescription = "这是一张示例照片"
        samplePhoto.creationDate = Date()
        samplePhoto.imagePath = "sample_image.jpg"
        
        do {
            try viewContext.save()
        } catch {
            // 预览数据保存失败不会影响 App 运行
            let nsError = error as NSError
            fatalError("预览数据创建失败: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LookyDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // 在生产环境中，应该优雅地处理此错误
                fatalError("Core Data 加载失败: \(error), \(error.userInfo)")
            }
        }
        
        // 自动合并来自父上下文的更改
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Core Data 操作扩展
extension PersistenceController {
    
    /// 保存视图上下文
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("保存失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// 创建新的照片记录
    func createPhotoRecord(image: Data?, textDescription: String, imagePath: String? = nil) -> PhotoRecord {
        let context = container.viewContext
        let photoRecord = PhotoRecord(context: context)
        
        photoRecord.id = UUID()
        photoRecord.textDescription = textDescription
        photoRecord.creationDate = Date()
        photoRecord.imagePath = imagePath
        photoRecord.imageData = image
        
        return photoRecord
    }
} 