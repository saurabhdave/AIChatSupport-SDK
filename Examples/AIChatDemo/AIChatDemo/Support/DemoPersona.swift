import AIChatSupport
import SwiftUI

/// A demo domain (e-commerce, travel, …). Each persona drives the bot identity, product
/// knowledge, suggested prompts, welcome message, and brand — demonstrating that one SDK adapts
/// to any context. (On the mock provider the replies are canned; set an API key to see the
/// per-domain `AppContext` shape the actual answers.)
struct DemoPersona: Identifiable {
    let id: String
    let tabTitle: String
    let tabSystemImage: String
    let botName: String
    let botSubtitle: String
    let avatarSystemImage: String
    let appContext: AppContext
    let suggestedPrompts: [String]
    let welcomeMessages: [WelcomeMessage]
    /// Brand tokens used by the "Branded theme" demo.
    let brandTheme: HostAppTheme

    func makeConfiguration(
        hostAppTheme: HostAppTheme? = nil,
        presentationStyle: PresentationStyle = .sheet,
        delegate: (any AIChatDelegate)? = nil
    ) -> AIChatConfiguration {
        AIChatConfiguration(
            provider: DemoBackend.provider,
            botName: botName,
            botSubtitle: botSubtitle,
            botAvatarStyle: .sfSymbol(avatarSystemImage),
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

// MARK: - Personas

extension DemoPersona {

    /// E-commerce support.
    static let shopEasy = DemoPersona(
        id: "shopeasy",
        tabTitle: "ShopEasy",
        tabSystemImage: "bag.fill",
        botName: "ShopEasy Support",
        botSubtitle: "Typically replies instantly",
        avatarSystemImage: "bag.fill",
        appContext: AppContext(
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
        ),
        suggestedPrompts: ["Track my order", "Start a return", "Find my size"],
        welcomeMessages: [
            WelcomeMessage(text: "👋 Hi! I'm the ShopEasy assistant. How can I help?", delay: 0.3)
        ],
        brandTheme: HostAppTheme(
            brandPrimaryColor: Color(red: 1.0, green: 0.42, blue: 0.21),
            brandSurfaceColor: Color(red: 0.98, green: 0.96, blue: 0.94),
            brandOnPrimaryColor: .white,
            headingFontWeight: .bold,
            cornerRadiusStyle: .pill
        )
    )

    /// Travel concierge — a deliberately different domain, tone, and brand.
    static let wanderly = DemoPersona(
        id: "wanderly",
        tabTitle: "Wanderly",
        tabSystemImage: "airplane",
        botName: "Wanderly Concierge",
        botSubtitle: "Your 24/7 travel assistant",
        avatarSystemImage: "airplane.departure",
        appContext: AppContext(
            appName: "Wanderly",
            appDescription: "A trip-planning and booking assistant for flights, hotels, and itineraries.",
            companyName: "Wanderly Travel Co.",
            websiteURL: "https://wanderly.example.com",
            supportEmail: "help@wanderly.example.com",
            productCategories: ["Travel", "Bookings"],
            primaryUseCases: ["Flight booking", "Hotel search", "Itinerary planning"],
            keyFeatures: ["24/7 trip support", "Price-drop alerts", "Free cancellation on select fares"],
            pricingInfo: "Free to plan. Wanderly Plus: $12/mo for premium support.",
            doNotDiscussList: ["competitor pricing"],
            escalationTriggers: ["speak to an agent", "talk to a human"],
            handoffMessage: "I'll connect you with a Wanderly travel specialist right away.",
            tonePersonality: .friendly,
            faqs: [
                FAQ(question: "How do I change my flight?",
                    answer: "Open Trips, select your booking, and tap Change Flight to see options and fees."),
                FAQ(question: "What's the cancellation policy?",
                    answer: "Select fares offer free cancellation within 24 hours of booking.")
            ]
        ),
        suggestedPrompts: ["Plan a weekend trip", "Find flights to Tokyo", "Change my booking"],
        welcomeMessages: [
            WelcomeMessage(text: "✈️ Hi! I'm Wanderly, your travel concierge. Where to next?", delay: 0.3)
        ],
        brandTheme: HostAppTheme(
            brandPrimaryColor: Color(red: 0.0, green: 0.55, blue: 0.55),
            brandSurfaceColor: Color(red: 0.94, green: 0.97, blue: 0.97),
            brandOnPrimaryColor: .white,
            headingFontWeight: .bold,
            cornerRadiusStyle: .rounded
        )
    )
}
