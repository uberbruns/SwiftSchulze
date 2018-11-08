import Foundation
import Moderator


// MARK: - Command Line Interface -
// MARK: Input Types

enum OutputFormat: String {
    case plain, json
}


// MARK: Configuration

let arguments = Moderator(description: "Tool for calculating the winner of an election by letting voters cast their vote in form of a ranked list of candidates.")

let rankingOption = arguments.add(
    Argument<String>
        .optionWithValue("r", "ranking", name: "Ranking", description: "A comma separated ranking of candidates casted by one voter. Repeat this option for every participant.")
        .repeat()
)

let formatOption = arguments.add(
    Argument<OutputFormat>
        .optionWithValue("f", "format", name: "Format", description: "The output format ('plain' or 'json').")
)

let stdInOption = arguments.add(
    Argument<Bool>
        .option("i", "stdin", description: "Takes a list of votes from standard input. Every line should contain a comma separated ranking.")
)

let pathOption = arguments.add(
    Argument<Bool>
        .optionWithValue("p", "path", name: "Path", description: "Use this option to provide a path to a file containing the casted rankings. Every line should contain a comma separated ranking.")
)


// MARK: Main Input Handling

do {
    try arguments.parse()

    // Parse input into `rankings`
    let lines: [String]
    var finalRanking = [[String]]()

    if let path = pathOption.value, let fileContent = try? String(contentsOfFile: path) {
        lines = fileContent.components(separatedBy: "\n")
    } else if stdInOption.value {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        lines = String(bytes: data, encoding: .utf8)!.components(separatedBy: "\n")
    } else if !rankingOption.value.isEmpty {
        lines = rankingOption.value
    } else {
        print(arguments.usagetext)
        exit(1)
    }


    let rankings = lines.map { list in
        list.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    // Calculate winner table
    var rankedCandidates = Set<String>()
    let candidateSet = rankings.reduce(into: Set<String>()) { $0.formUnion($1) }
    var candidates = Array(candidateSet)

    while rankedCandidates.count < candidateSet.count {
        let indexedRankings = rankings.map { ranking in ranking.compactMap { candidates.index(of: $0) }}
        let rank = Schulze.winners(of: candidates, rankings: indexedRankings)
        candidates.removeAll(where: { rank.contains($0) })
        rankedCandidates.formUnion(rank)
        finalRanking.append(rank)
    }

    // Output final ranking
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
