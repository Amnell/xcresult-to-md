import ArgumentParser
import XCResultKit
import Foundation
import Markdown

struct Generate: ParsableCommand {

    public static let configuration = CommandConfiguration(abstract: "Generate a summary for a given xcresult")

    @Argument(help: "The path to the xcresult to parse")
    private var path: String

    fileprivate func summarySections(_ invocationRecord: ActionsInvocationRecord) -> [BlockMarkup]? {
        var markup: [BlockMarkup] = []
        
        func issueSummarySection(fromIssueSummaries summaries: [IssueSummary], title: String) -> [BlockMarkup]? {
            var markup: [BlockMarkup] = []
            if summaries.count > 0 {
                var rows: [Table.Row] = []
                summaries.forEach { issueSummary in
                    rows.append(Table.Row(
                        Table.Cell(Text(":warning: \(issueSummary.issueType)")),
                        Table.Cell(Text(issueSummary.message)))
                    )
                }
                markup.append(Heading(level: 2, Text(title)))
                markup.append(Table(columnAlignments: nil,
                                    header: Table.Head(
                                        Table.Cell(Text("Type")), Table.Cell(Text("Message"))
                                    ),
                                    body: Table.Body(rows)))
            }
            return markup.count > 0 ? markup : nil
        }
        
        func testFailureSection(fromErrorSummaries summaries: [TestFailureIssueSummary], title: String) -> [BlockMarkup]? {
            var markup: [BlockMarkup] = []
            if summaries.count > 0 {
                var rows: [Table.Row] = []
                summaries.forEach { issueSummary in
                    rows.append(Table.Row(
                        Table.Cell(Text(":heavy_exclamation_mark: \(issueSummary.testCaseName)")),
                        Table.Cell(Text(issueSummary.message)))
                    )
                }
                markup.append(Heading(level: 2, Text(title)))
                markup.append(Table(columnAlignments: nil,
                                    header: Table.Head(
                                        Table.Cell(Text("Test case")), Table.Cell(Text("Message"))
                                    ),
                                    body: Table.Body(rows)))
            }
            return markup.count > 0 ? markup : nil
        }
        
        if let errorsMarkup = issueSummarySection(fromIssueSummaries: invocationRecord.issues.errorSummaries, title: "Errors") {
            markup.append(contentsOf: errorsMarkup)
        }
        
        if let warningsMarkup = issueSummarySection(fromIssueSummaries: invocationRecord.issues.analyzerWarningSummaries, title: "Warnings") {
            markup.append(contentsOf: warningsMarkup)
        }
        
        if let testFailureMarkup = testFailureSection(fromErrorSummaries: invocationRecord.issues.testFailureSummaries, title: "Test failures") {
            markup.append(contentsOf: testFailureMarkup)
        }
        
        if let warningFailuresMarkup = issueSummarySection(fromIssueSummaries: invocationRecord.issues.warningSummaries, title: "Warning failures") {
            markup.append(contentsOf: warningFailuresMarkup)
        }
        
        return markup.count > 0 ? markup : nil
    }
    
    func run() throws {
        let url = URL(fileURLWithPath: path)
        let resultFile = XCResultFile(url: url)
        if let invocationRecord = resultFile.getInvocationRecord() {
            
            let coverageFormatter = NumberFormatter()
            coverageFormatter.numberStyle = .percent
            let coverage = resultFile.getCodeCoverage()
            let formattedCoverage = String(format: "%.2f", (coverage?.lineCoverage ?? 0)*100)
            
            let metrics: [BlockMarkup] = [
                Heading(level: 2, [Text("Metrics")]),
                UnorderedList(
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.errorCount ?? 0) Errors"))),
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.warningCount ?? 0) Warnings"))),
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.analyzerWarningCount ?? 0) Analyzer warnings"))),
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.testsCount ?? 0) Tests"))),
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.testsFailedCount ?? 0) Failed tests"))),
                    ListItem(Paragraph(Text("\(invocationRecord.metrics.testsSkippedCount ?? 0) Skipped tests"))),
                    ListItem(Paragraph(Text("\(formattedCoverage)% Code coverage")))
                )
            ]
            
            let summaries: [BlockMarkup]? = summarySections(invocationRecord)
            
            let documentContent: [BlockMarkup] = [
                [Heading(level: 1, [Text("Test result")])],
                metrics,
                summaries
            ].compactMap({$0}).flatMap({$0})
            
            let paragraph = Document(documentContent)
            
            print(paragraph.format())
        }
    }
}
