//
//  ContentView.swift
//  looky
//
//  Created by 沈力源 on 2025/7/28.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PhotoRecord.creationDate, ascending: false)],
        animation: .default)
    private var photoRecords: FetchedResults<PhotoRecord>
    
    @State private var showingCamera = false
    
    var body: some View {
        NavigationView {
            VStack {
                if photoRecords.isEmpty {
                    // 空状态
                    VStack(spacing: 30) {
                        Image(systemName: "camera.circle")
                            .font(.system(size: 100))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        VStack(spacing: 10) {
                            Text("还没有记录")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("点击下方按钮开始你的第一张照片记录")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                } else {
                    // 照片记录列表
                    List {
                        ForEach(photoRecords, id: \.id) { record in
                            PhotoRecordRow(record: record)
                        }
                        .onDelete(perform: deleteRecords)
                    }
                }
                
                Spacer()
                
                // 底部拍照按钮
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("快速记录")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("快看！")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCamera) {
                NavigationView {
                    CameraContainerView()
                }
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            offsets.map { photoRecords[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("删除失败: \(error)")
            }
        }
    }
}

// MARK: - 照片记录行视图
struct PhotoRecordRow: View {
    let record: PhotoRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图片
            if let imageData = record.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            }
            
            // 文字描述
            if let text = record.textDescription, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .lineLimit(nil)
            }
            
            // 时间
            HStack {
                Spacer()
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
