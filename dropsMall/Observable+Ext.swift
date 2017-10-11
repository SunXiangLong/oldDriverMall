import Foundation
import RxSwift
import RxCocoa

extension ObservableType where E == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
//extension ObservableType {
//    
//    /**
//     Filters the elements of an observable sequence based on a predicate.
//     
//     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
//     
//     - parameter predicate: A function to test each source element for a condition.
//     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
//     */
//    public func filter(_ predicate: @escaping (Self.E) throws -> Bool) -> RxSwift.Observable<Self.E>
//}
extension ObservableType {
    
//    public func filter(_ predicate: @escaping (Self.E) throws -> Bool) -> RxSwift.Observable<Self.E>


    
    
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { _ in
            assertionFailure()
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
