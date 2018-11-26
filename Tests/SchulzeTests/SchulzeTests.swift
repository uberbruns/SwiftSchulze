import Foundation
import XCTest

@testable import SchulzeLibrary

final class SchulzeTests: XCTestCase {
    func testWikiExample() {
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

        let ranking = Schulze.ranking(rankings: rankings)
        XCTAssertEqual(ranking, [["E"], ["A"], ["C"], ["B"], ["D"]])
    }

    func testWikiExample2() {
        let rankings = Array(repeating: ["A", "B", "C", "D"], count: 3)
            + Array(repeating: ["D", "A", "B", "C"], count: 2)
            + Array(repeating: ["D", "B", "C", "A"], count: 2)
            + Array(repeating: ["C", "B", "D", "A"], count: 2)

        let winners = Schulze.winners(of: ["A", "B", "C", "D"], rankings: rankings)
        XCTAssertEqual(winners, ["B", "D"])
    }

    func testFernandezExample() {
        let rankings = Array(repeating: ["M", "S", "B", "T"], count: 7)
            + Array(repeating: ["T", "M", "S", "B"], count: 4)
            + Array(repeating: ["S", "T", "B", "M"], count: 3)
            + Array(repeating: ["T", "M", "S", "B"], count: 5)

        let winners = Schulze.winners(of: ["M", "S", "B", "T"], rankings: rankings)
        XCTAssertEqual(winners, ["T"])
    }

    static var allTests = [
        ("testWikiExample", testWikiExample),
        ("testFernandezExample", testFernandezExample),
    ]
}
