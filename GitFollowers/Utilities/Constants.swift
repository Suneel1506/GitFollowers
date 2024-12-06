
import UIKit

enum SFSymbols {
    static let location = UIImage(systemName: "mappin.and.ellipse")
    static let repos = UIImage(systemName: "folder")
    static let gists = UIImage(systemName: "text.alignleft")
    static let followers = UIImage(systemName: "heart")
    static let following = UIImage(systemName: "person.2")
}

enum Images {
    static let ghLogo = UIImage(resource: .ghLogo)
    static let placeholder = UIImage(resource: .avatarPlaceholder)
    static let emptyStateLogo = UIImage(resource: .emptyStateLogo)
}

enum screenSize {
    static let width: CGFloat = UIScreen.main.bounds.size.width
    static let height: CGFloat = UIScreen.main.bounds.size.height
    static let maxLength = max(screenSize.width, screenSize.height)
    static let minLength = min(screenSize.width, screenSize.height)
}

enum deviceTypes {
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale
    
    static let isIphoneSE = idiom == .phone && screenSize.maxLength == 568.0
    static let isIphone8Standard = idiom == .phone && screenSize.maxLength == 667.0 && nativeScale == scale
    static let isIphone8Zoomed = idiom == .phone && screenSize.maxLength == 667.0 && nativeScale > scale
    static let isIphone8PlusStandard = idiom == .phone && screenSize.maxLength == 736.0
    static let isIphone8PlusZoomed = idiom == .phone && screenSize.maxLength == 736.0 && nativeScale < scale
    static let isIphoneX = idiom == .phone && screenSize.maxLength == 812.0
    static let isIphoneXsAndXr = idiom == .phone && screenSize.maxLength == 896.0
    static let isIpad = idiom == .pad && screenSize.maxLength >= 1024.0
    
    static func isIphoneXAspectRatio() -> Bool {
        return isIphoneX || isIphoneXsAndXr
    }
}
