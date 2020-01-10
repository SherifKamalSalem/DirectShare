 

import UIKit
import KooberUIKit
import PromiseKit
import KooberKit
import RxSwift

public class MainViewController: NiblessViewController {

  // MARK: - Properties
  // View Model
  let viewModel: MainViewModel

  // Child View Controllers
  let launchViewController: LaunchViewController
  var signedInViewController: SignedInViewController?
  var onboardingViewController: OnboardingViewController?

  // State
  let disposeBag = DisposeBag()

  // Factories
  let makeOnboardingViewController: () -> OnboardingViewController
  let makeSignedInViewController: (UserSession) -> SignedInViewController

  // MARK: - Methods
  public init(viewModel: MainViewModel,
              launchViewController: LaunchViewController,
              onboardingViewControllerFactory: @escaping () -> OnboardingViewController,
              signedInViewControllerFactory: @escaping (UserSession) -> SignedInViewController) {
    self.viewModel = viewModel
    self.launchViewController = launchViewController
    self.makeOnboardingViewController = onboardingViewControllerFactory
    self.makeSignedInViewController = signedInViewControllerFactory
    super.init()
  }

  func subscribe(to observable: Observable<MainView>) {
    observable
      .subscribe(onNext: { [weak self] view in
        guard let strongSelf = self else { return }
        strongSelf.present(view)
      })
      .disposed(by: disposeBag)
  }

  public func present(_ view: MainView) {
    switch view {
    case .launching:
      presentLaunching()
    case .onboarding:
      if onboardingViewController?.presentingViewController == nil {
        if presentedViewController.exists {
          // Dismiss profile modal when signing out.
          dismiss(animated: true) { [weak self] in
            self?.presentOnboarding()
          }
        } else {
          presentOnboarding()
        }
      }
    case .signedIn(let userSession):
      presentSignedIn(userSession: userSession)
    }
  }

  public func presentLaunching() {
    addFullScreen(childViewController: launchViewController)
  }

  /**
   After MainViewController presents a new OnboardingViewController, MainViewController removes and deallocates any previous SignedInViewController from the view hierarchy. This could happen on a sign out
   */
  public func presentOnboarding() {
    let onboardingViewController = makeOnboardingViewController()
    onboardingViewController.modalPresentationStyle = .fullScreen
    present(onboardingViewController, animated: true) { [weak self] in
      guard let strongSelf = self else {
        return
      }

      strongSelf.remove(childViewController: strongSelf.launchViewController)
      if let signedInViewController = strongSelf.signedInViewController {
        strongSelf.remove(childViewController: signedInViewController)
        strongSelf.signedInViewController = nil
      }
    }
    self.onboardingViewController = onboardingViewController
  }

  /**
   When the user signs in, MainViewController creates a brand new SignInViewController. Then, MainViewController removes any previous OnboardingViewController from the view hierarchy.
   After the app switches from non-authenticated to authenticated scope, only the SignedInViewController exists. For any UI that existed in the non-authenticated scope, the application tears it down and deallocates it.
   */
  public func presentSignedIn(userSession: UserSession) {
    remove(childViewController: launchViewController)

    let signedInViewControllerToPresent: SignedInViewController
    if let vc = self.signedInViewController {
      signedInViewControllerToPresent = vc
    } else {
      signedInViewControllerToPresent = makeSignedInViewController(userSession)
      self.signedInViewController = signedInViewControllerToPresent
    }

    addFullScreen(childViewController: signedInViewControllerToPresent)

    if onboardingViewController?.presentingViewController != nil {
      onboardingViewController = nil
      dismiss(animated: true)
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    observeViewModel()
  }

  private func observeViewModel() {
    let observable = viewModel.view.distinctUntilChanged()
    subscribe(to: observable)
  }
}
