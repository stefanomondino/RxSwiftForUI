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

class ParallaxViewController: UIViewController {
    /// Layout constraint between image and superview top edges
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    /// Layout constraint for image height
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView:UIScrollView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.rx
            .bindParallax(top: imageTop, height: imageHeight, amount: 4)
            .disposed(by: disposeBag)
    }
}



