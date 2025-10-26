import SwiftUI
import Combine

struct NotificationsTabView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    NotificationRow(
                        icon: "person.badge.plus",
                        title: "New follower",
                        subtitle: "John Doe started following you",
                        time: "2m ago",
                        isUnread: true
                    )
                    
                    NotificationRow(
                        icon: "heart.fill",
                        title: "Like received",
                        subtitle: "Someone liked your post",
                        time: "1h ago",
                        isUnread: true
                    )
                    
                    NotificationRow(
                        icon: "message.fill",
                        title: "New message",
                        subtitle: "You have a new message",
                        time: "3h ago",
                        isUnread: false
                    )
                    
                    NotificationRow(
                        icon: "calendar",
                        title: "Event reminder",
                        subtitle: "Team meeting in 30 minutes",
                        time: "5h ago",
                        isUnread: false
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Notifications")
        }
    }
}

#Preview {
    NavigationView {
        NotificationsTabView()
            .environmentObject(AuthenticationManager())
    }
}