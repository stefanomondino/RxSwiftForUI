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
import MapKit

class MapCell: UICollectionViewCell {
    @IBOutlet weak var label:UILabel!
}

extension MKPointAnnotation {
    convenience init(index: Int) {
        self.init()
        // If you ever wondered if trigonometry could become useful in your life, this is one of those occasions :)
        self.coordinate =
            CLLocationCoordinate2D(latitude: 45 + sin(CLLocationDegrees(index) / 10 * 2 * .pi),
                                   longitude: 7.7 + cos(CLLocationDegrees(index) / 10 * 2 * .pi))
        self.title = "Position #\(index + 1)"
    }
}

class MapViewController: UIViewController, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        let annotations =  (0..<10).map { MKPointAnnotation(index: $0)}
        let objects = Observable<[MKPointAnnotation]>.just(annotations)
        
        objects
            .asDriver(onErrorJustReturn: [])
            .drive(mapView.rx.showAnnotations())
            .disposed(by:disposeBag)
        
        collectionView.rx
            .itemSelected
            .asDriver()
            .map { annotations[$0.item] }
            .drive(mapView.rx.centerAnnotation())
            .disposed(by: disposeBag)
        
        objects
            .bind(to: collectionView.rx.items(cellIdentifier: "MapCell", cellType: MapCell.self))
            { (row, element, cell) in
                cell.label.text = element.title
            }.disposed(by: disposeBag)
        
        collectionView
            .rx
            .currentIndex()
            .asDriver(onErrorJustReturn: 0)
            .distinctUntilChanged()
            .map { annotations[$0] }
            .drive(mapView.rx.centerAnnotation())
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

