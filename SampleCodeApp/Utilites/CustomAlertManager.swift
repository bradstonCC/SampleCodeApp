//
//  CustomAlertManager.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class CustomAlertManager: NSObject {
    
    // property to hold the current alert
//    var alertVC: UserAlertController!
    
    // the static size of the frame for alerts for posistioning
    let alertFrame = CGRect(x: 0, y: 0, width: 280, height: 48)
    
    let buttonWidth: CGFloat = 168
    let buttonHeight: CGFloat = 32
    
    let inputFieldWidth: CGFloat = 240
    let inputFieldHeight: CGFloat = 32
    
    var alertVC: CustomAlertViewController!
    
    func singleButtonAlertWithTitle(title: String, withMessage message: String, withButtonTitle buttonTitle: String) {
        //Load Custom Alert VC for use
        let alertViewController = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil, alertTitleText: title, button1Title: buttonTitle, button2IsHidden: true)

        //Set message label
        let alertMessageLabel = createAlertLabel(message: message)
        //Add message label to show when VC is shown
        alertViewController.alertItems.append(alertMessageLabel)
        //Present Alert
        CustomAlertManager.getAlertWindowViewController().present(alertViewController, animated: true, completion: nil)
    }
    
    func multiButtonAlertViewControllerWithTitle(title: String, withMessage message: String, withCancelButtonTitle buttonTitle: String, withTarget buttonTarget: Any, withButtonActions buttonActions: [[String: Selector]]) {
        //Load Custom Alert VC for use
        let alertViewController = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil, alertTitleText: title, button1Title: buttonTitle, button2IsHidden: true)
        
        //Set message label
        let alertMessageLabel = createAlertLabel(message: message)
        //Add message label to show when VC is shown
        alertViewController.alertItems.append(alertMessageLabel)
        
        //Create all Buttons and add actions associated with button
        for buttonAction in buttonActions {
            //Key holds Button title, value holds action for button
            guard let title = buttonAction.first?.key, let action = buttonAction.first?.value else {continue}
            //Create button with associated action
            let alertButton = createAlertButton(btnTitle: title, btnTarget: buttonTarget, btnAction: action, customAlertVC: alertViewController)
            //Add button to show when VC is shown
            alertViewController.alertItems.append(alertButton)
        }
        //Present Alert
        CustomAlertManager.getAlertWindowViewController().present(alertViewController, animated: true, completion: nil)
    }
    
    func inputFieldAlertWithTitle(title: String, withMessage message: String, withPlaceholder placeholderText: String, withButtonTitle buttonTitle: String) {
        //Load Custom Alert VC for use
        alertVC = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil, alertTitleText: title, button1Title: buttonTitle, button2IsHidden: true)

        //Set message input field
        let inputField = createInputField(placeholderText: placeholderText, delegateVC: alertVC)
        //Add message label to show when VC is shown
        alertVC.alertItems.append(inputField)
        
        //Present Alert
        CustomAlertManager.getAlertWindowViewController().present(alertVC, animated: true, completion: nil)
    }
    
    // helper function to add a label to the alert controller
    func createAlertLabel(message: String) -> UILabel {
        // create and configure a new label with message
        let newLabel = UILabel.init(frame: alertFrame)
        newLabel.text = message
        newLabel.textColor = .black
        newLabel.textAlignment = .center

        return newLabel
    }
    
    // helper function to add a button to the alert controller
    func createAlertButton(btnTitle: String, btnTarget: Any, btnAction: Selector, customAlertVC: CustomAlertViewController) -> UIButton {
        // position the button in middle of alert frame
        let btnX = (alertFrame.width - buttonWidth) / 2
        let btnY = (alertFrame.height - buttonHeight) / 2
        // create a new button to add to alert
        let button = UIButton.init(frame: CGRect(x: btnX, y: btnY, width: buttonWidth, height: buttonHeight))
        button.setTitle(btnTitle, for: .normal)
        button.setTitle(btnTitle, for: .highlighted)
        button.addTarget(btnTarget, action: btnAction, for: .touchUpInside)
        //Set to dismiss Alert after an option is selected
        button.addTarget(customAlertVC, action: #selector(CustomAlertViewController.dismissCustomAlert), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "alertBtnNormal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "alertBtnHighlighted"), for: .highlighted)
        
        return button
    }
    
    func createInputField(placeholderText: String, delegateVC: CustomAlertViewController) -> UITextField {
        // position the button in middle of alert frame
        let btnX = (alertFrame.width - inputFieldWidth) / 2
        let btnY = (alertFrame.height - inputFieldHeight) / 2
        // create a new input to add to alert
        let inputField = UITextField(frame: CGRect(x: btnX, y: btnY, width: inputFieldWidth, height: inputFieldHeight))
        inputField.placeholder = placeholderText
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: inputField.frame.height))
        
        let textBorderColor = UIColor(hexString: "#0B2451")
        inputField.layer.borderColor = textBorderColor.cgColor
        inputField.layer.borderWidth = 2.0
        inputField.leftView = paddingView
        inputField.leftViewMode = UITextField.ViewMode.always
        
        inputField.delegate = delegateVC
        
        return inputField
    }
    
    // get a controller wrapped in window to avoid transition issues
    class func getAlertWindowViewController() -> UIViewController {
        let tempVC = UIViewController()
        let alertWindow = UIWindow()
        alertWindow.frame = UIScreen.main.bounds
        alertWindow.windowLevel = .alert
        
        //Create View Controller that will be used as rootViewController
        alertWindow.rootViewController = tempVC
        alertWindow.screen = UIScreen.main
        alertWindow.isHidden = false
        //Set Background Color to clear so Application can be seen in background
        alertWindow.backgroundColor = .clear
        return tempVC
    }
    
}

