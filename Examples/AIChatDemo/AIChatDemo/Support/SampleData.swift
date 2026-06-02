import AIChatSupport
import SwiftUI

/// Shared content + a configuration factory used by every demo.
enum SampleData {

    static var appContext: AppContext {
        AppContext(
            appName: "ShopEasy",
            appDescription: "A curated fashion marketplace for independent designers.",
            companyName: "ShopEasy Inc.",
            websiteURL: "https://shopeasy.example.com",
            supportEmail: "help@shopeasy.example.com",
            productCategories: ["Fashion", "Marketplace"],
            primaryUseCases: ["Order tracking", "Returns", "Sizing help"],
            keyFeatures: ["Free 30-day returns", "Same-day city delivery"],
            pricingInfo: "Free to shop. ShopEasy Pro: $9.99/mo",
            doNotDiscussList: ["competitor pricing"],
            escalationTriggers: ["speak to a human", "talk to an agent"],
            handoffMessage: "I'll connect you with a ShopEasy team member right away.",
            tonePersonality: .friendly,
            faqs: [
                FAQ(question: "How do I track my order?",
                    answer: "Open the Orders tab, tap your order, and you'll see live tracking."),
                FAQ(question: "What is the return policy?",
                    answer: "Free returns within 30 days under Orders ▸ Return Item.")
            ]
        )
    }

    static let suggestedPrompts = ["Track my order", "Start a return", "Find my size"]

    static let welcomeMessages = [
        WelcomeMessage(text: "👋 Hi! I'm the ShopEasy assistant. How can I help?", delay: 0.3)
    ]

    /// Builds a base configuration; each demo overrides only what it showcases.
    static func configuration(
        theme: AIChatTheme = .light,
        hostAppTheme: HostAppTheme? = nil,
        presentationStyle: PresentationStyle = .sheet,
        delegate: (any AIChatDelegate)? = nil
    ) -> AIChatConfiguration {
        AIChatConfiguration(
            provider: DemoBackend.provider,
            botName: "ShopEasy Support",
            botSubtitle: "Typically replies instantly",
            botAvatarStyle: .sfSymbol("bag.fill"),
            theme: theme,
            hostAppTheme: hostAppTheme,
            appContext: appContext,
            presentationStyle: presentationStyle,
            welcomeMessages: welcomeMessages,
            suggestedPrompts: suggestedPrompts,
            enableFeedback: true,
            showTypingIndicator: true,
            delegate: delegate
        )
    }
}
