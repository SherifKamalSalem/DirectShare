 

import Foundation
import RxSwift

///Navigation action with onboarding view enum as parameter for switching on signin, signup and welcome cases
public typealias OnboardingNavigationAction = NavigationAction<OnboardingView>

public class OnboardingViewModel: GoToSignUpNavigator, GoToSignInNavigator {

  // MARK: - Properties
  
  /**
   Shared observable view state holds a mutable Observable subject property with the current view enum value. A dependency container injects child view models with the Observable subject. Any child view model can push a new view enum value. The container view model observes the value and navigates to the next screen when it changes.
   */
  public var view: Observable<OnboardingNavigationAction> { return _view.asObservable() }
  private let _view = BehaviorSubject<OnboardingNavigationAction>(value: .present(view: .welcome))
  

  // MARK: - Methods
  public init() {}

  ///emit .present(view: .signup) case on _view behaviourSubject called in welcomeViewModel on onboardingVM that comform signup navigator
  public func navigateToSignUp() {
    _view.onNext(.present(view: .signup))
  }
  
  ///emit .present(view: .signin) case on _view behaviourSubject called in welcomeViewModel on onboardingVM that comform signin navigator
  public func navigateToSignIn() {
    _view.onNext(.present(view: .signin))
  }

  
  public func uiPresented(onboardingView: OnboardingView) {
    _view.onNext(.presented(view: onboardingView))
  }
}
