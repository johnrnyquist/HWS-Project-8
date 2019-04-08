//
//  ViewController.swift
//  Project8
//
//  Created by John Nyquist on 3/24/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Labels
    var scoreLabel: UILabel!
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswerTextField: UITextField!

    var wordBitButtons = [UIButton]()
    var selectedButtons = [UIButton]()

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    var solutionWords = [String]()
    
    
    //MARK: - ViewController class
    
    func loadLevel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var clueString = ""
            var solutionString = ""
            var letterBits = [String]()
            
            /* level1.txt
             HA|UNT|ED: Ghosts in residence
             LE|PRO|SY: A Biblical skin disease
             TW|ITT|ER: Short but sweet online chirping
             OLI|VER: Has a Dickensian twist
             ELI|ZAB|ETH: Head of state, British style
             SA|FA|RI: The zoological web
             POR|TL|AND: Hipster heartland
             
             
             */
            guard let level = self?.level else {return}
            if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    for (index, line) in lines.enumerated() {
                        if line == "" { continue }
                        let parts = line.components(separatedBy: ": ")
                        let answer = parts[0]
                        let clue = parts[1]
                        
                        clueString += "\(index + 1). \(clue)\n"
                        
                        let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                        solutionString += "\(solutionWord.count) letters\n"
                        self?.solutionWords.append(solutionWord)
                        
                        let bits = answer.components(separatedBy: "|")
                        letterBits += bits
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                // Now configure the buttons and labels
                self?.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                letterBits.shuffle()
                
                if letterBits.count == self?.wordBitButtons.count {
                    for i in 0 ..< letterBits.count {
                        self?.wordBitButtons[i].setTitle(letterBits[i], for: .normal)
                    }
                }
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutionWords.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for wordBitButton in wordBitButtons {
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { wordBitButton.alpha = 1 })
        }
    }
    
    func clear() {
        currentAnswerTextField.text = ""
        
        for wordBitButton in selectedButtons {
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { wordBitButton.alpha = 1 })
        }
        
        selectedButtons.removeAll()
    }
    
    func clearAction(action: UIAlertAction) {
        clear()
    }
    
    //MARK: - ViewController #selectors
    
    @objc func letterTapped(_ wordBitButton: UIButton) {
        guard let buttonTitle = wordBitButton.titleLabel?.text else { return }
        currentAnswerTextField.text = currentAnswerTextField.text?.appending(buttonTitle)
        selectedButtons.append(wordBitButton)
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { wordBitButton.alpha = 0 })
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswerTextField.text else { return }
        
        if let solutionPosition = solutionWords.firstIndex(of: answerText) {
            selectedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswerTextField.text = ""
            score += 1
            
            var canLevelUp = true
            for wordBitButton in wordBitButtons {
                if wordBitButton.alpha == 0 {
                    canLevelUp = false
                }
            }
            if canLevelUp {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Incorrect", message: "Don't give up!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: clearAction))
            present(ac, animated: true)
            score -= 1
        }
    }

    @objc func clearTapped(_ sender: UIButton) {
        clear()
    }
    
    
    //MARK: - UIViewController class
    
    //Like in projects 4 and 7, a custom loadView() method creates our user interface in code.
    override func loadView() {
        //create the main view as a white empty space
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        view.addSubview(answersLabel)
        
        currentAnswerTextField = UITextField()
        currentAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
        currentAnswerTextField.placeholder = "Tap letters to guess"
        currentAnswerTextField.textAlignment = .center
        currentAnswerTextField.font = UIFont.systemFont(ofSize: 44)
        currentAnswerTextField.isUserInteractionEnabled = false
        view.addSubview(currentAnswerTextField)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // pin the top of the clues label to the bottom of the score label
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // pin the leading edge of the clues label to the leading edge of our layout margins, adding 100 for some space
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // make the clues label 60% of the width of our layout margins, minus 100
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // also pin the top of the answers label to the bottom of the score label
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // make the answers label stick to the trailing edge of our layout margins, minus 100
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            // make the answers label take up 40% of the available space, minus 100
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            // make the answers label match the height of the clues label
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswerTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswerTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswerTextField.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
            ])
        
        // set some values for the width and height of each button
        let width = 150
        let height = 80
        
        // create 20 buttons as a 4x5 grid
        for row in 0..<4 {
            for col in 0..<5 {
                // create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                // give the button some temporary text so we can see it on-screen
                letterButton.setTitle("WWW", for: .normal)
                
                // calculate the frame of this button using its column and row
                let frame = CGRect(x: col * width, y: row * height, width: width-5, height: height-5)
                letterButton.frame = frame
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.gray.cgColor
                
                // add it to the buttons view
                buttonsView.addSubview(letterButton)
                
                // and also to our letterButtons array
                wordBitButtons.append(letterButton)
            }
        }
        
        
//        cluesLabel.backgroundColor = .red
//        answersLabel.backgroundColor = .blue
//        buttonsView.backgroundColor = .green
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadLevel()
    }
    
}


