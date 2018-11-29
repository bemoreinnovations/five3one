//
//  LiftSettingsViewController.swift
//  five3one
//
//  Created by Cody Dillon on 10/17/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import RxSwift
import RxCocoa
import Firebase
import RxFirebase
import Parse

class LiftSettingsViewController: UIViewController {
    var viewModel: LiftViewModel?
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var oneRepMaxTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var repSchemes: UILabel!
    var cycle: [[Five3OneSet]]?
    public var oneRepMax: Int = 0
    var trainingMax: Int = 0
    var sets: [WorkoutSet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cycle = Five3OneSet.five3OneSets()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let viewModel = self.viewModel,
            let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let doc = db.collection("users").document(user.uid)
            
//            doc.rx.getDocument()
//                .subscribe(onNext: { document in
//
//                    if let data = document.data(),
//                        let max = data[viewModel.name] as? Int {
//                        self.oneRepMax = max
//                        self.trainingMax = Int(Double(self.oneRepMax) * 0.9)
//
//                        self.oneRepMaxTextField.text = "\(self.oneRepMax)"
//
//                        self.tableView.reloadData()
//                    }
//                }, onError: { error in
//                    print("Error fetching snapshots: \(error)")
//                }).disposed(by: self.disposeBag)
            
            if let parseUser = PFUser.current(),
                let max = parseUser.value(forKey: viewModel.name) as? Int {
                self.oneRepMax = max
                self.trainingMax = Int(Double(self.oneRepMax) * 0.9)
                
                self.oneRepMaxTextField.text = "\(self.oneRepMax)"
                
                self.tableView.reloadData()
                
                (parseUser.value(forKey: "currentCycle") as? Cycle)?.fetchIfNeededInBackground(block: { (cycle, error) in
                    let currentCycle = cycle as? Cycle

                    PFObject.fetchAllIfNeeded(inBackground: currentCycle?.workouts, block: { (objects, error) in
                        let workouts = objects as? [Workout]

                        print(workouts)
                    })

                })
            }
        }
        else {
            self.tableView.reloadData()
        }
        
