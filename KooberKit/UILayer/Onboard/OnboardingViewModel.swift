/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
