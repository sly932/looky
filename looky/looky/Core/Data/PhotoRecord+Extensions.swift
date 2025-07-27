import Foundation
import CoreData

// MARK: - PhotoRecord 扩展
extension PhotoRecord {
    
    /// 获取格式化的创建时间
    var formattedDate: String {
        guard let date = creationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// 检查是否有图片数据
    var hasImage: Bool {
        return imageData != nil || (imagePath != nil && !imagePath!.isEmpty)
    }
} 