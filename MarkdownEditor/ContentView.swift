import SwiftUI

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @State private var fontSize: CGFloat = 14

    var body: some View {
        TextEditor(text: $document.text)
            .font(.system(size: fontSize, design: .monospaced))
            .padding(8)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { fontSize = max(10, fontSize - 1) }) {
                        Image(systemName: "textformat.size.smaller")
                    }
                    Button(action: { fontSize = min(24, fontSize + 1) }) {
                        Image(systemName: "textformat.size.larger")
                    }
                }
            }
    }
}
