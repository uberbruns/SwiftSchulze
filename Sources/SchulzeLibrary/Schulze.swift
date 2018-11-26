//
//  Schulze.swift
//  Schulze
//
//  Created by Karsten Bruns on 06.11.18.
//

import Foundation


private class SimpleMatrix<Row: Hashable, Column: Hashable, Value> {
    var data = [Row:[Column:Value]]()

    subscript(_ row: Row, _ column: Column) -> Value {
        get {
            return data[row]![column]!
        }
        set {
            data[row, default: [Column:Value]()][column] = newValue
        }
    }
}


public enum Schulze {

    public static func winners<C: Hashable>(of candidates: [C], rankings: [[C]]) -> [C] where C: CustomStringConvertible {
        // Determine winner with the Schulze method
        let matrix = SimpleMatrix<C, C, Int>()
        var winnerList = [C]()

        for candidateA in candidates {
            for candidateB in candidates where candidateA != candidateB {
                let aOverB = numberOfVotesPreferring(candidateA, over: candidateB, rankings: rankings)
                let bOverA = numberOfVotesPreferring(candidateB, over: candidateA, rankings: rankings)
                let numberOfVotesPreferringAOverB = aOverB > bOverA ? aOverB : 0
                matrix[candidateA, candidateB] = numberOfVotesPreferringAOverB
            }
        }

        for candidateA in candidates {
            for candidateB in candidates where candidateA != candidateB {
                for candidateK in candidates where candidateA != candidateK && candidateB != candidateK {
                    let strengthBetweenBandK = matrix[candidateB, candidateK]
                    let strengthBetweenBandA = matrix[candidateB, candidateA]
                    let strengthBetweenAandK = matrix[candidateA, candidateK]
                    let voteConnectionStrength = max(strengthBetweenBandK, min(strengthBetweenBandA, strengthBetweenAandK))
                    matrix[candidateB, candidateK] = voteConnectionStrength
                }
            }
        }

        for candidateA in candidates {
            var isCandidateAaWinner = true
            for candidateB in candidates where candidateA != candidateB {
                let strengthBetweenAandB = matrix[candidateA, candidateB]
                let strengthBetweenBandA = matrix[candidateB, candidateA]
                isCandidateAaWinner = isCandidateAaWinner && (strengthBetweenAandB >= strengthBetweenBandA)
            }
            if isCandidateAaWinner {
                winnerList.append(candidateA);
            }
        }

        return winnerList
    }

    private static func numberOfVotesPreferring<C: Equatable>(_ a: C, over b: C, rankings: [[C]]) -> Int {
        var votesPreferingAoverB = 0
        for ranking in rankings {
            let indexOfA = ranking.index(of: a) ?? Int.max
            let indexOfB = ranking.index(of: b) ?? Int.max
            if indexOfA < indexOfB {
                votesPreferingAoverB += 1
            }
        }
        return votesPreferingAoverB
    }
}


public extension Schulze {
    static func ranking<C: Hashable>(rankings: [[C]]) -> [[C]] where C: Comparable, C: CustomStringConvertible {
        var finalRanking = [[C]]()
        var rankedCandidates = Set<C>()
        let candidateSet = rankings.reduce(into: Set<C>()) { $0.formUnion($1) }
        var remainingCandidates = Array(candidateSet).sorted()

        while rankedCandidates.count < candidateSet.count {
            let filteredRankings = rankings.map { ranking in ranking.filter { remainingCandidates.contains($0) }}
            let rank = Schulze.winners(of: remainingCandidates, rankings: filteredRankings)
            remainingCandidates.removeAll(where: { rank.contains($0) })
            rankedCandidates.formUnion(rank)
            finalRanking.append(rank)
        }
        return finalRanking
    }
}
