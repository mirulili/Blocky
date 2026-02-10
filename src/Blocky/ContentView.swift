//
//  ContentView.swift
//  Blocky
//
//  Created by Miru on 9/21/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var photoStore: PhotoStore
    @State private var displayDate: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var navigateToDetail = false
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7) // Reduced spacing
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                CalendarHeader(displayDate: $displayDate)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
                
                // Weekday Headers
                HStack(spacing: 0) {
                    ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                        Text(day)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textColor(for: index))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
                
                // Calendar Grid
                LazyVGrid(columns: columns, spacing: 5) { // Reduced spacing
                    ForEach(fetchDates(), id: \.self) { date in
                         if date.isCurrentMonth {
                            Button(action: {
                                selectedDate = date.date
                            }) {
                                DateCell(date: date, isSelected: calendar.isDate(date.date, inSameDayAs: selectedDate))
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Color.clear
                                .aspectRatio(9.0/16.0, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                // Footer
                HStack {
                    HStack {
                        Text("\(formatDate(selectedDate))")
                            .font(.callout)
                            .foregroundColor(.blue)
                            .padding(.leading, 20)
                        
                        
                        // Navigation Link Button
                        NavigationLink(destination: PhotoDetailView(selectedDate: selectedDate), isActive: $navigateToDetail) {
                            Button(action: {
                                navigateToDetail = true
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
            }
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemGray6).edgesIgnoringSafeArea(.all))
        }
    }
    
    private var daysOfWeek: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
    
    private func textColor(for index: Int) -> Color {
        if index == 0 { return .red }
        if index == 6 { return .blue }
        return .primary
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func fetchDates() -> [DateValue] {
        let month = calendar.dateComponents([.year, .month], from: displayDate)
        guard let firstDayOfMonth = calendar.date(from: month) else { return [] }
        
        var dates: [DateValue] = []
        
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numDays = range.count
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Dates from the previous month (padding)
        for i in 0..<(firstDayWeekday - 1) {
            let date = calendar.date(byAdding: .day, value: -((firstDayWeekday - 1) - i), to: firstDayOfMonth)!
            dates.append(DateValue(day: calendar.component(.day, from: date), date: date, isCurrentMonth: false))
        }
        
        // Dates for the current month
        for i in 1...numDays {
            let date = calendar.date(byAdding: .day, value: i - 1, to: firstDayOfMonth)!
            dates.append(DateValue(day: i, date: date, isCurrentMonth: true))
        }
        
        // Dates for the next month (padding)
        let totalCells = dates.count
        let remainingDays = (7 - (totalCells % 7)) % 7
        if remainingDays > 0 {
             for i in 1...remainingDays {
                let date = calendar.date(byAdding: .day, value: i, to: dates.last!.date)!
                dates.append(DateValue(day: calendar.component(.day, from: date), date: date, isCurrentMonth: false))
            }
        }
        
        return dates
    }
}

struct CalendarHeader: View {
    @Binding var displayDate: Date
    @State private var showDatePicker = false
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                 Text(dateString(from: displayDate))
                    .font(.system(size: 24, weight: .bold)) // Larger, bold title
                    .foregroundColor(.blue)
                    .onTapGesture { showDatePicker = true }
            }
            
            Spacer()
            
            Button(action: {
                displayDate = Date()
            }) {
                Text("오늘")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 15) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                Button(action: { changeMonth(by: 1) }) {
                     Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 10)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .sheet(isPresented: $showDatePicker) {
            YearMonthPickerView(displayDate: $displayDate, showPicker: $showDatePicker)
                .presentationDetents([.height(300)])
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월"
        return formatter.string(from: date)
    }
    
     private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: displayDate) {
            displayDate = newDate
        }
    }
}

struct YearMonthPickerView: View {
    @Binding var displayDate: Date
    @Binding var showPicker: Bool
    
    private let yearRange = (Calendar.current.component(.year, from: Date()) - 100)...(Calendar.current.component(.year, from: Date()) + 50)
    
    var body: some View {
        VStack {
            HStack {
                Picker("연도 선택", selection: Binding(
                    get: { Calendar.current.component(.year, from: displayDate) },
                    set: { newYear in
                        var components = Calendar.current.dateComponents([.year, .month, .day], from: displayDate)
                        components.year = newYear
                        displayDate = Calendar.current.date(from: components) ?? displayDate
                    }
                )) {
                    ForEach(Array(yearRange), id: \.self) { year in
                        Text("\(String(year))년").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 150)
                .clipped()
                
                Picker("월 선택", selection: Binding(
                    get: { Calendar.current.component(.month, from: displayDate) },
                    set: { newMonth in
                        var components = Calendar.current.dateComponents([.year, .month, .day], from: displayDate)
                        components.month = newMonth
                        displayDate = Calendar.current.date(from: components) ?? displayDate
                    }
                )) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()
            }
            
            Button("완료") { showPicker = false }
                .padding()
        }
    }
}


struct DateCell: View {
    @EnvironmentObject var photoStore: PhotoStore
    let date: DateValue
    let isSelected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                if let photoData = photoStore.getPhotoData(for: date.date),
                   let image = photoStore.loadImage(from: photoData.filename) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemBackground)) // Light gray for empty
                }
                
                // Border for selection
                 if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                }
                
                // Date Number
                Text("\(date.day)")
                     .font(.system(size: 14, weight: .semibold)) // Smaller font
                     .foregroundColor(hasImage ? .white : textColor(for: date.date))
                     .shadow(color: hasImage ? .black.opacity(0.5) : .clear, radius: 2, x: 0, y: 1)
                     .padding(6) // Padding from corners
            }
            .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip everything to rounded rect including image
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1) // Subtle shadow for depth
        }
        .aspectRatio(9.0/16.0, contentMode: .fit) // Enforce 9:16 aspect ratio
    }
    
    private var hasImage: Bool {
        photoStore.getPhotoData(for: date.date) != nil
    }
    
    private func textColor(for date: Date) -> Color {
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 { return .red }
        if weekday == 7 { return .blue }
        return .primary
    }
}

struct DateValue: Hashable {
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
}

// Preview
#Preview {
    ContentView()
        .environmentObject(PhotoStore())
}
