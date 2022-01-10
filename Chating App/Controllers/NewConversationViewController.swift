//
//  NewConversationViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    var completion : (([String:String])->(Void))?

    @IBOutlet weak var newConvTableView: UITableView!
    
    var users = [[String : String]]()
    var result = [[String : String]]()
    var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = " Search For Users .."
        return searchBar
    }()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Result"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchBar)
        view.addSubview(noResultLabel)
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dissmisSelf))
        
        newConvTableView.isHidden = true
        newConvTableView.delegate = self
        newConvTableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noResultLabel.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)
    }
    
    @objc func dissmisSelf(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newConvTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newConvTableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = result[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(selectedUser)
        })
    }
    
    
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text , !text.isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        result.removeAll()
        
        self.searchForUsers(text: text)
    }
    
    func searchForUsers(text: String){
        if hasFetched {
            self.filterUsers(with: text)
        } else {
            DatabaseManger.shared.getAllUsers(completion: { result in
                switch result {
                case .success(let usersCollection):
                    self.hasFetched = true
                    self.users = usersCollection
                    self.filterUsers(with: text)
                case .failure(let error):
                    print("failed to get users :\(error)")
                }
            })
        }
    }
    
    func filterUsers(with text: String){
        guard hasFetched else {
            return
        }
        
        let result :[[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(text.lowercased())
        })
        self.result = result
        updateUI()
    }
    
    func updateUI(){
        if users.isEmpty {
            self.noResultLabel.isHidden = false
            self.newConvTableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.newConvTableView.isHidden = false
            self.newConvTableView.reloadData()
        }
    }
}
