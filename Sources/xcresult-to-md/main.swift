import ArgumentParser

struct XCResultToMarkdown: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to parse xcresult bundles to markdown",
        subcommands: [Generate.self])

    init() { }
}

XCResultToMarkdown.main()