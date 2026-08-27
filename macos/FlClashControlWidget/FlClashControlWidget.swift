import AppIntents
import SwiftUI
import WidgetKit

private let flClashWidgetDefaults = UserDefaults(
    suiteName: FlClashControlWidgetStore.appGroupIdentifier
)

struct FlClashWidgetStatus {
    let isRunning: Bool
    let profileName: String
    let hasProfile: Bool
    let pendingFeedbackUntil: TimeInterval
    let requestedRunning: Bool
    let requestedRunningUntil: TimeInterval

    var isPending: Bool {
        pendingFeedbackUntil > Date().timeIntervalSince1970
    }

    var isUsingRequestedState: Bool {
        requestedRunningUntil > Date().timeIntervalSince1970
    }

    var displayIsRunning: Bool {
        isUsingRequestedState ? requestedRunning : isRunning
    }

    static var current: FlClashWidgetStatus {
        FlClashWidgetStatus(
            isRunning: FlClashControlWidgetStore.isRunning,
            profileName: FlClashControlWidgetStore.profileName,
            hasProfile: FlClashControlWidgetStore.hasProfile,
            pendingFeedbackUntil: FlClashControlWidgetStore.pendingFeedbackUntil,
            requestedRunning: FlClashControlWidgetStore.requestedRunning,
            requestedRunningUntil: FlClashControlWidgetStore.requestedRunningUntil
        )
    }
}

struct FlClashControlValueProvider: ControlValueProvider {
    var previewValue: Bool {
        false
    }

    func currentValue() async throws -> Bool {
        FlClashControlWidgetStore.isRunning
    }
}

struct FlClashStatusEntry: TimelineEntry {
    let date: Date
    let status: FlClashWidgetStatus
}

struct FlClashStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> FlClashStatusEntry {
        FlClashStatusEntry(
            date: Date(),
            status: FlClashWidgetStatus(
                isRunning: false,
                profileName: "Default",
                hasProfile: true,
                pendingFeedbackUntil: 0,
                requestedRunning: false,
                requestedRunningUntil: 0
            )
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (FlClashStatusEntry) -> Void
    ) {
        completion(FlClashStatusEntry(date: Date(), status: .current))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<FlClashStatusEntry>) -> Void
    ) {
        let status = FlClashWidgetStatus.current
        var entries = [FlClashStatusEntry(date: Date(), status: status)]
        let feedbackEnd = max(status.pendingFeedbackUntil, status.requestedRunningUntil)
        if feedbackEnd > Date().timeIntervalSince1970 {
            entries.append(
                FlClashStatusEntry(
                    date: Date(timeIntervalSince1970: feedbackEnd),
                    status: .current
                )
            )
        }
        completion(
            Timeline(
                entries: entries,
                policy: .never
            )
        )
    }
}

struct FlClashStatusWidgetView: View {
    let entry: FlClashStatusEntry

    @AppStorage(
        "macosControlWidget.running",
        store: flClashWidgetDefaults
    )
    private var storedIsRunning = false

    @AppStorage(
        "macosControlWidget.pendingFeedbackUntil",
        store: flClashWidgetDefaults
    )
    private var storedPendingFeedbackUntil = 0.0

    @AppStorage(
        "macosControlWidget.requestedRunning",
        store: flClashWidgetDefaults
    )
    private var storedRequestedRunning = false

    @AppStorage(
        "macosControlWidget.requestedRunningUntil",
        store: flClashWidgetDefaults
    )
    private var storedRequestedRunningUntil = 0.0

    private var liveStatus: FlClashWidgetStatus {
        FlClashWidgetStatus(
            isRunning: storedIsRunning,
            profileName: entry.status.profileName,
            hasProfile: entry.status.hasProfile,
            pendingFeedbackUntil: storedPendingFeedbackUntil,
            requestedRunning: storedRequestedRunning,
            requestedRunningUntil: storedRequestedRunningUntil
        )
    }

    private var profileName: String {
        if !entry.status.hasProfile {
            return "No Profile"
        }
        return entry.status.profileName.isEmpty ? "Default" : entry.status.profileName
    }

    private var accentColor: Color {
        if liveStatus.isPending {
            return Color(red: 1.0, green: 0.64, blue: 0.16)
        }
        return liveStatus.displayIsRunning ? Color(red: 0.18, green: 0.79, blue: 0.33) : Color.gray
    }

    private var connectionIconName: String {
        if liveStatus.isPending {
            return "ellipsis"
        }
        return liveStatus.displayIsRunning ? "bolt.fill" : "bolt"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONFIG")
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.primary)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 4) {
                Text("DEFAULT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)

                Text(profileName)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 6)

            HStack(alignment: .bottom) {
                Button(intent: ToggleFlClashConnectionIntent()) {
                    Image(systemName: connectionIconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(accentColor, in: Circle())
                }
                .buttonStyle(FlClashWidgetCircleButtonStyle())

                Spacer()

                Button(intent: RefreshFlClashProfileIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Color.secondary.opacity(0.10), in: Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(FlClashWidgetCircleButtonStyle())
            }
            .invalidatableContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .containerBackground(.background, for: .widget)
        .widgetURL(URL(string: "flclash://open"))
    }
}

struct FlClashWidgetCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1)
            .brightness(configuration.isPressed ? -0.10 : 0)
            .overlay {
                Circle()
                    .stroke(
                        Color.primary.opacity(configuration.isPressed ? 0.28 : 0),
                        lineWidth: 3
                    )
            }
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FlClashStatusWidget: Widget {
    static let kind = "com.follow.clash.status-widget.v2"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.kind,
            provider: FlClashStatusProvider()
        ) { entry in
            FlClashStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("FlClash")
        .description("Control FlClash and view the current profile.")
        .supportedFamilies([.systemSmall])
    }
}

struct FlClashControlWidget: ControlWidget {
    static let kind = "com.follow.clash.control-widget.v2"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: FlClashControlValueProvider()
        ) { isRunning in
            ControlWidgetToggle(
                "FlClash",
                isOn: isRunning,
                action: SetFlClashRunningIntent()
            ) { isRunning in
                Label(
                    "FlClash",
                    systemImage: isRunning
                        ? "bolt.horizontal.circle.fill"
                        : "bolt.horizontal.circle"
                )
            }
        }
        .displayName("FlClash")
        .description("Start or stop the FlClash VPN/proxy connection.")
    }
}

@main
struct FlClashControlWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        FlClashStatusWidget()
        FlClashControlWidget()
    }
}
