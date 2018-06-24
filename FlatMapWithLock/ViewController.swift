//
//  ViewController.swift
//  FlatMapWithLock
//
//  Created by mnr-kjm on 2018/06/24.
//  Copyright © 2018年 minoru_kojima. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftUtilities

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var lockObject: ActivityIndicator!
    private var lockState: Observable<Bool>!
    private var callCount = 0

    @IBOutlet private var executeButton: UIButton!
    @IBOutlet private var progressIndicator: UIActivityIndicatorView!
    @IBOutlet private var callCountLabel: UILabel!

    private func alert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }

    private func doLongtimeTask() -> Observable<String> {
        self.callCount += 1
        self.callCountLabel.text = "`doLongtimeTask` called \(self.callCount) times."

        let asyncSubject = AsyncSubject<String>()

        let time = DispatchTime.now() + 5.0
        DispatchQueue.main.asyncAfter(deadline: time) {
            let result = "Complete! Endtime is \(Date().description)"
            asyncSubject.onNext(result)
            asyncSubject.onCompleted()
        }

        return asyncSubject.asObservable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize
        self.lockObject = ActivityIndicator()
        self.lockState = self.lockObject.asObservable()

        // bind lock state to animation of progress
        self.lockState
            .bind(to: self.progressIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        // bind button tap to execute long time task
        // at that time, use the lock object to restrict not to run at the same time
        self.executeButton.rx.tap
            .flatMap(withLock: self.lockObject, { [weak self] _ in
                return self?.doLongtimeTask() ?? Observable.error(MyError.assertion)
            })
            .subscribe(onNext: { [weak self] result in
                self?.alert(message: result)
            })
            .disposed(by: self.disposeBag)
    }
}
