//
//  test.swift
//  Github
//
//  Created by 이송은 on 2022/11/25.
//

import Foundation
import RxSwift
import UIKit
let disposeBag = DisposeBag()

func testing(){
    print("-----just-----")
    Observable<Int>.just(1).subscribe(onNext: {
        print($0)
    })
    
    print("-----Of1-----")
    Observable<Int>.of(1,2,3,4,5).subscribe(onNext: {
        print($0)
    })
    
    print("-----Of2-----")
    Observable.of([1,2,3,4,5]).subscribe(onNext: {
        print($0)
    })
    
    print("-----From-----")
    Observable.from([1,2,3,4,5]).subscribe(onNext: {
        print($0)
    })
    
    print("-----subscribe-----")
    Observable.of(1,2,3).subscribe{
        print($0)
    }
    
    print("-----subscribe2-----")
    Observable.of(1,2,3).subscribe{
        if let element = $0.element{
            print(element)
        }
    }
    
    print("-----subscribe3-----")
    Observable.of(1,2,3).subscribe(onNext: {
        print($0)
    })
    
    print("-----empty-----")
    Observable<Any>.empty().subscribe({
        print($0)
    })
    
    print("-----never-----")
    Observable.never().debug("never").subscribe(onNext: {
        print($0)
    },
                                                onCompleted: {
        print("Completed")
    })
    
    print("-----range-----")
    Observable.range(start: 1, count: 9).subscribe(onNext: {
        print("2 * \($0) = \(2*$0)")
    })
    //dispose - observable 종료
    
    print("-----dispose-----")
    Observable.of(1,2,3).subscribe(onNext: {
        print($0)
    }).dispose()
    
    let disposeBag = DisposeBag()
    print("-----disposeBag-----")
    Observable.of(1,2,3).subscribe{
        print($0)
    }.disposed(by: disposeBag)
    //써야하는 이유 - 메모리 누수 잊지말기 ~ (생명주기)
    
    print("-----create-----")
    Observable.create{ observer -> Disposable in
        observer.onNext(1)
        observer.onCompleted()
        observer.onNext(2)
        return Disposables.create()
    }.subscribe{
        print($0)
    }.disposed(by: disposeBag)
    
    print("-----create2-----")
    enum MyError : Error{
        case anError
    }
    Observable<Int>.create{observer -> Disposable in
        observer.onNext(1)
        observer.onError(MyError.anError)//error이후엔 종료 complete까지 안감
        observer.onCompleted()
        observer.onNext(2)
        return Disposables.create()
    }.subscribe{
        print($0)
    }.disposed(by: disposeBag)
    //error complete dispose중 꼭 있어야 함
    
    print("-----deffered-----")
    Observable.deferred{
        Observable.of(1,2,3)
    }.subscribe{
        print($0)
    }.disposed(by: disposeBag
    )
    
    print("-----deffer2-----")
    var flip : Bool = false
    let factory : Observable<String> = Observable.deferred{
        flip = !flip
        
        if flip {
            return Observable.of("up")
        }else{
            return Observable.of("down")
        }
    }
    for _ in 0...3{
        factory.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    //factory ?
    
}

func text2(){
    
    enum TraitsError : Error{
        case single
        case maybe
        case completable
    }
    
    print("-----Single1-----")
    Single<String>.just("checked").subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error :", $0)
        },
        onDisposed: {
            print("disposed")
        }
    ).disposed(by: disposeBag)
    
    //        print("-----Single2-----")
    //        Single<String>.create{ observer -> Disposable in
    //            observer.onError(TraitsError.single)
    //            return Disposables.create ()
    //        }.asSingle().subscribe(
    //            onSucess : {
    //                print($0)
    //            },
    //            onFailure : {
    //                print("error : " , $0.localizedDescription)
    //            },
    //            onDisposed : {
    //                print("disposed")
    //            }
    //        ).disposed(by : disposeBag)
    
    print("-----Single3-----")
    struct SomeJSON : Decodable{
        let name : String
    }
    enum JSONError : Error{
        case decodingError
    }
    
    let json1 = """
{"name" : "park"}
"""
    //잘못된 키 값
    let json2 = """
{"my_name" : "lee"}
"""
    func decode(json : String) -> Single<SomeJSON>{
        Single<SomeJSON>.create { observer -> Disposable in
            guard let data = json.data(using : .utf8),
                  let json = try? JSONDecoder().decode(SomeJSON.self, from: data)else{
                observer(.failure(JSONError.decodingError))
                return Disposables.create()
            }
            observer(.success(json))
            return Disposables.create()
        }
    }
    decode(json: json1).subscribe{
        switch $0{
        case .success(let json) : print(json.name)
        case .failure(let error) : print(error)
        }
    }.disposed(by: disposeBag)
    
    decode(json: json2).subscribe{
        switch $0{
        case .success(let json) : print(json)
        case .failure(let error) : print(error)
        }
    }.disposed(by: disposeBag)
    
    print("-----maybe-----")
    Maybe<String>.just("checked").subscribe(
        onSuccess: {print($0)},
        onError : {print($0)},
        onCompleted: {print("completed")},
        onDisposed: {print("disposed")}
    ).disposed(by: disposeBag)
    
    print("-----maybe2-----")
    Observable<String>.create{ observer -> Disposable in
        observer.onError(TraitsError.maybe)
        return Disposables.create()
    }.asMaybe()
        .subscribe(
            onSuccess: {_ in print("성공")},
            onError : {_ in print("에러")},
            onCompleted: {print("completed")},
            onDisposed: {print("disposed")}
        ).disposed(by: disposeBag)
    
}

