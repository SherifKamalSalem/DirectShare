 

import Foundation
import RxSwift

public class PickMeUpViewModel: DropoffLocationDeterminedResponder,
                                RideOptionDeterminedResponder,
                                CancelDropoffLocationSelectionResponder {

  // MARK: - Properties
  public var view: Observable<PickMeUpView> { return viewSubject.asObservable() }
  private let viewSubject: BehaviorSubject<PickMeUpView>
  var progress: PickMeUpRequestProgress
  let newRideRepository: NewRideRepository
  let newRideRequestAcceptedResponder: NewRideRequestAcceptedResponder
  let mapViewModel: PickMeUpMapViewModel

  public var shouldDisplayWhereTo: Observable<Bool> { return shouldDisplayWhereToSubject.asObservable() }
  private let shouldDisplayWhereToSubject = BehaviorSubject<Bool>(value: true)
  public var errorMessages: Observable<ErrorMessage> { return errorMessagesSubject.asObservable() }
  private let errorMessagesSubject = PublishSubject<ErrorMessage>()
  public let errorPresentation: BehaviorSubject<ErrorPresentation?> = BehaviorSubject(value: nil)

  let disposeBag = DisposeBag()

  // MARK: - Methods
  public init(pickupLocation: Location,
              newRideRepository: NewRideRepository,
              newRideRequestAcceptedResponder: NewRideRequestAcceptedResponder,
              mapViewModel: PickMeUpMapViewModel,
              shouldDisplayWhereTo: Bool = true) {
    //Start of model-driven navigation
    self.viewSubject = BehaviorSubject(value: .initial)
    self.progress = .initial(pickupLocation: pickupLocation)
    self.newRideRepository = newRideRepository
    self.newRideRequestAcceptedResponder = newRideRequestAcceptedResponder
    self.mapViewModel = mapViewModel
    self.shouldDisplayWhereToSubject.onNext(shouldDisplayWhereTo)

    viewSubject
      .asObservable() 
      .subscribe(onNext: { [weak self] view in
        self?.updateShouldDisplayWhereTo(basedOn: view)
      })
      .disposed(by: disposeBag)
  }

  func updateShouldDisplayWhereTo(basedOn view: PickMeUpView) {
    shouldDisplayWhereToSubject.onNext(shouldDisplayWhereTo(during: view))
  }

  func shouldDisplayWhereTo(during view: PickMeUpView) -> Bool {
    switch view {
    case .initial, .selectDropoffLocation:
      return true
    case .selectRideOption, .confirmRequest, .sendingRideRequest, .final:
      return false
    }
  }

  public func cancelDropoffLocationSelection() {
    viewSubject.onNext(.initial)
  }

  ///PickMeUpViewModel changes its state to .selectRideOption and PickMeUpViewController dismisses the screen.
  public func dropOffUser(at location: Location) {
    guard case let .initial(pickupLocation) = progress else {
      fatalError()
    }
    let waypoints = NewRideWaypoints(pickupLocation: pickupLocation,
                                     dropoffLocation: location)
    progress = .waypointsDetermined(waypoints: waypoints)
    viewSubject.onNext(.selectRideOption)
    mapViewModel.dropoffLocation.onNext(location)
  }

  public func pickUpUser(in rideOptionID: RideOptionID) {
    if case let .waypointsDetermined(waypoints) = progress {
      let rideRequest = NewRideRequest(waypoints: waypoints,
                                       rideOptionID: rideOptionID)
      progress = .rideRequestReady(rideRequest: rideRequest)
      viewSubject.onNext(.confirmRequest)
    } else if case let .rideRequestReady(oldRideRequest) = progress {
      let rideRequest = NewRideRequest(waypoints: oldRideRequest.waypoints,
                                       rideOptionID: rideOptionID)
      progress = .rideRequestReady(rideRequest: rideRequest)
      viewSubject.onNext(.confirmRequest)
    } else {
      fatalError()
    }
  }

  /**
   When user tap where to button this func emits .selectDropoffLocation case event that observed by PickMeUpVC that subscribe on view observable so it reacts to the event and navigate to DropoffVC this called model-driven navigation
   */
  @objc
  public func showSelectDropoffLocationView() {
    viewSubject.onNext(.selectDropoffLocation)
  }
  
  @objc
  public func sendRideRequest() {
    guard case let .rideRequestReady(rideRequest) = progress else {
      fatalError()
    }
    viewSubject.onNext(.sendingRideRequest)
    newRideRepository.request(newRide: rideRequest)
      .done {
        self.viewSubject.onNext(.final)
      }.catch { error in
        self.goToNextScreenAfterErrorPresentation()
        let errorMessage = ErrorMessage(title: "Ride Request Error",
                                        message: "There was an error trying to confirm your ride request.\nPlease try again.")
        self.errorMessagesSubject.onNext(errorMessage)
      }
  }

  public func finishedSendingNewRideRequest() {
    newRideRequestAcceptedResponder.newRideRequestAccepted()
  }

  func goToNextScreenAfterErrorPresentation() {
    _ = errorPresentation
      .filter { $0 == .dismissed }
      .take(1)
      .subscribe(onNext: { [weak self] _ in
        self?.viewSubject.onNext(PickMeUpView.confirmRequest)
      })
  }
}
