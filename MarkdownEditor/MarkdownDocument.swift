import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let markdown = UTType(importedAs: "net.daringfireball.markdown")
    static let quartoMarkdown = UTType(exportedAs: "org.quarto.qmd")
}

struct MarkdownDocument: FileDocument {
    var text: String

    init(text: String = "") {
        self.text = text
    }

    static var readableContentTypes: [UTType] {
        [.markdown, .quartoMarkdown]
    }

    static var writableContentTypes: [UTType] {
        [.markdown, .quartoMarkdown]
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
