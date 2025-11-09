import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()
    @StateObject private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                BlueWhiteBackground()

                CardPanel {
                    VStack(alignment: .leading, spacing: 8) {
                        titleView
                        Spacer()
                        buttonView
                    }
                    .padding(16)
                }
            }
            .alert("🥹 Kód už máš", isPresented: $store.showScratchError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Musíš ho aktivovať.")
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .scratch:
                    ScratchView(store: store)
                        .environmentObject(store)
                case .activate:
                    ActivationView(store: store)
                        .environmentObject(store)
                }
            }
        }
    }

    var titleView: some View {
        Group {
            switch store.state {
            case .hidden:
                Text("🤓 Získajte odmenu!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Zoškrabte svoj kód a zistíte čo vyhrávate!")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.gray)
            case let .revealed(code):
                Text("🥳 Aktivujte odmenu!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Prejdite na aktiváciu a získajte odmenu!")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.gray)
                Text(code)
                    .font(.caption)
            case .activated:
                Text("😎 Odmena aktivovaná!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Veď kto iný by si to zaslúžil ak nie vy!")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.gray)
            }
        }
    }

    var buttonView: some View {
        Group {
            Button("Získať kód") {
                if case .revealed = store.state {
                    store.showScratchError = true
                    return
                }
                router.push(.scratch)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 0/255, green: 146/255, blue: 215/255))
            .foregroundStyle(Color.white)
            .fontWeight(.bold)

            Button("Aktivovať kód") {
                router.push(.activate)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.gray)
            .foregroundStyle(Color.white)
            .fontWeight(.bold)
        }
    }
}
