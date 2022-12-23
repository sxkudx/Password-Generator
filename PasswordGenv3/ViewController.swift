//
//  ViewController.swift
//  PasswordGenv3
//
//  Created by Dominik Lembke on 22.12.22.
//

import UIKit
import Foundation
import AudioToolbox


class ViewController: UIViewController {
    
    public var useUppercase: Bool = true
    public var useNumbers: Bool = true
    public var useSymbols: Bool = true
    
    public var passwordLenght: Int = 4
    
    public func setpassword() {
        let password = PasswordGenerator.sharedInstance.generatePassword(includeUppercase: useUppercase, includeLowercase: true, includeNumbers: useNumbers, includeSymbols: useSymbols, lenght: passwordLenght)
        displayPassword.text = String(password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBOutlets & IBActions
    
        
    @IBAction func setUppercase(_ sender: Any) {
        if checkUppercase.isOn == true {
            useUppercase = true
        }else {
            useUppercase = false
        }
    }
    
    @IBAction func setNumbers(_ sender: Any) {
        if checkNumbers.isOn == true {
            useNumbers = true
        }else {
            useNumbers = false
        }
    }
    
    @IBAction func setSymbols(_ sender: Any) {
        if checkSymbols.isOn == true {
            useSymbols = true
        }else {
            useSymbols = false
        }
    }
    
    @IBAction func setpasswordLenght(_ sender: UISlider) {
        displayPasswordLenght.text = String(Int(sender.value))
        passwordLenght = Int(sender.value)
    }
    
    @IBAction func generatePassword(_ sender: Any) {
        setpassword()
        copyhint.isHidden = false
    }
    
    @IBOutlet weak var checkUppercase: UISwitch!
    @IBOutlet weak var checkNumbers: UISwitch!
    @IBOutlet weak var checkSymbols: UISwitch!
    @IBOutlet weak var displayPasswordLenght: UILabel!
    @IBOutlet weak var displayPassword: UILabel!
    @IBOutlet weak var copyhint: UILabel!
    
    //MARK: - Copy to Clipboard
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            UIPasteboard.general.string = displayPassword.text
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            copyhint.text = "Password added to Clipboard"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.copyhint.text = "Shake me to Copy!"
                self.copyhint.isHidden = true
            }
        }
    }
}

public typealias CharactersArray = [Character]
public typealias CharactersHash = [CharactersGroup : CharactersArray]

public enum CharactersGroup {
    case Uppercase
    case Lowercase
    case Numbers
    case Symbols
    
    public static var groups: [CharactersGroup] {
        get {
            return [.Uppercase, .Lowercase, .Numbers, .Symbols]
        }
    }
    
    private static func charactersString(group: CharactersGroup) -> String {
        switch group {
        case .Uppercase:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        case .Lowercase:
            return "abcdefghijklmnopqrstuvwxyz"
        case .Numbers:
            return "0123456789"
        case .Symbols:
            return ";,&%$@#^*~"
        }
    }
    
    public static func characters(group: CharactersGroup) -> CharactersArray {
        var array: CharactersArray = []
        
        let string = charactersString(group: group)
        assert(string.count > 0)
        var index = string.startIndex
        
        while index != string.endIndex {
            let character = string[index]
            array.append(character)
            index = string.index(index, offsetBy: 1)
        }
        return array
    }
    
    public static var hash: CharactersHash {
        get {
            var hash: CharactersHash = [:]
            for group in groups {
                hash [group] = characters(group: group)
            }
            return hash
        }
    }
}

//MARK: - PasswordGenerator Class

public class PasswordGenerator {
    
    private var hash: CharactersHash = [:]
    public static let sharedInstance = PasswordGenerator()
    
    private init() {
        self.hash = CharactersGroup.hash
    }
    
    public func charactersForGroup(group: CharactersGroup) -> CharactersArray {
        if let characters = hash[group] {
            return characters
        }
        return []
    }
    
    public func generatePassword(includeUppercase: Bool = true, includeLowercase: Bool = true, includeNumbers: Bool = true, includeSymbols: Bool = true, lenght: Int = 4) -> String {
        
        var characters: CharactersArray = []
        
        if includeUppercase {
            characters.append(contentsOf: charactersForGroup(group: .Uppercase))
        }
        if includeLowercase {
            characters.append(contentsOf: charactersForGroup(group: .Lowercase))
        }
        if includeNumbers {
            characters.append(contentsOf: charactersForGroup(group: .Numbers))
        }
        if includeSymbols {
            characters.append(contentsOf: charactersForGroup(group: .Symbols))
        }
        
        var passwordArray: CharactersArray = []
        while passwordArray.count < lenght {
            let index = Int(arc4random()) % (characters.count - 1)
            passwordArray.append(characters[index])
        }
        
        let password = String(passwordArray)
        
        return password
        }
}



