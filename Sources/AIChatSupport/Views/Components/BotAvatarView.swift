import SwiftUI

/// Renders the bot's avatar based on the configured AvatarStyle.
struct BotAvatarView: View {
    let avatarStyle: AvatarStyle
    let theme: AIChatTheme

    var body: some View {
        Group {
            switch avatarStyle {
            case .sfSymbol(let name):
                Circle()
                    .fill(theme.primaryColor)
                    .frame(width: theme.avatarSize, height: theme.avatarSize)
                    .overlay(
                        Image(systemName: name)
                            .font(.system(size: theme.avatarSize * 0.45))
                            .foregroundStyle(.white)
                    )
            case .assetName(let name):
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: theme.avatarSize, height: theme.avatarSize)
                    .clipShape(Circle())
            case .initials(let text):
                Circle()
                    .fill(theme.primaryColor)
                    .frame(width: theme.avatarSize, height: theme.avatarSize)
                    .overlay(
                        Text(String(text.prefix(2)))
                            .font(.system(size: theme.avatarSize * 0.35, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            case .none:
                EmptyView()
            }
        }
        .accessibilityLabel("Bot avatar")
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        BotAvatarView(avatarStyle: .sfSymbol("bubble.left.fill"), theme: .light)
        BotAvatarView(avatarStyle: .initials("AI"), theme: .light)
    }
    .padding()
}
