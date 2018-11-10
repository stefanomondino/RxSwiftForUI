//
//  ViewController.swift
//  SwiftHeroesDemo
//
//  Created by Stefano Mondino on 01/11/2018.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopwatchLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable<Int>
            .clock(format: "HH:mm:ss", rate: 1)
            .asDriver(onErrorJustReturn: "")
            .drive(timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        let startToggle = startButton.rx.toggle(startingWith: false)
        
        
        startToggle
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
            .map { $0 ? "STOP" : "START"}
            .drive(startButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        
        startToggle.filter { $0 }.flatMapLatest { _ in
            Observable<Int>.stopWatch(format: "mm:ss:SSS", rate: 1/60.0)
                .takeUntil(startToggle.filter { !$0 })
        }
            .asDriver(onErrorJustReturn: "")
            .startWith("00:00:000")
            .drive(stopwatchLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        
    }
}
