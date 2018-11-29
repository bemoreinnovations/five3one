//
//  FirstViewController.swift
//  five3one
//
//  Created by Cody Dillon on 10/17/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Floaty
import Firebase
import RxSwift
import RxFirebase
import Parse

class LiftsViewController: ButtonBarPagerTabStripViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        
        settings.style.buttonBarItemBackgroundColor = UIColor.AppColors.blue
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.selectedBarBackgroundColor = UIColor.black
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarItemFont = .systemFont(ofSize: 14)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let floaty = Floaty()
        floaty.addItem(title: "Start a 5/3/1 Cycle", handler: { item in
            self.startCycle()
            floaty.close()
        })
        self.view.addSubview(floaty)
    }
    
    func startCycle() {
        if let user = Auth.auth().currentUser {
            
            let today = Date()
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
            let startDate = Calendar.current.date(from: dateComponents)! as NSDate
            
            let db = Firestore.firestore()
            let doc = db.collection("users")
                .document(user.uid)
                .collection("cycles")
                .document()
//                .document("\(startDate)")
            
            doc.rx.setData([
                "startDate": startDate
                ]).subscribe(onNext: { _ in
                    let alert = UIAlertController(title: "New Cycle", message: "New cycle created", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }, onError: { error in
                    print(error.localizedDescription)
                }).disposed(by: self.disposeBag)
            
            if let parseUser = PFUser.current() {
                let cycle = Cycle()
                
                cycle.startDate = startDate
                cycle.user = parseUser
                
                cycle.squat = parseUser.value(forKey: "squat") as? NSNumber
                cycle.benchPress = parseUser.value(forKey: "benchPress") as? NSNumber
                cycle.deadlift = parseUser.value(forKey: "deadlift") as? NSNumber
                cycle.shoulderPress = parseUser.value(forKey: "shoulderPress") as? NSNumber
                
                parseUser.setValue(cycle, forKey: "currentCycle")
                parseUser.saveInBackground()
            }
            else {
                PFAnonymousUtils.logIn { (user, error) in
                    
                    if (error != nil) {
                        print(error?.localizedDescription)
                    }
                    else {
                        let cycle = Cycle()
                        
                        cycle.startDate = startDate
                        cycle.user = user
                        cycle.squat = user?.value(forKey: "squat") as? NSNumber
                        cycle.benchPress = user?.value(forKey: "benchPress") as? NSNumber
                        cycle.deadlift = user?.value(forKey: "deadlift") as? NSNumber
                        cycle.shoulderPress = user?.value(forKey: "shoulderPress") as? NSNumber
                        
                        user?.setValue(cycle, forKey: "currentCycle")
                        user?.saveInBackground()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let v1 = UIStoryboard(name: "Lifts", bundle: nil).instantiateViewController(withIdentifier: "LiftSettingsView") as! LiftSettingsViewController
        v1.viewModel = LiftViewModel(lift: Lift(name: "squat", displayName: "Squat"))
        
        let v2 = UIStoryboard(name: "Lifts", bundle: nil).instantiateViewController(withIdentifier: "LiftSettingsView") as! LiftSettingsViewController
        v2.viewModel = LiftViewModel(lift: Lift(name: "benchPress", displayName: "Bench Press"))
        
        let v3 = UIStoryboard(name: "Lifts", bundle: nil).instantiateViewController(withIdentifier: "LiftSettingsView") as! LiftSettingsViewController
        v3.viewModel = LiftViewModel(lift: Lift(name: "deadlift", displayName: "Deadlift"))
        
        let v4 = UIStoryboard(name: "Lifts", bundle: nil).instantiateViewController(withIdentifier: "LiftSettingsView") as! LiftSettingsViewController
        v4.viewModel = LiftViewModel(lift: Lift(name: "shoulderPress", displayName: "Shoulder Press"))
        
        return [v1, v2, v3, v4]
    }
}

