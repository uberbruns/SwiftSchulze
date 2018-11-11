//
//  Schulze.swift
//  Schulze
//
//  Created by Karsten Bruns on 06.11.18.
//

import Foundation


private class SimpleMatrix {
    var data = [Int:[Int:Int]]()

    func set(_ a: Int, _ b: Int, value: Int) {
        data[a, default: [Int:Int]()][b] = value
    }

    func get(_ a: Int, _ b: Int) -> Int {
        return data[a]![b]!
    }
}


enum Schulze {

    static func winners<C: CustomStringConvertible>(of candidates: [C], rankings: [[Int]]) -> [C] {
        // Determine winner with the Schulze method
        let candidateCount = candidates.count
        let candidateRange = 0..<candidateCount
        let matrix = SimpleMatrix()
        var winnerList = [C]()

        for candidateA in candidateRange {
            for candidateB in candidateRange where candidateA != candidateB {
                let aOverB = numberOfVotesPreferring(candidateA, over: candidateB, rankings: rankings, candidateCount: candidateCount)
                let bOverA = numberOfVotesPreferring(candidateB, over: candidateA, rankings: rankings, candidateCount: candidateCount)
                let voteConnectionStrength = aOverB > bOverA ? aOverB : 0
                matrix.set(candidateA, candidateB, value: voteConnectionStrength)
            }
        }

        for candidateA in candidateRange {
            for candidateB in candidateRange where candidateA != candidateB {
                for candidateK in candidateRange where candidateA != candidateK && candidateB != candidateK {
                    let strengthBetweenBandK = matrix.get(candidateB, candidateK)
                    let strengthBetweenBandA = matrix.get(candidateB, candidateA)
                    let strengthBetweenAandK = matrix.get(candidateA, candidateK)
                    let voteConnectionStrength = max(strengthBetweenBandK, min(strengthBetweenBandA, strengthBetweenAandK))
                    matrix.set(candidateB, candidateK, value: voteConnectionStrength)
                }
            }
        }

        for candidateA in candidateRange {
            var isCandidateAaWinner = true
            for candidateB in candidateRange where candidateA != candidateB {
                let strengthBetweenAandB = matrix.get(candidateA, candidateB)
                let strengthBetweenBandA = matrix.get(candidateB, candidateA)
                isCandidateAaWinner = isCandidateAaWinner && (strengthBetweenAandB >= strengthBetweenBandA)
            }
            if isCandidateAaWinner {
                winnerList.append(candidates[candidateA]);
            }
        }

        return winnerList
    }


    private static func numberOfVotesPreferring(_ a: Int, over b: Int, rankings: [[Int]], candidateCount: Int) -> Int {
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
