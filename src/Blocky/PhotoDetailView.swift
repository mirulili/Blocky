import SwiftUI

struct PhotoDetailView: View {
    @EnvironmentObject var photoStore: PhotoStore
    let selectedDate: Date
    
    @State private var photoData: PhotoData?
    
    var body: some View {
        VStack(spacing: 20) {
            if let data = photoData, let image = photoStore.loadImage(from: data.filename) {
                // If a photo exists
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
                Text(data.description)
                    .padding(.horizontal)
                
                Spacer()
                
            } else {
                // If no photo exists
                Spacer()
                Text("사진이 없습니다.")
                    .foregroundColor(.gray)
                
                NavigationLink(destination: AddView(date: selectedDate)) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("사진 추가하기")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
        }
        .navigationTitle(formattedDate(selectedDate))
        .navigationBarItems(trailing: editButton)
        .onAppear(perform: loadPhotoData)
    }
    
    // Edit button
    @ViewBuilder
    private var editButton: some View {
        if photoData != nil {
            NavigationLink(destination: AddView(date: selectedDate)) {
                Text("수정")
            }
        }
    }
    
    private func loadPhotoData() {
        self.photoData = photoStore.getPhotoData(for: selectedDate)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

#Preview {
    PhotoDetailView(selectedDate: Date())
        .environmentObject(PhotoStore())
}