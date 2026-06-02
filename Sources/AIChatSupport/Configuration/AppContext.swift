import Foundation

/// A Q&A pair injected into the system prompt as product knowledge.
public struct FAQ: Identifiable, Sendable {
    public let id: UUID
    public let question: String
    public let answer: String

    public init(question: String, answer: String) {
        self.id = UUID()
        self.question = question
        self.answer = answer
    }
}

/// Contextual information about the currently signed-in user.
public struct UserInfo: Sendable {
    public var userID: String?
    public var name: String?
    public var email: String?
    /// e.g. "Pro", "Free"
    public var plan: String?
    public var accountCreatedAt: Date?
    /// Arbitrary extra metadata passed to the assistant.
    public var customAttributes: [String: String]

    public init(
        userID: String? = nil,
        name: String? = nil,
        email: String? = nil,
        plan: String? = nil,
        accountCreatedAt: Date? = nil,
        customAttributes: [String: String] = [:]
    ) {
        self.userID = userID
        self.name = name
        self.email = email
        self.plan = plan
        self.accountCreatedAt = accountCreatedAt
        self.customAttributes = customAttributes
    }
}

/// Controls the assistant's tone and communication style.
public enum TonePersonality: Sendable {
    case professional
    case friendly
    case concise
    case technical
    case empathetic
    /// Freeform personality description injected directly into the prompt.
    case custom(String)

    var description: String {
        switch self {
        case .professional: return "professional and formal"
        case .friendly: return "friendly, warm, and approachable"
        case .concise: return "concise and to the point"
        case .technical: return "technical and precise"
        case .empathetic: return "empathetic and supportive"
        case .custom(let desc): return desc
        }
    }
}

/// Product and behavioral knowledge injected into every conversation's system prompt.
public struct AppContext: Sendable {

    // MARK: – Product Identity

    public var appName: String
    public var appDescription: String
    public var appVersion: String?
    public var companyName: String?
    public var websiteURL: String?
    public var supportEmail: String?
    public var supportPhoneNumber: String?

    // MARK: – Domain Knowledge

    public var productCategories: [String]
    public var primaryUseCases: [String]
    public var keyFeatures: [String]
    public var pricingInfo: String?
    public var targetAudience: String?

    // MARK: – Behavioral Rules

    public var doNotDiscussList: [String]
    public var escalationTriggers: [String]
    public var handoffMessage: String
    public var responseLanguage: String
    public var tonePersonality: TonePersonality

    // MARK: – FAQ Knowledge Base

    public var faqs: [FAQ]

    // MARK: – Runtime User Context

    public var currentUserInfo: UserInfo?

    public init(
        appName: String = "",
        appDescription: String = "",
        appVersion: String? = nil,
        companyName: String? = nil,
        websiteURL: String? = nil,
        supportEmail: String? = nil,
        supportPhoneNumber: String? = nil,
        productCategories: [String] = [],
        primaryUseCases: [String] = [],
        keyFeatures: [String] = [],
        pricingInfo: String? = nil,
        targetAudience: String? = nil,
        doNotDiscussList: [String] = [],
        escalationTriggers: [String] = [],
        handoffMessage: String = "Let me connect you with a team member who can help.",
        responseLanguage: String = "en-US",
        tonePersonality: TonePersonality = .friendly,
        faqs: [FAQ] = [],
        currentUserInfo: UserInfo? = nil
    ) {
        self.appName = appName
        self.appDescription = appDescription
        self.appVersion = appVersion
        self.companyName = companyName
        self.websiteURL = websiteURL
        self.supportEmail = supportEmail
        self.supportPhoneNumber = supportPhoneNumber
        self.productCategories = productCategories
        self.primaryUseCases = primaryUseCases
        self.keyFeatures = keyFeatures
        self.pricingInfo = pricingInfo
        self.targetAudience = targetAudience
        self.doNotDiscussList = doNotDiscussList
        self.escalationTriggers = escalationTriggers
        self.handoffMessage = handoffMessage
        self.responseLanguage = responseLanguage
        self.tonePersonality = tonePersonality
        self.faqs = faqs
        self.currentUserInfo = currentUserInfo
    }

    /// Compiles this context into a structured system prompt block.
    internal func buildSystemPromptBlock() -> String {
        let allEmpty = appName.isEmpty && appDescription.isEmpty
            && companyName == nil && websiteURL == nil && supportEmail == nil
            && supportPhoneNumber == nil && productCategories.isEmpty
            && primaryUseCases.isEmpty && keyFeatures.isEmpty
            && pricingInfo == nil && targetAudience == nil
            && faqs.isEmpty && doNotDiscussList.isEmpty
            && escalationTriggers.isEmpty

        if allEmpty && currentUserInfo == nil { return "" }

        var lines: [String] = []

        if !allEmpty {
            lines.append("[PRODUCT CONTEXT]")

            var identityParts: [String] = []
            if !appName.isEmpty { identityParts.append(appName) }
            if let company = companyName, !company.isEmpty {
                identityParts.append(identityParts.isEmpty ? company : "by \(company)")
            }
            if !identityParts.isEmpty {
                lines.append("App: \(identityParts.joined(separator: " "))")
            }

            if !appDescription.isEmpty { lines.append("Description: \(appDescription)") }
            if let v = appVersion { lines.append("Version: \(v)") }
            if let url = websiteURL { lines.append("Website: \(url)") }

            var supportParts: [String] = []
            if let email = supportEmail { supportParts.append(email) }
            if let phone = supportPhoneNumber { supportParts.append(phone) }
            if !supportParts.isEmpty { lines.append("Support: \(supportParts.joined(separator: " | "))") }

            if !productCategories.isEmpty {
                lines.append("Categories: \(productCategories.joined(separator: ", "))")
            }
            if !primaryUseCases.isEmpty {
                lines.append("Primary Use Cases: \(primaryUseCases.joined(separator: ", "))")
            }
            if !keyFeatures.isEmpty {
                lines.append("Key Features:")
                for feature in keyFeatures {
                    lines.append("  - \(feature)")
                }
            }
            if let pricing = pricingInfo { lines.append("Pricing: \(pricing)") }
            if let audience = targetAudience { lines.append("Audience: \(audience)") }

            if !faqs.isEmpty {
                lines.append("")
                lines.append("[KNOWLEDGE BASE]")
                for faq in faqs {
                    lines.append("Q: \(faq.question)")
                    lines.append("A: \(faq.answer)")
                }
            }

            lines.append("")
            lines.append("[BEHAVIORAL RULES]")
            lines.append("Tone: \(tonePersonality.description)")
            lines.append("Response Language: \(responseLanguage)")

            if !doNotDiscussList.isEmpty {
                lines.append("Do NOT discuss: \(doNotDiscussList.joined(separator: ", "))")
            }
            if !escalationTriggers.isEmpty {
                lines.append("If the user mentions any of \(escalationTriggers.joined(separator: ", ")), respond with exactly:")
                lines.append("  \"\(handoffMessage)\"")
            }
        }

        if let user = currentUserInfo {
            lines.append("")
            lines.append("[CURRENT USER]")
            if let name = user.name { lines.append("Name: \(name)") }
            if let email = user.email { lines.append("Email: \(email)") }
            if let plan = user.plan { lines.append("Plan: \(plan)") }
            if let createdAt = user.accountCreatedAt {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                lines.append("Member Since: \(formatter.string(from: createdAt))")
            }
            for (key, value) in user.customAttributes.sorted(by: { $0.key < $1.key }) {
                lines.append("\(key): \(value)")
            }
        }

        return lines.joined(separator: "\n")
    }
}
