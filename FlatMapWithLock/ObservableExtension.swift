//
//  ObservableExtension.swift
//  FlatMapWithLock
//
//  Created by mnr-kjm on 2018/06/24.
//  Copyright © 2018年 minoru_kojima. All rights reserved.
//

import RxSwift
import RxSwiftUtilities

extension ObservableType {
    func flatMap<O>(withLock: ActivityIndicator, _ selector: @escaping (Self.E) throws -> O) -> RxSwift.Observable<O.E> where O : ObservableConvertibleType {
        return self
            .withLatestFrom(withLock) { input, loading in
                return (input, loading)
            }
            .filter { (input, loading) in
                return !loading
            }
            .flatMap({ (input, loading) -> RxSwift.Observable<O.E> in
                return (try! selector(input)).trackActivity(withLock)
            })
    }
}
