
import Foundation
import Moderator


enum OutputFormat: String {
    case plain, json
}


let arguments = Moderator(description: "Tool for calculating the winner of an election where the voters cast their vote by providing a ranked list of candidates.")
let rankingOption = arguments.add(
    Argument<String>
        .optionWithValue("r", "ranking", name: "Ranking", description: "A ranking of candidates provoded by a voter.")
        .repeat()
)

let formatOption = arguments.add(
    Argument<OutputFormat>
        .optionWithValue("f", "format", name: "Format", description: "The output format ('plain' or 'json')")
)

let stdInOption = arguments.add(
    Argument<Bool>
        .option("i", "stdin", description: "")
)


do {
    try arguments.parse()

    let rankings: [[String]]

    if stdInOption.value {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        rankings = String(bytes: data, encoding: .utf8)!.components(separatedBy: "\n").map { list in
            list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
    } else {
        rankings = rankingOption.value.map { list in
            list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
    }

    let candidateSet = rankings.reduce(into: Set<String>()) { $0.formUnion($1) }
    let candidates = Array(candidateSet)

    let indexedRankings = rankings.map { ranking in
        ranking.map { candidates.index(of: $0)! }
    }

    let winners = Schulze.winners(of: candidates, rankings: indexedRankings)

    if formatOption.value == OutputFormat.json.rawValue {
        let output = ["winners": winners]
        let writingOptions: JSONSerialization.WritingOptions
        let data: Data

        if #available(OSX 10.13, *) {
            writingOptions = [.prettyPrinted, .sortedKeys]
        } else {
            writingOptions = [.prettyPrinted]
        }

        data = try JSONSerialization.data(withJSONObject: output, options: writingOptions)
        print(String(bytes: data, encoding: .utf8)!)
    } else {
        print(winners.joined(separator: ", "))
    }

} catch {
    print(error)
    exit(Int32(error._code))
}
