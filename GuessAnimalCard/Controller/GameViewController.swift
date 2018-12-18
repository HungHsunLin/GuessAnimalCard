//
//  GameViewController.swift
//  MemeryCard
//
//  Created by 弘勳 on 2018/10/20.
//  Copyright © 2018 Hung Hsun Lin. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate {


    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var gameOverView: UIStackView!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var createNewGame: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var playerTitle: UILabel!
    @IBOutlet weak var computerTitle: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!

    var gameWinner: String?
    
    private lazy var game = Game(numberOfPairsOfCards: numberOfPairsOfCards)
    var numberOfPairsOfCards: Int {
        return cardButtons.count / 2
    }
    private var emojiChoose =
        ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵"]
    static var emoji = [Card: String]()
    static var canFlipedButtons = [Int: Int]()
//    static var matchedCards = [Int: Int]()
    static var flipedCards = [Int: Int]()
    
    func putEmoji(for card: Card, buttonIndex: Int) -> String {
        if GameViewController.emoji[card] == nil, emojiChoose.count > 0 {
            let randomIndex = Int.random(in: 0...(emojiChoose.count - 1))
            GameViewController.emoji[card] = emojiChoose.remove(at: randomIndex)
            GameViewController.flipedCards[buttonIndex] = card.hashValue
        }
        return GameViewController.emoji[card] ?? "?"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bannerView.adUnitID = "ca-app-pub-4497068935276765/3018947874"
        
        // Test ID
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        buttonsView.isHidden = false
        gameOverView.isHidden = true
        
        // Change text size.
        let playerLabelTextSize = playerTitle.bounds.width / 5
        let winnerLabelTextSize = winnerLabel.bounds.width / 5
        playerTitle.font = UIFont.systemFont(ofSize: playerLabelTextSize)
        computerTitle.font = UIFont.systemFont(ofSize: playerLabelTextSize)
        playerTitle.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        winnerLabel.font = UIFont.systemFont(ofSize: winnerLabelTextSize)
        
        // Let canFlipedButtons id is same to card id.
        for index in 0...(cardButtons.count - 1) {
            GameViewController.canFlipedButtons[index] = index
        }
        
    }
    
//    override func viewLayoutMarginsDidChange() {
//        if Game.nowPlayer == .computer {
//            computerPlay()
//        }
//    }
    
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let buttonIndex = cardButtons.index(of: sender) {
            game.chooseCard(at: buttonIndex)
            updateViewFromModel()
//            print(Game.nowPlayer)
//            let buttonLabel = cardButtons[buttonIndex].titleLabel?.text ?? ""
//            print("Touch card. Button: \(buttonIndex) is \(buttonLabel). \ncanFlipedCard total have \(GameViewController.canFlipedButtons.count) cards.")
//        } else {
//            print("Clicked button which is not in button array.")
        }
    }

    // MARK: - Restart Game.
    
    @IBAction func playAgain(_ sender: UIButton) {
        game = Game(numberOfPairsOfCards: numberOfPairsOfCards)
        emojiChoose =
            ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵"]
        resetCardButtons()
        Game.nowPlayer = .player1
        GameViewController.emoji = [Card: String]()
        GameViewController.canFlipedButtons = [Int: Int]()
        
        // Let canFlipedButtons id is same to card id.
        for index in 0...(cardButtons.count - 1) {
            GameViewController.canFlipedButtons[index] = index
        }
        computerScoreLabel.text = "0"
        playerScoreLabel.text = "0"
        computerTitle.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        playerTitle.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        Game.computerScore = 0
        Game.playerScore = 0
//        print("nowFlipedCards: \(GameViewController.emoji.count), flipedCard: \(GameViewController.canFlipedButtons.count)")
        buttonsView.isHidden = false
        gameOverView.isHidden = true
        
    }
    
    private func resetCardButtons(){
        for cardButton in cardButtons{
            cardButton.setTitle("", for: UIControl.State.normal)
            cardButton.backgroundColor = #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
            cardButton.isEnabled = true
        }
    }
    
    // MARK: - Upload UIViews.
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            playerScoreLabel.text = String(Game.playerScore)
            computerScoreLabel.text = String(Game.computerScore)
            let button = cardButtons[index]
            let card = game.cards[index]
            let labelHeight = button.bounds.height / 2
            button.titleLabel?.font = UIFont.systemFont(ofSize: labelHeight)
            if card.isFacedUp {
                button.setTitle(putEmoji(for: card, buttonIndex: index), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
            }
            switch Game.nowPlayer {
            case .computer:
                button.isEnabled = false
                computerTitle.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                playerTitle.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            case .player1:
                computerTitle.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                playerTitle.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                if card.isMatched {
                    button.isEnabled = false
                } else {
                    button.isEnabled = true
                }
            }
        }
        if Game.nowPlayer == .computer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.newGameButton.isEnabled = false
                self.computerPlay()
            }
        } else {
            self.newGameButton.isEnabled = true
        }
        if GameViewController.canFlipedButtons.count == 0 {
            finishGame()
        }
    }
    
    // MARK: - Set computer choose card.
    
    private func computerPlay() {
//        let matchedRate = Int.random(in: 1...5)
//        if GameViewController.matchedCards.count > 1 && matchedRate == 1 {
//            let matchedCardsRandom = Int.random(in: 0...(GameViewController.matchedCards.count - 1))
//            let index = GameViewController.matchedCards[matchedCardsRandom]!
//            touchCard(cardButtons[index])
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.touchCard(self.cardButtons[matchedCardsRandom])
//            }
//        }
        if GameViewController.canFlipedButtons.count > 0 {
            let randomIndex = Int.random(in: 0...(cardButtons.count - 1))
            if game.cards[randomIndex].isFacedUp || game.cards[randomIndex].isMatched {
                computerPlay()
            } else {
                touchCard(cardButtons[randomIndex])
            }
        }
    }

    // MARK: - Game is over. Show the winner.
    
    private func finishGame() {
        buttonsView.isHidden = true
        gameOverView.isHidden = false
        if Game.playerScore > Game.computerScore {
            gameWinner = NSLocalizedString("玩家獲勝！！", comment: "")
        } else {
            gameWinner = NSLocalizedString("電腦獲勝！！", comment: "")
        }
        winnerLabel.text = gameWinner
    }
}

