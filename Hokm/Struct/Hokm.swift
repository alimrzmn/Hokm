//
//  Hokm.swift
//  Hokm
//
//  Created by Ali Mirzamani on 4/15/23.
//

import Foundation

struct Hokm {

    // MARK: - Constants
    private let cards: [Card] = {
        var cards = [Card]()
        for type in CardType.allCases {
            for value in CardValue.allCases {
                cards.append(Card(type: type, value: value))
            }
        }
        return cards
    }()

    // MARK: - Variables
    private var playersWithTheirCards: [Int: [Card]] = [:]
    private var hakem: Int // For now hakem in the start is you
    private(set) var hokm: Card?
    private var rounds: [[RoundCard]] = []
    private var roundStartPlayer: Int
    private var team02Score: Int = 0
    private var team13Score: Int = 0

    // MARK: - Initializers
    init(hakem: Int = 0) {
        self.hakem = hakem
        self.roundStartPlayer = hakem
    }

    // MARK: - Functions
    mutating func deal() {
        let shuffledCards = cards.shuffled()
        let dealer = Dealer(cards: shuffledCards)
        playersWithTheirCards = dealer.deal(with: hakem)
    }

    mutating func determineHokm() {
        let hakemCards = getCards(of: hakem)
        let firstFiveCards = hakemCards[0 ..< 5]
        let sortedByValue = firstFiveCards.sorted()
        hokm = sortedByValue.first
    }

    mutating func play() {
        for round in 0 ..< 13 {
            playRound(round: round)
        }
    }

    mutating func playRound(round: Int) {
        print("--- Start of Round \(round + 1) ---")

        var roundCards = [RoundCard]()
        var backSuit: CardType?
        for turn in 0 ..< 4 {
            var player = roundStartPlayer + turn
            if player > 3 {
                player -= 4
            }

            if let backSuit {
                let card = getCard(type: backSuit, player: player)
                roundCards.append(card)
                print("Player \(player): \(card.card.symbol)")
            } else {
                let card = firstCardOfRound(player: player)
                roundCards.append(card)
                print("Player \(player): \(card.card.symbol)")
                backSuit = card.card.type
            }
        }

        let winnerPlayer = roundWinnerPlayer(round: roundCards)
        print("Round Winner: \(winnerPlayer)")
        if winnerPlayer == 0 || winnerPlayer == 2 {
            team02Score += 1
        } else {
            team13Score += 1
        }

        roundStartPlayer = winnerPlayer
        removeRoundCards(roundCards)
        print("--- End of Round ---")
    }

    private func roundWinnerPlayer(round: [RoundCard]) -> Int {
        // TODO: Is not correct
        let sortedRound = round.sorted { lhs, rhs in
            return lhs.card < rhs.card
        }

        guard let winner = sortedRound.first?.player else { fatalError() }
        return winner
    }

    private mutating func removeRoundCards(_ roundCards: [RoundCard]) {
        for roundCard in roundCards {
            let player = roundCard.player
            var cards = getCards(of: player)
            cards.removeAll { card in
                return card == roundCard.card
            }
            playersWithTheirCards[player] = cards
        }
    }

    private func firstCardOfRound(player: Int) -> RoundCard {
        let cards = getCards(of: player).sorted()
        guard let firstBigCard = cards.first else { fatalError() }
        return RoundCard(player: player, card: firstBigCard)
    }

    private func getCard(type: CardType, player: Int) -> RoundCard {
        let playerCards = getCards(of: player)
        let cardsWithType = playerCards.filter { $0.type == type }
        if !cardsWithType.isEmpty {
            let sortedCards = cardsWithType.sorted()
            guard let biggestCard = sortedCards.first else { fatalError() }
            return RoundCard(player: player, card: biggestCard)
        } else {
            guard let card = playerCards.first else { fatalError() }
            return RoundCard(player: player, card: card)
        }
    }

    private func getCards(of player: Int) -> [Card] {
        guard let cards = playersWithTheirCards[player] else { fatalError() }
        return cards
    }
}
