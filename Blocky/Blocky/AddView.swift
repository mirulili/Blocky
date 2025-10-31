import SwiftUI
import UIKit

struct AddView: View {
    @State private var photo: UIImage? = nil
    @State private var showImagePicker = false
    @State private var descriptionText: String = ""
    @State private var selectedDate: Date
    @FocusState private var isFocused: Bool
    @EnvironmentObject var photoStore: PhotoStore
    @Environment(\.dismiss) var dismiss
    
    init(date: Date) {
        _selectedDate = State(initialValue: date)
    }
    
    var body: some View {
        VStack {
            // Photo area (opens gallery on tap)
            ZStack {
                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(height: 300)
            .padding()
            .onTapGesture {
                showImagePicker = true
            }
            
            // Description input field
            TextEditor(text: $descriptionText)
                .frame(height: 120)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .focused($isFocused)
                .padding(.horizontal)
            
            // Button area
            VStack {
                // Save button
                if photo != nil {
                    Button("완료") {
                        photoStore.savePhoto(photo!, for: selectedDate, with: descriptionText)
                        isFocused = false
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Delete button (only shown if a photo already exists)
                if photoStore.getPhotoData(for: selectedDate) != nil {
                    Button("삭제") {
                        photoStore.deletePhoto(for: selectedDate)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("사진 추가")
        .sheet(isPresented: $showImagePicker) {
            ImgPicker(image: $photo)
        }
        .onAppear(perform: loadData)
        .contentShape(Rectangle()) // Added to recognize tap gestures on the entire area
        .onTapGesture {
            isFocused = false
        }
    }
    
    private func loadData() {
        guard let data = photoStore.getPhotoData(for: selectedDate) else { return }
        descriptionText = data.description
        photo = photoStore.loadImage(from: data.filename)
    }
}
