import SwiftUI

@MainActor
struct ScratchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: AppDataStore
    @State private var isScratching = false
    @State private var scratchTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            BlueWhiteBackground()

            CardPanel {
                VStack(alignment: .center, spacing: 8) {
                    Text("🫣 Zobraz svoj kód")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()

                    Button(isScratching ? "Načítavam" : "Zobraziť kód")
                    {
                        guard !isScratching else { return }
                        isScratching = true
                        scratchTask = Task {
                            do {
                                try await Task.sleep(for: .seconds(2))
                                try Task.checkCancellation()

                                let code = UUID().uuidString
                                store.completeScratch(with: code)

                                isScratching = false
                                dismiss()
                            } catch is CancellationError {

                            } catch {
                                await MainActor.run { isScratching = false }
                            }
                        }
                    }
                    .disabled(isScratching)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0/255, green: 146/255, blue: 215/255))
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                }
                .padding(16)
            }
        }
        .navigationTitle("Odmena")
        .onDisappear {
            scratchTask?.cancel()
            scratchTask = nil
            isScratching = false
        }
    }
}
