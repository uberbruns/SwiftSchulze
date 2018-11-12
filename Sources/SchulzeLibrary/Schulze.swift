//
//  Schulze.swift
//  Schulze
//
//  Created by Karsten Bruns on 06.11.18.
//

import Foundation


private class SimpleMatrix<Row: Hashable, Column: Hashable, Value> {
    var data = [Row:[Column:Value]]()

    func set(_ row: Row, _ column: Column, value: Value) {
        data[row, default: [Column:Value]()][column] = value
    }

    func get(_ row: Row, _ column: Column) -> Value {
        return data[row]![column]!
    }
}


public enum Schulze {

    public static func winners<C: Hashable>(of candidates: [C], rankings: [[C]]) -> [C] where C: CustomStringConvertible {
        // Determine winner with the Schulze method
        let candidateCount = candidates.count
        let matrix = SimpleMatrix<C, C, Int>()
        var winnerList = [C]()

        for candidateA in candidates {
            for candidateB in candidates where candidateA != candidateB {
                let aOverB = numberOfVotesPreferring(candidateA, over: candidateB, rankings: rankings, candidateCount: candidateCount)
                let bOverA = numberOfVotesPreferring(candidateB, over: candidateA, rankings: rankings, candidateCount: candidateCount)
                let voteConnectionStrength = aOverB > bOverA ? aOverB : 0
                matrix.set(candidateA, candidateB, value: voteConnectionStrength)
            }
        }

        for candidateA in candidates {
            for candidateB in candidates where candidateA != candidateB {
                for candidateK in candidates where candidateA != candidateK && candidateB != candidateK {
                    let strengthBetweenBandK = matrix.get(candidateB, candidateK)
                    let strengthBetweenBandA = matrix.get(candidateB, candidateA)
                    let strengthBetweenAandK = matrix.get(candidateA, candidateK)
                    let voteConnectionStrength = max(strengthBetweenBandK, min(strengthBetweenBandA, strengthBetweenAandK))
                    matrix.set(candidateB, candidateK, value: voteConnectionStrength)
                }
            }
        }

        for candidateA in candidates {
            var isCandidateAaWinner = true
            for candidateB in candidates where candidateA != candidateB {
                let strengthBetweenAandB = matrix.get(candidateA, candidateB)
                let strengthBetweenBandA = matrix.get(candidateB, candidateA)
                isCandidateAaWinner = isCandidateAaWinner && (strengthBetweenAandB >= strengthBetweenBandA)
            }
            if isCandidateAaWinner {
                winnerList.append(candidateA);
            }
        }

        return winnerList
    }

    
    public static func ranking<C: Hashable>(rankings: [[C]]) -> [[C]] where C: Comparable, C: CustomStringConvertible {
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


    private static func numberOfVotesPreferring<C: Equatable>(_ a: C, over b: C, rankings: [[C]], candidateCount: Int) -> Int {
        var votesPreferingAoverB = 0
        for ranking in rankings {
            let indexOfA = ranking.index(of: a) ?? candidateCount - 1
            let indexOfB = ranking.index(of: b) ?? candidateCount - 1
            if indexOfA < indexOfB {
                votesPreferingAoverB += 1
            }
        }
        return votesPreferingAoverB
    }
}
