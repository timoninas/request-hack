//
//  ViewController.swift
//  UserSystem
//
//  Created by Антон Тимонин on 21.05.2020.
//  Copyright © 2020 Антон Тимонин. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ViewController: UIViewController {
    
    // MARK:-Data for Firebase
    var originalArray = [RequestHack]()
    var filteredArray = [RequestHack]()
    var toDo: Int = 0
    var done: Int = 0
    private var requestsCollectionRef: CollectionReference!
    
    
    // MARK:-IBOutlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var toDoLabel: UILabel!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsCollectionRef = Firestore.firestore().collection("requests")
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let handle = Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            if self?.emailLabel.text != nil {
                self?.emailLabel.text = user?.email
            }
        }
        
        requestsCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                debugPrint("Error fetching requests: \(error)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    let docID = document.documentID
                    let date = data["date"] as? String
                    let description = data["description"] as? String
//                    let director = data["director"] as? String
                    let isComplete = data["isDone"] as? Int
                    let receiver = data["receiver"] as? String
                    let sender = data["sender"] as? String
                    
                    var tmp = RequestHack()
                    tmp.date = date ?? ""
                    tmp.description = description ?? ""
                    tmp.isCompleted = isComplete ?? 0
                    tmp.receiver = receiver ?? ""
                    tmp.sender = sender ?? ""
                    tmp.requesid = docID ?? ""
                    
                    let currentEmail = self?.emailLabel.text
                    
                    if tmp.receiver == currentEmail {
                        self?.originalArray.append(tmp)
                        self?.filteredArray.append(tmp)
                    }
                }
                self?.tableView.reloadData()
                self?.setupVars()
            }
        }
        
    }
    
    // MARK: setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupVars() {
        toDo = 0
        done = 0
        
        for request in filteredArray {
            if request.isCompleted == 0 {
                toDo += 1
            } else {
                done += 1
            }
        }
        
        toDoLabel.text = "ToDo: \(toDo)"
        doneLabel.text = "Done: \(done)"
        doneLabel.textColor = .some(.lightGray)
    }
    
    
    //MARK:- Button functions
    @IBAction func logoutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "You can filtered tasks", message: "Chose you needed", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "All tasks", style: .default, handler: {action in
            self.makeFilter(choice: "all")
        }))
        alert.addAction(UIAlertAction(title: "ToDo tasks", style: .default, handler: {action in
            self.makeFilter(choice: "todo")
        }))
        alert.addAction(UIAlertAction(title: "Done tasks", style: .default, handler: {action in
            self.makeFilter(choice: "done")
        }))
        self.present(alert, animated: true)
    }
    func makeFilter(choice: String) {
        
        filteredArray = [RequestHack]()
        
        switch choice {
        case "todo":
            filteredArray = originalArray.filter({ (request) -> Bool in
                if request.isCompleted == 0 {
                    return true
                }
                return false
            })
        case "done":
            filteredArray = originalArray.filter({ (request) -> Bool in
                if request.isCompleted != 0 {
                    return true
                }
                return false
            })
        default:
            filteredArray = originalArray
        }
        self.tableView.reloadData()
        
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let request = filteredArray[indexPath.row]
        
        let completeAction = UIContextualAction(style: .destructive, title: "Complete") { [weak self] (_, _, _) in
            if request.isCompleted == 0 {
                self?.requestsCollectionRef.document(request.requesid).updateData(["isDone":1])
                self?.filteredArray[indexPath.row].isCompleted = 1
                
                self?.tableView.reloadData()
                self?.setupVars()
                
                for i in 0..<(self?.originalArray.count)! {
                    if self?.originalArray[i].requesid == request.requesid {
                        self?.originalArray[i].isCompleted = 1
                    }
                }
            }
        }
        
        completeAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
}

extension ViewController: UITableViewDataSource {
    
    //detailTask
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailTask" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let selectedTask = filteredArray[indexPath.row]
            let detailVC = segue.destination as! DetailViewController
            
            detailVC.task = selectedTask
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        let tmp = filteredArray[indexPath.row]
        if tmp.isCompleted == 0 {
            cell.textLabel?.textColor = .some(.black)
        } else {
            cell.textLabel?.textColor = .some(.lightGray)
        }
        cell.textLabel?.text = "\(tmp.description)"
        return cell
    }
    
    
}

