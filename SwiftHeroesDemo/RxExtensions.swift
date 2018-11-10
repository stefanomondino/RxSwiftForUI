//
//  Extensions.swift
//  SwiftHeroesDemo
//
//  Created by Stefano Mondino on 04/11/2018.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

extension Reactive where Base: UIScrollView {
    
    func parallax(amount:CGFloat = 3.0) -> Driver<CGFloat> {
    
        return base.rx.contentOffset
            .asDriver()
            .map { -$0.y / max(1, amount) }
            .map { min(0, $0)}
    }
    
    
    func bindParallax(top: NSLayoutConstraint, height: NSLayoutConstraint, amount:CGFloat = 3.0) -> Disposable {
        
        let startingHeight = height.constant
    
        let offset = base.rx.contentOffset.asDriver().map { -$0.y }
        // Create two subscriptions for both height and top constraint
        // Returns a composite disposable that will internally dispose both subscriptions
        return Disposables.create(
            parallax(amount:amount).drive(top.rx.constant),
            offset
                .map { max(startingHeight,$0 + startingHeight)}
                .drive(height.rx.constant))
    }
}

extension Reactive where Base: UIButton {
    func toggle(startingWith start:Bool) -> Observable<Bool> {
        return   tap
            .scan(start) { last, _ in return !last }
            .share(replay: 1, scope: .forever)
    }
}

extension Observable where Element == Int {
    static func clock(format: String, rate: TimeInterval = 1.0) -> Observable<String> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return Observable<Int>
            .interval(rate, scheduler: MainScheduler.instance)
            .startWith(0)
            .map { _ in dateFormatter.string(from: Date()) }
    }
    
    static func stopWatch(format: String, rate: TimeInterval = 1.0) -> Observable<String> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let now = Date()
        let midnight = Date(timeIntervalSince1970: 0)
        return Observable<Int>
            .interval(rate, scheduler: MainScheduler.instance)
            .startWith(0)
            .map { _ -> Date in
                let delta = Date().timeIntervalSince(now)
                return midnight.addingTimeInterval(delta)
                
        }
       .map { dateFormatter.string(from: $0) }
        
    }
}

extension Reactive where Base: UICollectionView {
    func currentIndex() -> Observable<Int> {
        
        return contentOffset
            .map { $0.x }
            //Trim value to only positive values
            .map { max(0, $0)}
            .map { [weak collectionView = self.base] in
                guard let collectionView = collectionView else { return 0 }
                // index of current page is the current x-scroll amount divided by single page width
                // to avoid out-of-bounds index, we need to trim current x-scroll value to not exceed total content width
                
                let contentWidth = collectionView.collectionViewLayout
                    .collectionViewContentSize.width
                
                return Int(round((min($0, contentWidth ) / collectionView.frame.size.width)))
        }
    }
    
    func scrollToIndexPath(animated: Bool = true) -> Binder<IndexPath?> {
        return Binder(base) { base, indexPath in
            if let indexPath = indexPath {
                base.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            }
        }
    }
    
    func nextIndexPath(after time: TimeInterval) -> Observable<IndexPath?> {
        let cv = base
        return Observable<Int>
            .interval(time, scheduler: MainScheduler.instance)
            .map { _ -> IndexPath? in
                if let index = cv.indexPathsForVisibleItems.first?.item,
                    cv.numberOfSections > 0 {
                    let count = cv.numberOfItems(inSection: 0)
                    if count > 0 {
                        return IndexPath(item:(index + 1) % count, section: 0)
                    }
                }
                return nil
        }
    }
    func autoscroll(interval:TimeInterval) -> Disposable {
        let beginDragging = willBeginDragging
        
        let endDragging = didEndDragging
            .map {_ in ()}
        
        //Let the carousel automatically scroll each 2 seconds
        //To avoid unwanted behavior, autoscroll should be disabled while user is manually dragging the collection view.
        
        //1. when user did end dragging ->
        return endDragging
            .startWith(()) //simulate initial "fake" drag
            .flatMapLatest {[weak collectionView = self.base as UICollectionView] _ in
                //2. wait 2 seconds and emit the next index path
                return collectionView?
                    .rx
                    .nextIndexPath(after: interval)
                    //4 until user begins dragging the scrollview
                    .takeUntil(beginDragging) ?? .just(nil)
            }
            //3. scroll horizontally to next index path with animation
            .bind(to: scrollToIndexPath())
    }
}

extension Reactive where Base: MKMapView {
    func showAnnotations<Annotation: MKAnnotation>(animated: Bool = true) -> Binder<[Annotation]> {
        return Binder(base) { base, annotations in
            base.removeAnnotations(base.annotations)
            base.showAnnotations(annotations, animated: animated)
        }
    }
    func centerAnnotation<Annotation: MKAnnotation>() -> Binder<Annotation> {
        return Binder(base) { base, annotation in
            base.setCenter(annotation.coordinate, animated: true)
        }
    }
}
