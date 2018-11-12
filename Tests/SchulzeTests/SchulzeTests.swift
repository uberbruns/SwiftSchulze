import Foundation
import XCTest

@testable import SchulzeLibrary

final class SchulzeTests: XCTestCase {
    func testSchulze() throws {
        let rankings = [
            ["A", "C", "B", "E", "D"],
            ["A", "C", "B", "E", "D"],
            ["A", "C", "B", "E", "D"],
            ["A", "C", "B", "E", "D"],
            ["A", "C", "B", "E", "D"],
            ["A", "D", "E", "C", "B"],
            ["A", "D", "E", "C", "B"],
            ["A", "D", "E", "C", "B"],
            ["A", "D", "E", "C", "B"],
            ["A", "D", "E", "C", "B"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["B", "E", "D", "A", "C"],
            ["C", "A", "B", "E", "D"],
            ["C", "A", "B", "E", "D"],
            ["C", "A", "B", "E", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "A", "E", "B", "D"],
            ["C", "B", "A", "D", "E"],
            ["C", "B", "A", "D", "E"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["D", "C", "E", "B", "A"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
            ["E", "B", "A", "D", "C"],
        ]

        let winners = Schulze.ranking(rankings: rankings)
        XCTAssertEqual(winners, [["E"], ["A"], ["C"], ["B"], ["D"]])
    }

    static var allTests = [
        ("testSchulze", testSchulze),
    ]
}
