 

import Foundation

public class WelcomeViewModel {

  // MARK: - Properties
  let goToSignUpNavigator: GoToSignUpNavigator
  let goToSignInNavigator: GoToSignInNavigator

  // MARK: - Methods
  /**
   A dependency container injects child view models with the Observable subject. Any child view model can push a new view enum value. The container view model observes the value and navigates to the next screen when it changes.
   take care that the injected view model in this case is OnboardingViewModel that conform to GoToSignUpNavigator
   */
  public init(goToSignUpNavigator: GoToSignUpNavigator,
              goToSignInNavigator: GoToSignInNavigator) {
    self.goToSignUpNavigator = goToSignUpNavigator
    self.goToSignInNavigator = goToSignInNavigator
  }

  /**
   called in WelcomeRootView as signup button target action
   */
  @objc
  public func showSignUpView() {
    goToSignUpNavigator.navigateToSignUp()
  }

  @objc
  public func showSignInView() {
    goToSignInNavigator.navigateToSignIn()
  }
}