// MARK: - Alert Classes
class CustomAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var alertItems = [UIView].init()
    
    weak var delegate: CustomAlertInputFieldDelegate?
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertTable: UITableView!
    @IBOutlet weak var alertTitle: UILabel!
    
    @IBAction func okButtonPressedAction(_ sender: Any) {
        
        //If a text field exists in alert items, call the inputfieldDidSubmit delegate method to pass input text
        for item in alertItems {
            if let textfield = item as? UITextField, let inputText = textfield.text {
                delegate?.inputfieldDidSubmit(inputfieldText: inputText)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
        
    var button2IsHidden = false
    var alertTitleText = ""
    var button2Title = "Cancel"
    var button1Title = "Ok"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        // register the cell's nib
        let nib = UINib(nibName: "CustomAlertTableViewCell", bundle: nil)
        self.alertTable.register(nib, forCellReuseIdentifier: "CustomAlertTableViewCell")
        // set table data source and delegate
        self.alertTable.dataSource = self
        self.alertTable.delegate = self
        
        //Hide cancel button if flag set
        if button2IsHidden {
            cancelButton.isHidden = true
        }
        
        //Set alert title
        setAlertTitle()
        //Set Button 1 Title
        setButton1Title()
        //Set Cancel Button Title
        setButton2Title()

    }
    
    init(nibName: String?, bundle: Bundle?, alertTitleText: String, button1Title: String, button2IsHidden: Bool, button2Title: String = "Cancel") {
        self.alertTitleText = alertTitleText
        self.button1Title = button1Title
        self.button2Title = button2Title
        self.button2IsHidden = button2IsHidden
        
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    func setAlertTitle() {
        alertTitle.text = alertTitleText
    }
    
    func setButton2Title() {
        cancelButton.setTitle(button2Title, for: .normal)
    }
    
    func setButton1Title() {
        okButton.setTitle(button1Title, for: .normal)
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if the item count is > 3 enable scrolling
        if self.alertItems.count > 3 {
            self.alertTable.isScrollEnabled = true
        } else {
            self.alertTable.isScrollEnabled = false
        }
        return alertItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomAlertTableViewCell", for: indexPath) as? CustomAlertTableViewCell else {
            print("Error: failed to dequeue re useable cell!")
            return UITableViewCell.init()
        }
        // add the alert item to the cell
        let alertItem = self.alertItems[indexPath.row]
        print(alertItem)
        cell.itemContentView.addSubview(alertItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.alertItems.count > 3 {
            return 48
        }
        return self.alertTable.frame.height / CGFloat(self.alertItems.count)
    }
    
    // MARK: - Utilities
    
    @objc func dismissCustomAlert() {
        print("Should Dismiss")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - Alert Table View Classes

class CustomAlertTableViewCell: UITableViewCell {
    @IBOutlet weak var itemContentView: UIView!
}

// MARK: - Custom Alert Input Field Delegate Protocol

protocol CustomAlertInputFieldDelegate: class {
    func inputfieldDidSubmit(inputfieldText: String)
}
