import SwiftUI
import UIKit
import Combine

struct PhotoData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let filename: String
    let description: String
}

@MainActor
class PhotoStore: ObservableObject {
    @Published var photos: [PhotoData] = []
    
    let photosKey = "SavedPhotos"
    
    init() {
        loadPhotos()
    }
    
    func savePhoto(_ image: UIImage, for date: Date, with description: String) {
        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: url)
            
            // 기존 동일 날짜 사진 삭제 (중복 방지)
            photos.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
            
            let photoData = PhotoData(id: id, date: dateOnly(date), filename: filename, description: description)
            photos.append(photoData)
            savePhotos()
        }
    }

    
    func getImage(for date: Date) -> UIImage? {
        if let photo = photos.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            let url = getDocumentsDirectory().appendingPathComponent(photo.filename)
            if let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    private func savePhotos() {
        if let data = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(data, forKey: photosKey)
        }
    }
    
    private func loadPhotos() {
        if let data = UserDefaults.standard.data(forKey: photosKey),
           let decoded = try? JSONDecoder().decode([PhotoData].self, from: data) {
            photos = decoded
        }
    }
    
    func getPhotoData(for date: Date) -> PhotoData? {
        photos.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
    
    func loadImage(from filename: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func dateOnly(_ date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components)!
    }
}