func test3(){
    //publish subject
    let publishSubject = PublishSubject<String>()
    publishSubject.onNext("11111111")
    
    let subscriber1 = publishSubject.subscribe(onNext: {
        print($0)
    })
    
    publishSubject.onNext("222222")
    publishSubject.on(.next("33333333"))
    
    subscriber1.dispose()
    
    let subscriber2 = publishSubject.subscribe(onNext: {
        print($0)
    })
    
    publishSubject.onNext("4444444")
    
    subscriber2.dispose()
    
    let subscriber3 = publishSubject.subscribe(onNext: {print($0)})
    
    publishSubject.onNext("555555")
    publishSubject.onNext("666666")
    publishSubject.onNext("777777")
    
    subscriber3.dispose()
    
    //behavior subject
    enum SubjectError : Error{
        case error1
    }
    
    let behaviorSubject = BehaviorSubject<String>(value: "0.init")
    
    behaviorSubject.onNext("1")
    behaviorSubject.subscribe{
        print("first : ",$0.element ?? $0)
    }.disposed(by: disposeBag)
    
    //        behaviorSubject.onError(SubjectError.error1)
    behaviorSubject.onNext("2")
    behaviorSubject.onNext("3")
    behaviorSubject.onNext("4")
    
    behaviorSubject.subscribe{
        print("second : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    behaviorSubject.onNext("5")
    behaviorSubject.onNext("6")
    behaviorSubject.onNext("7")
    behaviorSubject.subscribe{
        print("third : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    behaviorSubject.onNext("8")
    behaviorSubject.onNext("9")
    behaviorSubject.onNext("10")
    behaviorSubject.subscribe{
        print("fourth : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    
    let value = try? behaviorSubject.value()
    print(value)
    
    
    //replay subject
    print("replay subject---------------------")
    let replaySubject = ReplaySubject<String>.create(bufferSize: 2)
    replaySubject.onNext("1")
    replaySubject.onNext("2")
    replaySubject.onNext("3")
    
    replaySubject.subscribe{
        print("first : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    replaySubject.onNext("4")
    replaySubject.onNext("5")
    replaySubject.onNext("6")
    
    replaySubject.subscribe{
        print("second : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    
    replaySubject.onNext("7")
    replaySubject.onNext("8")
    replaySubject.onNext("9")
    
    replaySubject.onError(SubjectError.error1)
    
    replaySubject.subscribe{
        print("third : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
    
    replaySubject.onNext("10")
    replaySubject.onNext("11")
    replaySubject.onNext("12")
    
    replaySubject.subscribe{
        print("fourth : ", $0.element ?? $0)
    }.disposed(by: disposeBag)
}

func test4(){
    print("ignoreElements-------------")
    let sleep = PublishSubject<String>()
    sleep.ignoreElements().subscribe{
        print("morning")
    }.disposed(by: disposeBag)
    
    sleep.onNext("alarm")
    sleep.onNext("alarm")
    sleep.onNext("alarm")
    
    sleep.onCompleted()
    
    print("elementAt------------")
    let lunch = PublishSubject<String>()
    //특정 인덱스애서 방출
    lunch.element(at: 2).subscribe{
        print($0)
    }.disposed(by: disposeBag)
    
    lunch.onNext("alarm1")
    lunch.onNext("alarm2")
    lunch.onNext("alarm3")
    lunch.onNext("alarm4")
    
    
    print("filter-------------")
    Observable.of(1,2,3,4,5,6,7,8).filter{$0 % 2 == 0}.subscribe(onNext : {print($0)}).disposed(by: disposeBag)
    
    
    print("skip--------------")
    Observable.of(1,2,3,4,5).skip(2).subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    
    print("skipwhile--------------")
    Observable.of(1,2,3,4,5).skip(while: {
        $0 != 3
    }).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    
    print("skipUntil--------------")
    let customer = PublishSubject<String>()
    let open = PublishSubject<String>()
    
    customer.skip(until: open).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    customer.onNext("1")
    customer.onNext("2")
    customer.onNext("3")
    customer.onNext("4")
    
    open.onNext("open~")
    
    customer.onNext("5")
    customer.onNext("6")
    customer.onNext("7")
    
    
    print("take----------")
    Observable.of(1,2,3,4,5).take(3).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    print("takewhile------------")
    Observable.of(1,2,3,4,5).take(while: {$0 != 3}).subscribe(onNext : {
        print($0)
    }).disposed(by: disposeBag)
    
    print("enumrated----------")
    Observable.of(1,2,3,4,5).enumerated().take(while: {
        $0.index < 3
    }).subscribe(onNext : {
        print($0)
    }).disposed(by: disposeBag)
    
    print("takeUntil------------")
    let sugang = PublishSubject<String>()
    let deadline = PublishSubject<String>()
    
    sugang.take(until: deadline).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    sugang.onNext("1")
    sugang.onNext("2")
    sugang.onNext("3")
    
    deadline.onNext("the end")
    
    sugang.onNext("4")
    sugang.onNext("5")
    
    print("distinct until changed-------")
    Observable.of(1,1,2,2,3,3,4,4,4,4,5,5,5,6,6,6).distinctUntilChanged().subscribe(onNext:{
        print($0)
    }).disposed(by: disposeBag)
}


func test5(){
    //변환 연산자
    
    //array로 변환
    print("toArray----------")
    Observable.of(1,2,3).toArray().subscribe(onSuccess: {
        print($0)
    }).disposed(by: disposeBag)
    
    print("map-----------")
    Observable.of(Date()).map{ date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from : date)
        
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    print("flatMap----------")
    
    
    let korean = yangungsunsu(score: BehaviorSubject<Int>(value: 10))
    let american = yangungsunsu(score: BehaviorSubject<Int>(value: 8))
    
    let olympic = PublishSubject<sunsu>()
    
    olympic.flatMap{ sunsu in
        sunsu.score
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    olympic.onNext(korean)
    korean.score.onNext(10)
    
    olympic.onNext(american)
    korean.score.onNext(10)
    american.score.onNext(9)
    
    print("flatMapLatest----------")
    //가장 최신값만 조회 ex 검색
    let s = highhope(score: BehaviorSubject(value: 7))
    let j = highhope(score: BehaviorSubject(value: 6))
    
    let game = PublishSubject<sunsu>()
    
    game.flatMapLatest{ sunsu in
        sunsu.score
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    game.onNext(s)
    s.score.onNext(9)
    
    game.onNext(j)
    s.score.onNext(10)
    j.score.onNext(8)
    
    print("materialize and dematerialize-------------")
    let rabbit = runSunsu(score: BehaviorSubject<Int>(value: 0))
    let chita = runSunsu(score: BehaviorSubject<Int>(value: 1))
    
    let run100m = BehaviorSubject<sunsu>(value: rabbit)
    
    run100m.flatMapLatest{ sunsu in
        sunsu.score.materialize()
    }.filter{
        guard let error = $0.error else{
            return true
        }
        print(error)
        return false
    }.dematerialize() //
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    
    rabbit.score.onNext(1)
    rabbit.score.onError(foul.earlyRun)
    rabbit.score.onNext(2)
    
    run100m.onNext(chita)
    
    print("phonenumber-----------")
    let input = PublishSubject<Int?>()
    
    let list : [Int] = [1]
    
    input.flatMap{
        $0 == nil ? Observable.empty() : Observable.just($0)
    }.map{ $0!}.skip(while: {$0 != 0}).take(11).toArray().asObservable().map{
        $0.map { "\($0)"}
    }.map{ numbers in
        var numberList = numbers
        numberList.insert("-", at: 3)
        numberList.insert("-", at: 8)
        let number = numberList.reduce(" ", +)
        return number
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    input.onNext(0)
    input.onNext(10)
    input.onNext(4)
    input.onNext(5)
    input.onNext(5)
    input.onNext(4)
    input.onNext(2)
    input.onNext(5)
    input.onNext(nil)
    input.onNext(9)
    input.onNext(nil)
    input.onNext(7)
    input.onNext(nil)
    input.onNext(7)

    
}


protocol sunsu {
var score : BehaviorSubject<Int> { get }
}

struct yangungsunsu : sunsu {
var score : BehaviorSubject<Int>
}

struct highhope : sunsu {
var score : BehaviorSubject<Int>
}

enum foul : Error{
case earlyRun
}

struct runSunsu : sunsu{
var score : BehaviorSubject<Int>
}
