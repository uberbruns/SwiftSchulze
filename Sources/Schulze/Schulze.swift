//
//  Schulze.swift
//  Schulze
//
//  Created by Karsten Bruns on 06.11.18.
//

import Foundation


private struct SimpleMatrix {

    var data = [Int:[Int:Int]]()

    mutating func set(_ a: Int, _ b: Int, value: Int) {
        data[a, default: [Int:Int]()][b] = value
    }

    func get(_ a: Int, _ b: Int) -> Int {
        return data[a]![b]!
    }
}


enum Schulze {

    static func winners<C>(of candidates: [C], rankings: [[Int]]) -> [C] {
        // Determine winner with the Schulze method
        let candidateCount = candidates.count
        var connectionStrength = SimpleMatrix()
        var winnerList = [C]()

        for candidateA in 0..<candidateCount {
            for candidateB in 0..<candidateCount {
                guard candidateA != candidateB else { continue }
                let aOverB = numberOfVotesPreferring(candidateA, over: candidateB, rankings: rankings, candidateCount: candidateCount)
                let bOverA = numberOfVotesPreferring(candidateB, over: candidateA, rankings: rankings, candidateCount: candidateCount)
                let voteConnectionStrength = aOverB > bOverA ? aOverB : 0
                connectionStrength.set(candidateA, candidateB, value: voteConnectionStrength)
            }
        }

        for candidateA in 0..<candidateCount {
            for candidateB in 0..<candidateCount {
                guard candidateA != candidateB else { continue }
                for candidateK in 0..<candidateCount {
                    guard candidateA != candidateK && candidateB != candidateK else { continue }
                    let strengthBetweenBandK = connectionStrength.get(candidateB, candidateK)
                    let strengthBetweenBandA = connectionStrength.get(candidateB, candidateA)
                    let strengthBetweenAandK = connectionStrength.get(candidateA, candidateK)
                    let voteConnectionStrength = max(strengthBetweenBandK, min(strengthBetweenBandA, strengthBetweenAandK))
                    connectionStrength.set(candidateB, candidateK, value: voteConnectionStrength)
                }
            }
        }

        for candidateA in 0..<candidateCount {
            var isCandidateAaWinner = true
            for candidateB in 0..<candidateCount {
                guard candidateA != candidateB else { continue }
                let strengthBetweenAandB = connectionStrength.get(candidateA, candidateB)
                let strengthBetweenBandA = connectionStrength.get(candidateB, candidateA)
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
