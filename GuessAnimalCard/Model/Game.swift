//
//  Game.swift
//  MemeryCard
//
//  Created by 弘勳 on 2018/10/24.
//  Copyright © 2018 Hung Hsun Lin. All rights reserved.
//

import Foundation
import AVFoundation

enum Player {
    case player1
    case computer
}

struct Game {
    // Now player.
    static var nowPlayer = Player.player1
    static var computerScore = 0
    static var playerScore = 0
    private var count = 0
    private var incorrectSound: AVAudioPlayer!
    private var correctSound: AVAudioPlayer!
    
    private(set) var cards = [Card]()
    
    private var indexOfTheOnlyFacedUpCard: Int? {
        get{
            return cards.indices.filter({ cards[$0].isFacedUp}).oneAndOnly
        }
        set{
            for index in cards.indices {
                cards[index].isFacedUp = (index == newValue)
            }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        count = 0
        guard cards.indices.contains(index) else {
            assertionFailure( "chooseCard(at: \(index)): index is out of bounds")
            return
        }
        count += 1
        if !cards[index].isMatched {
            if let matchIndex = indexOfTheOnlyFacedUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[index].isMatched = true
                    cards[matchIndex].isMatched = true
                    correctSound.play()
                    scoreCalculator()
                    removeCard(index: index, matchIndex: matchIndex)
                } else {
                    incorrectSound.play()
                    chagePlayer()
                }
                cards[index].isFacedUp = true
            } else {
                indexOfTheOnlyFacedUpCard = index
            }
        }
    }
    
    mutating func chagePlayer() {
        if Game.nowPlayer == .player1 {
            Game.nowPlayer = .computer
        } else {
            Game.nowPlayer = .player1
        }
        print(Game.nowPlayer)
    }
    
    func removeCard(index: Int, matchIndex: Int) {
        GameViewController.canFlipedButtons.removeValue(forKey: index)
        GameViewController.canFlipedButtons.removeValue(forKey: matchIndex)
      
        if GameViewController.flipedCards.count < index {
            GameViewController.flipedCards.removeValue(forKey: index)
        } else {
            GameViewController.flipedCards.removeValue(forKey: matchIndex)
        }
    }
    
    // MARK: - Prepare the game's sounds.
    
    mutating func prepareSound() {
        // Create sound player.
        let incorrectSoundPath = Bundle.main.path(forResource: "incorrectSound", ofType: "mp3")
        let correctSoundPath = Bundle.main.path(forResource: "correctSound", ofType: "mp3")
        do {
            incorrectSound = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: incorrectSoundPath!))
            correctSound = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: correctSoundPath!))
            
            // Set play times is 0 to play once.
            incorrectSound.numberOfLoops = 0
            correctSound.numberOfLoops = 0
        } catch {
            print("error")
        }
    }
    
    // MARK: - Caculator the scores about player and computer.
    
    mutating func scoreCalculator() {
        switch Game.nowPlayer {
        case .computer:
            Game.computerScore += 50
            if count > 1 {
                Game.computerScore += (20 * count)
            }
        case .player1:
            Game.playerScore += 50
            if count > 1 {
                Game.playerScore += (20 * count)
            }
        }
    }
    
    // MARK: - Initializer Game struct.
    
    init(numberOfPairsOfCards: Int) {
        prepareSound()
        guard numberOfPairsOfCards > 0 else {
            assertionFailure( "numberOfPairsOfCards is <= 0")
            return
        }
        for _ in 1...numberOfPairsOfCards{
            let card = Card()
            // add pair of cards to array
            cards += [card, card]
        }
        cards.shuffle()
    }
}

extension Collection{
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}

struct Card: Hashable {
    var hashValue: Int { return id }
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    var isMatched = false
    var isFacedUp = false
    private var id: Int
    
    // Create card id.
    private static var idFactory = 0
    private static func generateUniqueCardId() -> Int{
        idFactory += 1
        return idFactory
    }
    
    init() {
        self.id = Card.generateUniqueCardId()
    }
    
}
