import SwiftUI

struct ActivationView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var vm: ActivationViewModel

    init(store: AppDataStore) {
        _vm = StateObject(wrappedValue: ActivationViewModel(store: store))
    }

    var body: some View {
        ZStack(alignment: .top) {
            BlueWhiteBackground()
            CardPanel { contentView }
        }
        .alert("🥹 Aktivácia zlyhala", isPresented: $store.showActivationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Nastala nečakaná chyba. Skúste to znovu.")
        }
        .navigationTitle("Aktivácia")
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .center, spacing: 8) {
            switch store.state {
            case .hidden:
                Text("Najprv musíš získať kód 🙄")
                    .font(.title).fontWeight(.bold)

            case .revealed(let code):
                Text(code)
                    .font(.title).fontWeight(.bold)

                Button(vm.isActivating ? "Aktivujem…" : "Aktivovať") {
                    vm.activate()
                }
                .disabled(vm.isActivating)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0/255, green: 146/255, blue: 215/255))
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .cornerRadius(8)

            case .activated(let code):
                Text(code)
                    .font(.title).fontWeight(.bold)
                Text("Kód aktivovaný 😎")
                    .font(.title).fontWeight(.bold)
            }
        }
        .padding(16)
    }
}
