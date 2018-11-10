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

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}

class CarouselViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        // creates 10 UIImages in a simple observable that instantly the array and completes
        let objects = Observable<[UIImage]>
            .just((0..<10)
                .compactMap {_ in UIImage(named: "hero") })
        
        objects
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView
                .rx
                .items(cellIdentifier: "ImageCell", cellType: ImageCell.self))
            { (row, element, cell) in
                cell.imageView.image = element
            }.disposed(by: disposeBag)
        
        objects
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
            .drive(pageControl.rx.numberOfPages)
            .disposed(by:disposeBag)
        
        collectionView.rx
            .currentIndex()
            .asDriver(onErrorJustReturn: 0)
            .drive(pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
       collectionView
        .rx
        .autoscroll(interval: 2)
        .disposed(by: disposeBag)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

