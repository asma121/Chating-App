//
//  ChatViewController.swift
//  Chating App
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender:SenderType {
   public var senderId: String
   public var displayName: String
   public var photoURL:String
}

struct Message : MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var isnewConversation = false
    let otherUserEmail : String
    let conversationId:String?
    
   public var currentUser : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
       let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
       return Sender(senderId: safeEmail, displayName: "me", photoURL: " ")
    }
    
    //let otherUser = Sender(senderId: "other", displayName: " ")
    var messages = [Message]()
    
    init(with email:String , id:String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId , shouldScrolltoBttom: true)
        }
    }
    
    func listenForMessages(id:String , shouldScrolltoBttom:Bool){
        DatabaseManger.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
               
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrolltoBttom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("faild to get messages : \(error)")
            }
        })
    }
    
}

extension ChatViewController : MessagesDataSource , MessagesDisplayDelegate ,MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        if let sender = currentUser {
            return sender
        }
        fatalError("self sender is nil ..")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard  !text.replacingOccurrences(of: " ", with: "").isEmpty ,
               let sender = self.currentUser,
               let messageId = createMessageId() else {
            return
        }
        print("sender \(sender)")
        print(text)
        print(isnewConversation)
        let message = Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        
        if isnewConversation {
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("send message")
                    self?.isnewConversation = false
                    // send message ..
                }else{
                    print("failed to send")
                    // fail to send ..
                }
            })
        }else {
            guard let conversationId = conversationId,
                  let name = self.title else {
                return
            }
            DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail ,name: name, newMessage: message, completion: { success in
                if success {
                    print(" message sent")
                } else {
                    print("faild to sent message ")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt possibly
        // capital Self because its static
    
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
    
        print("created message id: \(newIdentifier)")
        return newIdentifier
        
    }
}
