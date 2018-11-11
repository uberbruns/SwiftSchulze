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
        .optionWithValue("p", "path", name: "Path", description: "Use this option to provide a path to a file containing the casted rankings. Every line should contain the candidates ranked by one voter seperated via comma.")
)

let directoryOption = arguments.add(
    Argument<Bool>
        .optionWithValue("d", "directory", name: "Directory", description: "Use this option to provide a directory containing .txt files. Every file should contain the candidates ranked by one voter. One candidate per line.")
)

let helpOption = arguments.add(
    Argument<Bool>
        .option("h", "help", description: "Prints this help page.")
)


// MARK: Main Input Handling

do {
    try arguments.parse()

    if helpOption.value {
        print(arguments.usagetext)
        exit(0)
    }

    // Parse input into `rankings`
    let rankings: [[String]]

    if let directory = directoryOption.value {
        let url = URL(fileURLWithPath: directory)
        let contents = try FileManager.default.contentsOfDirectory(at: url,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles, .skipsPackageDescendants])
        var foundRankings = [[String]]()
        for fileURL in contents where fileURL.pathExtension == "txt" {
            let fileContent = try String(contentsOf: fileURL)
            let candidates = fileContent.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            foundRankings.append(candidates)
        }
        rankings = foundRankings

    } else {
        let lines: [String]

        if let path = pathOption.value {
            let fileContent = try String(contentsOfFile: path)
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

        rankings = lines.map { list in
            list.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
    }


    // Calculate final ranking
    var finalRanking = [[String]]()
    var rankedCandidates = Set<String>()
    let candidateSet = rankings.reduce(into: Set<String>()) { $0.formUnion($1) }
    var candidates = Array(candidateSet).sorted()

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
