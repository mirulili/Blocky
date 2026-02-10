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
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Date Header
                    Text(formatDate(selectedDate))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)

                    // Photo Section
                    VStack(alignment: .leading, spacing: 8) {
                        
                        ZStack {    
                            
                            if let photo = photo {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    Text("사진 추가하기")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .frame(height: 300)
                        .onTapGesture {
                            showImagePicker = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            if descriptionText.isEmpty && !isFocused {
                                Text("오늘의 기억을 기록해보세요...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                            }
                            
                            TextEditor(text: $descriptionText)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .frame(height: 120)
                                .focused($isFocused)
                        }
                        .frame(height: 140)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            if let photo = photo {
                                photoStore.savePhoto(photo, for: selectedDate, with: descriptionText)
                                isFocused = false
                                dismiss()
                            }
                        }) {
                            Text("저장하기")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(photo == nil ? Color.gray : Color.blue)
                                .cornerRadius(16)
                                .shadow(color: (photo == nil ? Color.clear : Color.blue.opacity(0.3)), radius: 5, x: 0, y: 3)
                        }
                        .disabled(photo == nil)
                        
                        // Delete button (only shown if a photo already exists)
                        if photoStore.getPhotoData(for: selectedDate) != nil {
                            Button(action: {
                                photoStore.deletePhoto(for: selectedDate)
                                dismiss()
                            }) {
                                Text("삭제하기")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("기록 추가")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImgPicker(image: $photo)
        }
        .onAppear(perform: loadData)
        .onTapGesture {
            isFocused = false
        }
    }
    
    private func loadData() {
        guard let data = photoStore.getPhotoData(for: selectedDate) else { return }
        descriptionText = data.description
        photo = photoStore.loadImage(from: data.filename)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
