import SwiftUI

/// Displays a centered date label between message groups.
struct DateHeaderView: View {
    let date: Date
    let theme: AIChatTheme

    var body: some View {
        HStack {
            Spacer()
            Text(formattedDate)
                .font(.system(size: theme.timestampFontSize, weight: .medium))
                .foregroundStyle(theme.timestampColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(theme.secondaryBackgroundColor)
                )
            Spacer()
        }
        .padding(.top, 16)
        .accessibilityLabel("Conversation from \(formattedDate)")
    }

    private var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    VStack {
        DateHeaderView(date: Date(), theme: .light)
        DateHeaderView(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), theme: .light)
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
