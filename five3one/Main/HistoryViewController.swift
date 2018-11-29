//
//  HistoryViewController.swift
//  five3one
//
//  Created by Cody Dillon on 10/19/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import RxSwift
import RxCocoa
import RxFirebase
import Parse

class HistoryViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var textView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let user = Auth.auth().currentUser else { return }
//
//        let db = Firestore.firestore()
//
//        db.collection("users")
//            .document(user.uid)
//            .collection("logs")
//            .rx
//            .listen()
//            .subscribe(onNext: { snapshot in
//
//                var history = ""
//                for doc in snapshot.documents {
//                    let data = doc.data()
//
//                    if let weight = data["weight"],
//                        let reps = data["reps"],
//                        let exercise = data["exercise"] {
//                        history = history + "\(exercise) \(weight) x\(reps)\n"
//                    }
//                }
//
//                self.textView.text = history
//
//            }, onError: { error in
//                print(error.localizedDescription)
//            }).disposed(by: self.disposeBag)
//
//        let today = Date()
//        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
//        let startDate = Calendar.current.date(from: dateComponents)!
//
//        db.collection("users")
//            .document(user.uid)
//            .collection("cycles")
//            .order(by: "startDate", descending: true)
//            .rx
//            .getDocuments()
//            .subscribe(onNext: { snapshot in
//
//                for document in snapshot.documents {
//                    let squatRef = db.collection("exercises")
//                        .document("squat")
//
//                    db.collection("users")
//                        .document(user.uid)
//                        .collection("workouts")
//                        .whereField("cycle", isEqualTo: document.reference)
//                        .whereField("date", isEqualTo: startDate)
//                        .whereField("exercise", isEqualTo: squatRef)
//                        .rx
//                        .listen()
//                        .subscribe(onNext: { snapshot in
//
//
//                            print(snapshot.metadata)
//                            for doc in snapshot.documents {
//                                let workout = Workout(dictionary: doc.data())
//                                print(doc.data())
//                            }
//                            //                        self.textView.text = history
//
//                    }, onError: { error in
//                        print(error.localizedDescription)
//                    }).disposed(by: self.disposeBag)
//                }
//
//            }, onError: { error in
//                print(error.localizedDescription)
//            }).disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshHistory()
    }
    
    func refreshHistory() {
        guard let user = PFUser.current() else {
            return
        }
        
        let cycleQuery = PFQuery(className: "Cycle")
            .whereKey("user", equalTo: user)
            .order(byDescending: "startDate")
        
        cycleQuery.findObjectsInBackground { (objects, error) in
            if let cycles = objects as? [Cycle] {
                print(cycles)
                
                var text = ""
                var i: Int = 1
                for cycle in cycles {
                    if let date = cycle.startDate {
                        text = text + "Cycle \(i): \(date)\n"
                        i += 1
                    }
                }
                
                self.textView.text = text
            }
        }
        
        let innerQuery = PFQuery(className: "Workout")
            .order(byDescending: "date")
            .whereKey("cycle", matchesQuery: cycleQuery)

        let query = PFQuery(className: "Set")
            .whereKey("workout", matchesQuery: innerQuery)
            .includeKey("workout")

        query.findObjectsInBackground { (objects, error) in
            if let sets = objects as? [WorkoutSet] {
                print(sets)
            }
        }
    }
}

