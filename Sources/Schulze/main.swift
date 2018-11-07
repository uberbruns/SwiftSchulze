
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
        .optionWithValue("f", "format", name: "Output format", description: "The output format ('plain' or 'json').")
)

let stdInOption = arguments.add(
    Argument<Bool>
        .option("i", "stdin", description: "")
)

let pathOption = arguments.add(
    Argument<Bool>
        .optionWithValue("p", "path", name: "Input path", description: "A path to file containing the votes. Every line is a comma seperated ranking for one voter.")
)


do {
    try arguments.parse()

    let lines: [String]
    var finalRanking = [[String]]()

    if let path = pathOption.value, let fileContent = try? String(contentsOfFile: path) {
        lines = fileContent.components(separatedBy: "\n")
    } else if stdInOption.value {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        lines = String(bytes: data, encoding: .utf8)!.components(separatedBy: "\n")
    } else {
        lines = rankingOption.value
    }

    let rankings = lines.map { list in
        list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var rankedCandidates = Set<String>()
    let candidateSet = rankings.reduce(into: Set<String>()) { $0.formUnion($1) }
    var candidates = Array(candidateSet)

    while rankedCandidates.count < candidateSet.count {
        let indexedRankings = rankings.map { ranking in
            ranking.compactMap { candidates.index(of: $0) }
        }
        let rank = Schulze.winners(of: candidates, rankings: indexedRankings)
        candidates.removeAll(where: { rank.contains($0) })
        rankedCandidates.formUnion(rank)
        finalRanking.append(rank)
    }

    if formatOption.value == OutputFormat.json.rawValue {
        let output = ["finalRanking": finalRanking]
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
        print(finalRanking.map({ $0.joined(separator: ", ") }).joined(separator: "\n"))
    }

} catch {
    print(error)
    exit(Int32(error._code))
}
