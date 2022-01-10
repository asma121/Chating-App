//
//  ConversationViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth
import SDWebImage
import JGProgressHUD

struct Conversation {
    let id:String
    let name:String
    let otherUserEmail:String
    let latestMessage : LatestMessage
}

struct LatestMessage {
    let date:String
    let text:String
    let isRead:Bool
}

class ConversationViewController: UIViewController {

    @IBOutlet weak var conversationsTableView: UITableView!
    
    //let data = ["hello world"]
    
    let spinner = JGProgressHUD(style: .dark)
    
    var conversations = [Conversation]()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(noConversationsLabel)
        
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        //conversationsTableView.isHidden = true
        
        startListeningForConversations()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
  
        validateAuth()
    }
    
    func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        
        DatabaseManger.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.conversationsTableView.reloadData()
                }
            case .failure(let error):
                print("to get conversations :\(error)")
            }
        })
    }
    
    @IBAction func searchButtonBarTapped(_ sender: UIBarButtonItem) {
        let newConversationVC = self.storyboard?.instantiateViewController(identifier: "NewConversationViewController") as! NewConversationViewController
        newConversationVC.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(reslut: result)
        }
        let navVC = UINavigationController(rootViewController: newConversationVC)
       present(navVC, animated: true, completion: nil)
    }
    
    func createNewConversation(reslut : [String:String]){
        guard let name = reslut["name"] , let email = reslut["email"] else {
            return
        }
        let ChatVC = ChatViewController(with: email , id:nil)
        ChatVC.isnewConversation = true
        ChatVC.title = name
        ChatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(ChatVC, animated: true)
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let LoginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            let nav = UINavigationController(rootViewController: LoginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)

        }
    }
}

extension ConversationViewController : UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.userNameLabel.text = model.name
        cell.messageLabel.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    cell.userImageIV.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("faild to get url image :\(error)")
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        conversationsTableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let ChatVC = ChatViewController(with: model.otherUserEmail , id: model.id)
        ChatVC.title = model.name
        ChatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(ChatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}


