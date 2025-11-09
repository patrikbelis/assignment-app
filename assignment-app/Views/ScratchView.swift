import SwiftUI

@MainActor
struct ScratchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ScratchViewModel

    init(store: AppDataStore) {
        _vm = StateObject(wrappedValue: ScratchViewModel(store: store))
    }

    var body: some View {
        ZStack {
            BlueWhiteBackground()
            CardPanel {
                contentView
            }
        }
        .navigationTitle("Odmena")
        .onDisappear {
            vm.cancel()
        }
    }

    private var contentView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("🫣 Zobraz svoj kód")
                .font(.title)
                .fontWeight(.bold)
            Spacer()

            Button(vm.isScratching ? "Načítávam" : "Zobraziť kód") {
                vm.scratch {
                    dismiss()
                }
            }
            .disabled(vm.isScratching)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 0/255, green: 146/255, blue: 215/255))
            .foregroundStyle(Color.white)
            .fontWeight(.bold)
        }
        .padding(16)
    }
}
