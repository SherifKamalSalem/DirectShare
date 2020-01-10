 

import Foundation

///take view enum as generic element have two cases present and presented
public enum NavigationAction<ViewModelType>: Equatable where ViewModelType: Equatable {

  case present(view: ViewModelType)
  case presented(view: ViewModelType)
}
