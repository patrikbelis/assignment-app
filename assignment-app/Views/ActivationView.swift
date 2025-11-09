import SwiftUI

struct ActivationView: View {
    @EnvironmentObject var store: AppDataStore

    var body: some View {
        ZStack(alignment: .top) {
            BlueWhiteBackground()

            CardPanel {
                VStack(alignment: .center, spacing: 8) {

                    switch store.state {
                    case .hidden:
                        Text("Najprv musíš získať kód 🙄")
                            .font(.title)
                            .fontWeight(.bold)
                    case .revealed(let code):
                        Text("\(code)")
                            .font(.title)
                            .fontWeight(.bold)
                        Button("Aktivovať") {
                            Task { await store.activate() }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0/255, green: 146/255, blue: 215/255))
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                    case .activated(let code):
                        Text("\(code)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Kód aktivovaný 😎")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding(16)
            }
        }
        .alert("🥹 Aktivácia zlyhala", isPresented: $store.showActivationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Nastala nečakaná chyba. Skúste to znovu.")
        }
        .navigationTitle("Aktivácia")
    }
}
