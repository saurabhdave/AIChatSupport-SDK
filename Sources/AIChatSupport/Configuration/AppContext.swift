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

// MARK: - Codable

extension TonePersonality: Codable, Equatable {
    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw.lowercased() {
        case "professional": self = .professional
        case "friendly": self = .friendly
        case "concise": self = .concise
        case "technical": self = .technical
        case "empathetic": self = .empathetic
        default: self = .custom(raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .professional: try c.encode("professional")
        case .friendly: try c.encode("friendly")
        case .concise: try c.encode("concise")
        case .technical: try c.encode("technical")
        case .empathetic: try c.encode("empathetic")
        case .custom(let value): try c.encode(value)
        }
    }
}

extension FAQ: Codable {
    private enum CodingKeys: String, CodingKey { case question, answer }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(question: try c.decode(String.self, forKey: .question),
                  answer: try c.decode(String.self, forKey: .answer))
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(question, forKey: .question)
        try c.encode(answer, forKey: .answer)
    }
}

extension UserInfo: Codable {
    private enum CodingKeys: String, CodingKey {
        case userID, name, email, plan, accountCreatedAt, customAttributes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            userID: try c.decodeIfPresent(String.self, forKey: .userID),
            name: try c.decodeIfPresent(String.self, forKey: .name),
            email: try c.decodeIfPresent(String.self, forKey: .email),
            plan: try c.decodeIfPresent(String.self, forKey: .plan),
            accountCreatedAt: try c.decodeIfPresent(Date.self, forKey: .accountCreatedAt),
            customAttributes: try c.decodeIfPresent([String: String].self, forKey: .customAttributes) ?? [:]
        )
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(userID, forKey: .userID)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(email, forKey: .email)
        try c.encodeIfPresent(plan, forKey: .plan)
        try c.encodeIfPresent(accountCreatedAt, forKey: .accountCreatedAt)
        try c.encode(customAttributes, forKey: .customAttributes)
    }
}

extension AppContext: Codable {
    private enum CodingKeys: String, CodingKey {
        case appName, appDescription, appVersion, companyName, websiteURL, supportEmail,
             supportPhoneNumber, productCategories, primaryUseCases, keyFeatures, pricingInfo,
             targetAudience, doNotDiscussList, escalationTriggers, handoffMessage,
             responseLanguage, tonePersonality, faqs, currentUserInfo
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            appName: try c.decodeIfPresent(String.self, forKey: .appName) ?? "",
            appDescription: try c.decodeIfPresent(String.self, forKey: .appDescription) ?? "",
            appVersion: try c.decodeIfPresent(String.self, forKey: .appVersion),
            companyName: try c.decodeIfPresent(String.self, forKey: .companyName),
            websiteURL: try c.decodeIfPresent(String.self, forKey: .websiteURL),
            supportEmail: try c.decodeIfPresent(String.self, forKey: .supportEmail),
            supportPhoneNumber: try c.decodeIfPresent(String.self, forKey: .supportPhoneNumber),
            productCategories: try c.decodeIfPresent([String].self, forKey: .productCategories) ?? [],
            primaryUseCases: try c.decodeIfPresent([String].self, forKey: .primaryUseCases) ?? [],
            keyFeatures: try c.decodeIfPresent([String].self, forKey: .keyFeatures) ?? [],
            pricingInfo: try c.decodeIfPresent(String.self, forKey: .pricingInfo),
            targetAudience: try c.decodeIfPresent(String.self, forKey: .targetAudience),
            doNotDiscussList: try c.decodeIfPresent([String].self, forKey: .doNotDiscussList) ?? [],
            escalationTriggers: try c.decodeIfPresent([String].self, forKey: .escalationTriggers) ?? [],
            handoffMessage: try c.decodeIfPresent(String.self, forKey: .handoffMessage)
                ?? "Let me connect you with a team member who can help.",
            responseLanguage: try c.decodeIfPresent(String.self, forKey: .responseLanguage) ?? "en-US",
            tonePersonality: try c.decodeIfPresent(TonePersonality.self, forKey: .tonePersonality) ?? .friendly,
            faqs: try c.decodeIfPresent([FAQ].self, forKey: .faqs) ?? [],
            currentUserInfo: try c.decodeIfPresent(UserInfo.self, forKey: .currentUserInfo)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(appName, forKey: .appName)
        try c.encode(appDescription, forKey: .appDescription)
        try c.encodeIfPresent(appVersion, forKey: .appVersion)
        try c.encodeIfPresent(companyName, forKey: .companyName)
        try c.encodeIfPresent(websiteURL, forKey: .websiteURL)
        try c.encodeIfPresent(supportEmail, forKey: .supportEmail)
        try c.encodeIfPresent(supportPhoneNumber, forKey: .supportPhoneNumber)
        try c.encode(productCategories, forKey: .productCategories)
        try c.encode(primaryUseCases, forKey: .primaryUseCases)
        try c.encode(keyFeatures, forKey: .keyFeatures)
        try c.encodeIfPresent(pricingInfo, forKey: .pricingInfo)
        try c.encodeIfPresent(targetAudience, forKey: .targetAudience)
        try c.encode(doNotDiscussList, forKey: .doNotDiscussList)
        try c.encode(escalationTriggers, forKey: .escalationTriggers)
        try c.encode(handoffMessage, forKey: .handoffMessage)
        try c.encode(responseLanguage, forKey: .responseLanguage)
        try c.encode(tonePersonality, forKey: .tonePersonality)
        try c.encode(faqs, forKey: .faqs)
        try c.encodeIfPresent(currentUserInfo, forKey: .currentUserInfo)
    }
}
