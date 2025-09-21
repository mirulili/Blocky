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
            // 사진 영역 (탭 시 갤러리 열림)
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
                }
            }
            .frame(height: 300)
            .padding()
            .onTapGesture {
                showImagePicker = true
            }
            
            // 설명 입력란
            TextEditor(text: $descriptionText)
                .frame(height: 120)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .focused($isFocused)
                .padding(.horizontal)
            
            // 저장 버튼
            if photo != nil {
                Button("완료") {
                    if let image = photo {
                        photoStore.savePhoto(image, for: selectedDate, with: descriptionText)
                        isFocused = false
                        dismiss()
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("사진 추가")
        .sheet(isPresented: $showImagePicker) {
            ImgPicker(image: $photo)
        }
        .background(
            Color.white
                .onTapGesture {
                    isFocused = false
                }
        )
    }
}