        self.oneRepMaxTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .subscribe(onNext: { _ in
                
                guard let str = self.oneRepMaxTextField.text else {
                    return
                }
                
                self.oneRepMax = Int(str) ?? 0
                self.trainingMax = Int(Double(self.oneRepMax) * 0.9)
                self.tableView.reloadData()
                
                if Auth.auth().currentUser != nil {
                    self.saveMax()
                }
                else {
                    Auth.auth().signInAnonymously() { (authResult, error) in
                        self.saveMax()
                    }
                }
                
            }).disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshWorkouts()
    }
    
    func refreshWorkouts() {
        guard let user = PFUser.current(),
            let viewModel = self.viewModel else {
            return
        }
        
        if let cycle = user.value(forKey: "currentCycle") {
            
//            let subscription: Subscription<Message> = Client.shared.subscribe(myQuery)
            
            let innerQuery = PFQuery(className: "Workout")
                .whereKey("exerciseName", equalTo: viewModel.name)
                .whereKey("cycle", equalTo: cycle)
                .order(byDescending: "date")
            
            let query = PFQuery(className: "Set")
                .whereKey("workout", matchesQuery: innerQuery)
                .includeKey("workout")
            
            query.findObjectsInBackground { (objects, error) in
                if let sets = objects as? [WorkoutSet] {
                    self.sets = sets
                    
                    print(sets)
                    self.tableView.reloadData()
                }
            }
        }
        else {
            let cycle = self.newCycle()
            user.setValue(cycle, forKey: "currentCycle")
            
            user.saveInBackground()
        }
    }
    
    func newCycle() -> Cycle? {
        
        guard let user = PFUser.current() else { return nil }
        
        let cycle = Cycle()
        cycle.startDate = self.today()
        
        cycle.user = user
        cycle.squat = user.value(forKey: "squat") as? NSNumber
        cycle.benchPress = user.value(forKey: "benchPress") as? NSNumber
        cycle.deadlift = user.value(forKey: "deadlift") as? NSNumber
        cycle.shoulderPress = user.value(forKey: "shoulderPress") as? NSNumber
        
        return cycle
    }
    
    func saveMax() {
        if let viewModel = self.viewModel,
            let user = Auth.auth().currentUser {
            
            let db = Firestore.firestore()
            
            let doc = db.collection("users").document(user.uid)
            doc.updateData([
                viewModel.name: self.oneRepMax,
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        }
        
        if let viewModel = self.viewModel {
            if let parseUser = PFUser.current() {
                
                parseUser.setValue(self.oneRepMax, forKey: viewModel.name)
                parseUser.saveInBackground { (success, error) in
                    if (error != nil) {
                        print(error?.localizedDescription)
                    }
                }
            }
            else {
                PFAnonymousUtils.logIn { (user, error) in
                    
                    if (error != nil) {
                        print(error?.localizedDescription)
                    }
                    else {
                        user?.setValue(self.oneRepMax, forKey: viewModel.name)
                        user?.saveInBackground { (success, error) in
                            if (error != nil) {
                                print(error?.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
}

class LiftSettingsViewCell: UITableViewCell {
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var percentSlider: UISlider!
    
    var disposeBag = DisposeBag()
    var isDone: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag() // because life cicle of every cell ends on prepare for reuse
    }
}

extension LiftSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cycle?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.cycle?[section].count ?? -1) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiftSettingsCell", for: indexPath) as! LiftSettingsViewCell
        
        if indexPath.row == 0 {
            
            var title: String
            
            switch indexPath.section {
            case 0:
                title = "Week 1"
            case 1:
                title = "Week 2"
            case 2:
                title = "Week 3"
            case 3:
                title = "Deload"
            default:
                title = "Week 1"
            }
            
            cell.percentLabel.font = UIFont.boldSystemFont(ofSize: 17)
            cell.percentLabel.textColor = UIColor.AppColors.blue
            cell.percentLabel.text = title
            cell.repsLabel.isHidden = true
            cell.weightLabel.isHidden = true
            cell.percentSlider.isHidden = true
            cell.doneButton.isHidden = true
        }
        else {
            
            cell.percentLabel.font = UIFont.systemFont(ofSize: 17)
            cell.percentLabel.textColor = UIColor.black
            cell.repsLabel.isHidden = false
            cell.weightLabel.isHidden = false
            cell.percentSlider.isHidden = false
            cell.doneButton.isHidden = false
            
            let checked = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysTemplate)
            let unchecked = UIImage(named: "ic_unchecked")?.withRenderingMode(.alwaysTemplate)
            
            cell.doneButton.setImage(checked, for: [.selected, .highlighted])
            cell.doneButton.setImage(unchecked, for: .normal)
            cell.doneButton.tintColor = UIColor.AppColors.blue
            
            cell.doneButton
                .rx
                .tap
                .asDriver()
                .drive(onNext: { _ in
                    let isDone = !cell.isDone
                    
                    if isDone {
                        cell.doneButton.setImage(checked, for: .normal)
                    }
                    else {
                        cell.doneButton.setImage(unchecked, for: .normal)
                    }
                    
                    self.doneClicked(isDone: isDone, for: cell, at: indexPath)
                    
                    cell.isDone = isDone

                }).disposed(by: cell.disposeBag)
            
            if let set = self.cycle?[indexPath.section][indexPath.row - 1] {
                let workoutSet = self.getWorkoutSet(for: set)
                
                if workoutSet != nil {
                    cell.doneButton.setImage(checked, for: .normal)
                    cell.isDone = true
                }
                
                cell.percentLabel.text = "\(set.percent * 100)%"
                
                if indexPath.row == 3 && indexPath.section < 3 {
                    
                    if workoutSet != nil {
                        cell.repsLabel.text = "x\(workoutSet?.reps ?? NSNumber(value: set.reps))"
                    }
                    else {
                        cell.repsLabel.text = "x\(set.reps)+"
                    }
                }
                else {
                    cell.repsLabel.text = "x\(set.reps)"
                }
                
                cell.weightLabel.text = "\(self.roundUp(n: set.getWorkingWeight(for: self.trainingMax), toNearest: 5))"
                cell.percentSlider.setValue(Float(set.percent), animated: true)
            }
        }
        
        return cell
    }
    
    func doneClicked(isDone: Bool, for cell: LiftSettingsViewCell, at indexPath: IndexPath) {
        
        let checked = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysTemplate)
        let unchecked = UIImage(named: "ic_unchecked")?.withRenderingMode(.alwaysTemplate)
        if isDone {
            self.markDone(at: indexPath) { done in
                cell.isDone = done
                
                cell.doneButton.setImage(checked, for: [.selected, .highlighted])
                cell.doneButton.setImage(unchecked, for: .normal)
                cell.doneButton.tintColor = UIColor.AppColors.blue
                
                if done {
                    cell.doneButton.setImage(checked, for: .normal)
                }
                else {
                    cell.doneButton.setImage(unchecked, for: .normal)
                }
            }
        }
        else {
            if let set = self.cycle?[indexPath.section][indexPath.row - 1] {
                guard let workoutSet = self.getWorkoutSet(for: set) else {
                    return
                }
                
                cell.doneButton.setImage(unchecked, for: .normal)
                
                workoutSet.deleteInBackground(block: { (success, error) in
                    
                })
            }
        }
    }
    
    func markDone(at indexPath: IndexPath, handler: @escaping (_ isDone: Bool) -> Void) {
        if indexPath.row == 3 && indexPath.section < 3 {
            let alert = UIAlertController(title: "Reps", message: "How many reps did you get?", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter Reps"
                textField.keyboardType = UIKeyboardType.numberPad
                
                textField.rx.text.orEmpty.subscribe(onNext: { text in
                    
                    if alert.actions.count > 1 {
                        if text.isEmpty {
                            alert.actions[1].isEnabled = false
                        }
                        else {
                            alert.actions[1].isEnabled = true
                        }
                    }
                }).disposed(by: self.disposeBag)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                handler(false)
            }))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action -> Void in
                
                guard let text = alert.textFields?[0].text else {
                    return
                }
                
                if let reps = Int(text),
                    let set = self.cycle?[indexPath.section][indexPath.row - 1] {
                    var workoutSet = self.getWorkoutSet(for: set)
                    
                    if workoutSet == nil {
                        workoutSet = self.newWorkoutSet(for: set)
                    }
                    
                    workoutSet?.reps = NSNumber(value: reps)
                    
                    self.record(set: workoutSet!)
                    
                    handler(true)
                }
            }))
            
            self.present(alert, animated: true)
        }
        else {
            
            if let set = self.cycle?[indexPath.section][indexPath.row - 1] {
                let workoutSet = self.getWorkoutSet(for: set)
                self.record(set: workoutSet ?? self.newWorkoutSet(for: set))
            }
            
            handler(true)
        }
    }
    
    func getWorkoutSet(for set: Five3OneSet) -> WorkoutSet? {
        if let mySets = self.sets {
            for mySet in mySets {
                if mySet.number?.intValue == set.set && set.week == mySet.workout?.week?.intValue {
                    return mySet
                }
            }
        }
        
        return nil
    }
    
    func newWorkoutSet(for set: Five3OneSet) -> WorkoutSet {
        let workoutSet = WorkoutSet()
        workoutSet.reps = set.reps as NSNumber
        workoutSet.weight = self.roundUp(n: set.getWorkingWeight(for: self.trainingMax), toNearest: 5) as NSNumber
        workoutSet.number = set.set as NSNumber
        workoutSet.week = set.week
        
        return workoutSet
    }
    
    func record(set: CompletedSet) {
        if let viewModel = self.viewModel,
            let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let doc = db.collection("users")
                .document(user.uid)
                .collection("logs")
                .document()
            
            doc.setData([
                "week": set.week,
                "set": set.set,
                "weight": set.weightCompleted,
                "reps": set.repsCompleted,
                "exercise": viewModel.name
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        }
    }
    
    func record(set: WorkoutSet) {
        guard let user = PFUser.current() else {
            return
        }
        
        var cycle: Cycle? = user.value(forKey: "currentCycle") as? Cycle
            
        if cycle == nil {
            cycle = self.newCycle()
        }
        
        var workout: CycleWorkout
        
        if set.workout == nil {
            if let existingWorkout = self.getWorkout(for: set.week!) {
                workout = existingWorkout
            }
            else {
                workout = self.newWorkout()
            }
            set.workout = workout
        }
        else {
            workout = set.workout!
        }
        
        workout.week = set.week! as NSNumber
        workout.cycle = cycle
        
        user.setValue(cycle, forKey: "currentCycle")
        
        PFObject.saveAll(inBackground: [set, workout, cycle!, user]) { (success, error) in
            
        }
    }
    
    func getWorkout(for week: Int) -> CycleWorkout? {
        if let mySets = self.sets {
            for mySet in mySets {
                if week == mySet.workout?.week?.intValue {
                    return mySet.workout
                }
            }
        }
        
        return nil
    }
    
    func newWorkout() -> CycleWorkout {
        let workout = CycleWorkout()
        workout.date = self.today()
        workout.exerciseName = self.viewModel?.name
        
        return workout
    }
    
    func today() -> NSDate {
        let today = Date()
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        let date = Calendar.current.date(from: dateComponents)! as NSDate
        
        return date
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func round(n: Int, toNearest multiple: Int) -> Int {
        return ((n % multiple) > multiple/2) ? n + multiple - n%multiple : n - n%multiple
    }
    
    /** round n down to nearest multiple of m */
    func roundDown(n: Int, toNearest multiple: Int) -> Int {
        return n >= 0 ? (n / multiple) * multiple : ((n - multiple + 1) / multiple) * multiple;
    }
    
    /** round n up to nearest multiple of m */
    func roundUp(n: Int, toNearest multiple: Int) -> Int {
        return n >= 0 ? ((n + multiple - 1) / multiple) * multiple : (n / multiple) * multiple;
    }
}

extension LiftSettingsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.viewModel?.displayName)
    }
}
