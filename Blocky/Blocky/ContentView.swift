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
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarHeader(displayDate: $displayDate)
                
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 5)
                
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(fetchDates(), id: \.self) { date in
                        NavigationLink(destination: PhotoDetailView(selectedDate: date.date)) {
                            DateCell(date: date)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .navigationBarHidden(true) // Hide the default navigation bar title because we use a custom header
        }
    }
    
    private var daysOfWeek: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
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
        let remainingDays = 42 - dates.count // Based on a 6-week (42-day) grid
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
    @State private var showYearPicker = false
    @State private var showMonthPicker = false
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(yearString(from: displayDate))
                    .onTapGesture { showYearPicker = true }
                
                Text(monthString(from: displayDate))
                    .onTapGesture { showMonthPicker = true }
            }
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            
            Spacer()
            
            Button("오늘") {
                displayDate = Date()
            }
            .padding(.horizontal, 8)
            
            Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left") }
            
            Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right") }
        }
        .padding()
        .sheet(isPresented: $showYearPicker) {
            YearPickerView(displayDate: $displayDate, showPicker: $showYearPicker)
                .presentationDetents([.height(250)]) // Adjust sheet height
        }
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerView(displayDate: $displayDate, showPicker: $showMonthPicker)
                .presentationDetents([.height(250)]) // Adjust sheet height
        }
    }
    
    private func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter.string(from: date)
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: displayDate) {
            displayDate = newDate
        }
    }
}

struct YearPickerView: View {
    @Binding var displayDate: Date
    @Binding var showPicker: Bool
    
    private let yearRange = (Calendar.current.component(.year, from: Date()) - 100)...(Calendar.current.component(.year, from: Date()) + 50)
    
    var body: some View {
        VStack {
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
            Button("완료") { showPicker = false }
                .padding()
        }
    }
}

struct MonthPickerView: View {
    @Binding var displayDate: Date
    @Binding var showPicker: Bool
    
    var body: some View {
        VStack {
            MonthPicker(displayDate: $displayDate)
            Button("완료") { showPicker = false }
                .padding()
        }
    }
}

struct DateCell: View {
    @EnvironmentObject var photoStore: PhotoStore
    let date: DateValue
    
    var body: some View {
        // Use a transparent view as a base to define the frame size first.
        Color.clear
            .aspectRatio(9.0 / 16.0, contentMode: .fit) // Change to 9:16 aspect ratio
            .overlay(
                ZStack(alignment: .topTrailing) {
                    if let photoData = photoStore.getPhotoData(for: date.date),
                       let image = photoStore.loadImage(from: photoData.filename) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.1))
                    }
                    
                    Text("\(date.day)")
                        .font(.caption)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                        .foregroundColor(.white)
                        .padding(4)
                        .opacity(date.isCurrentMonth ? 1 : 0) // Hide the number if it's not in the current month
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(date.isCurrentMonth ? 1 : 0.3) // Dim if not in the current month
    }
}

struct DateValue: Hashable {
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
}

extension DateFormatter {
    static var monthYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월"
        return formatter
    }
}

struct MonthPicker: View {
    @Binding var displayDate: Date
    
    var body: some View {
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
    }
}

#Preview {
    ContentView()
        .environmentObject(PhotoStore())
}
