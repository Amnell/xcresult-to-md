//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-05-16.
//

import Foundation
import XCResultKit

// Unimplemented
private func iterateActions(_ actions: [ActionRecord], fromResultFile resultFile: XCResultFile) {
    actions.forEach { actionRecord in
        print("""
                ---------------------------------------------------------------------------
                \(actionRecord.title ?? "nil action title")
                ---------------------------------------------------------------------------
                schemeCommandName: \(actionRecord.schemeCommandName)
                schemeTaskName: \(actionRecord.schemeTaskName)
                """)
        if let tests = actionRecord.actionResult.testsRef {
            let testPlanRunSummaries = resultFile.getTestPlanRunSummaries(id: tests.id)
            testPlanRunSummaries?.summaries.forEach({ summary in
                print("name:", summary.name)
                summary.testableSummaries.forEach { testableSummary in
                    testableSummary.tests.forEach({ testSummaryGroup in
                        testSummaryGroup.subtests.forEach { actionTestMetadata in
                            print(actionTestMetadata.name)
                        }
                        
                        testSummaryGroup.subtestGroups.forEach { subtestGroup in
                            print("")
                            print("----------Test suite-------------")
                            print(subtestGroup.name ?? "nil")
                            print("subtestGroups.count:", subtestGroup.subtestGroups.count)
                            print("subtests.count:", subtestGroup.subtests.count)
                            print("---------------------------------")
                            
                            subtestGroup.subtests.forEach { actionTestMetadata in
                                print(actionTestMetadata.name)
                                print(actionTestMetadata.testStatus)
                                if let summaryRef = actionTestMetadata.summaryRef {
//                                    print("🙌", resultFile.getActionTestSummary(id: summaryRef.id))
                                }
                            }
                            
                            subtestGroup.subtestGroups.forEach { subtestGroup in
                                print("📜", subtestGroup.name ?? "nil")
                                subtestGroup.subtests.forEach { actionTestMetadata in
                                    let testStatus = actionTestMetadata.testStatus == "Success" ? "✅": "🔴"
                                    print(testStatus, actionTestMetadata.name)
                                    //                                            print("identifier", actionTestMetadata.identifier)
                                    if let summaryRef = actionTestMetadata.summaryRef {
//                                        print("🙌", resultFile.getActionTestSummary(id: summaryRef.id))
                                    }
                                    
                                }
                            }
                        }
                    })
                }
            })
        }
    }
}
