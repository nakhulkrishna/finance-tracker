import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white, Color(red: 0.97, green: 0.98, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(FinancePalette.oceanBlue.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 20)
                .offset(x: 150, y: -290)

            Circle()
                .fill(FinancePalette.royalBlue.opacity(0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 28)
                .offset(x: -170, y: 210)
        }
        .ignoresSafeArea()
    }
}
