import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.05, green: 0.08, blue: 0.14), Color(red: 0.08, green: 0.11, blue: 0.18)]
                    : [.white, Color(red: 0.97, green: 0.98, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(FinancePalette.oceanBlue.opacity(colorScheme == .dark ? 0.18 : 0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 20)
                .offset(x: 150, y: -290)

            Circle()
                .fill(FinancePalette.royalBlue.opacity(colorScheme == .dark ? 0.16 : 0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 28)
                .offset(x: -170, y: 210)
        }
        .ignoresSafeArea()
    }
}
