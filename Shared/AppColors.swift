//
//  AppColors.swift
//  Relisten
//
//  Created by Alec Gorge on 3/7/17.
//  Copyright © 2017 Alec Gorge. All rights reserved.
//

import UIKit
import AGAudioPlayer

public class _AppColors : Equatable {
    
    public let primary: UIColor
    public let textOnPrimary: UIColor
    public let highlight : UIColor
    
    public let soundboard: UIColor
    public let remaster: UIColor
    
    public let mutedText: UIColor
    public let lightGreyBackground: UIColor
    
    public static func == (lhs: _AppColors, rhs: _AppColors) -> Bool {
        return lhs === rhs
    }
    
    public init(primary: UIColor, textOnPrimary: UIColor, highlight: UIColor, soundboard: UIColor, remaster: UIColor, mutedText: UIColor, lightGreyBackground: UIColor) {
        self.primary = primary
        self.textOnPrimary = textOnPrimary
        self.highlight = highlight
        self.soundboard = soundboard
        self.remaster = remaster
        self.mutedText = mutedText
        self.lightGreyBackground = lightGreyBackground
    }
    
    // Taken from the Chameleon framework (https://github.com/ViccAlexander/Chameleon).
    // Linking the framework provides more functionality than we need and messes up some styling in our app (https://github.com/RelistenNet/relisten-ios/issues/161#issuecomment-470549027)
    
    private func hsb(_ h: CGFloat, _ s: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(hue:h/360.0, saturation:s/100.0, brightness:b/100.0, alpha:1.0)
    }
    
    //pragma mark - Chameleon - Light Shades
    
    public lazy var flatBlackColor : UIColor = { return hsb(0, 0, 17) }()
    public lazy var flatBlueColor : UIColor = { return hsb(224, 50, 63) }()
    public lazy var flatBrownColor : UIColor = { return hsb(24, 45, 37) }()
    public lazy var flatCoffeeColor : UIColor = { return hsb(25, 31, 64) }()
    public lazy var flatForestGreenColor : UIColor = { return hsb(138, 45, 37) }()
    public lazy var flatGrayColor : UIColor = { return hsb(184, 10, 65) }()
    public lazy var flatGreenColor : UIColor = { return hsb(145, 77, 80) }()
    public lazy var flatLimeColor : UIColor = { return hsb(74, 70, 78) }()
    public lazy var flatMagentaColor : UIColor = { return hsb(283, 51, 71) }()
    public lazy var flatMaroonColor : UIColor = { return hsb(5, 65, 47) }()
    public lazy var flatMintColor : UIColor = { return hsb(168, 86, 74) }()
    public lazy var flatNavyBlueColor : UIColor = { return hsb(210, 45, 37) }()
    public lazy var flatOrangeColor : UIColor = { return hsb(28, 85, 90) }()
    public lazy var flatPinkColor : UIColor = { return hsb(324, 49, 96) }()
    public lazy var flatPlumColor : UIColor = { return hsb(300, 45, 37) }()
    public lazy var flatPowderBlueColor : UIColor = { return hsb(222, 24, 95) }()
    public lazy var flatPurpleColor : UIColor = { return hsb(253, 52, 77) }()
    public lazy var flatRedColor : UIColor = { return hsb(6, 74, 91) }()
    public lazy var flatSandColor : UIColor = { return hsb(42, 25, 94) }()
    public lazy var flatSkyBlueColor : UIColor = { return hsb(204, 76, 86) }()
    public lazy var flatTealColor : UIColor = { return hsb(195, 55, 51) }()
    public lazy var flatWatermelonColor : UIColor = { return hsb(356, 53, 94) }()
    public lazy var flatWhiteColor : UIColor = { return hsb(192, 2, 95) }()
    public lazy var flatYellowColor : UIColor = { return hsb(48, 99, 100) }()
    
    //pragma mark - Chameleon - Dark Shades
    
    public lazy var flatBlackColorDark : UIColor = { return hsb(0, 0, 15) }()
    public lazy var flatBlueColorDark : UIColor = { return hsb(224, 56, 51) }()
    public lazy var flatBrownColorDark : UIColor = { return hsb(25, 45, 31) }()
    public lazy var flatCoffeeColorDark : UIColor = { return hsb(25, 34, 56) }()
    public lazy var flatForestGreenColorDark : UIColor = { return hsb(135, 44, 31) }()
    public lazy var flatGrayColorDark : UIColor = { return hsb(184, 10, 55) }()
    public lazy var flatGreenColorDark : UIColor = { return hsb(145, 78, 68) }()
    public lazy var flatLimeColorDark : UIColor = { return hsb(74, 81, 69) }()
    public lazy var flatMagentaColorDark : UIColor = { return hsb(282, 61, 68) }()
    public lazy var flatMaroonColorDark : UIColor = { return hsb(4, 68, 40) }()
    public lazy var flatMintColorDark : UIColor = { return hsb(168, 86, 63) }()
    public lazy var flatNavyBlueColorDark : UIColor = { return hsb(210, 45, 31) }()
    public lazy var flatOrangeColorDark : UIColor = { return hsb(24, 100, 83) }()
    public lazy var flatPinkColorDark : UIColor = { return hsb(327, 57, 83) }()
    public lazy var flatPlumColorDark : UIColor = { return hsb(300, 46, 31) }()
    public lazy var flatPowderBlueColorDark : UIColor = { return hsb(222, 28, 84) }()
    public lazy var flatPurpleColorDark : UIColor = { return hsb(253, 56, 64) }()
    public lazy var flatRedColorDark : UIColor = { return hsb(6, 78, 75) }()
    public lazy var flatSandColorDark : UIColor = { return hsb(42, 30, 84) }()
    public lazy var flatSkyBlueColorDark : UIColor = { return hsb(204, 78, 73) }()
    public lazy var flatTealColorDark : UIColor = { return hsb(196, 54, 45) }()
    public lazy var flatWatermelonColorDark : UIColor = { return hsb(358, 61, 85) }()
    public lazy var flatWhiteColorDark : UIColor = { return hsb(204, 5, 78) }()
    public lazy var flatYellowColorDark : UIColor = { return hsb(40, 100, 100) }()

}

public let RelistenAppColors = _AppColors(
    primary: UIColor(red:0, green:0.616, blue:0.753, alpha:1),
    textOnPrimary: UIColor.white,
    highlight: UIColor(red:0.0, green:0.366461, blue:0.453, alpha:1.0),
    soundboard: UIColor(red:0.0/255.0, green:128.0/255.0, blue:95.0/255.0, alpha:1.0),
    remaster: UIColor(red:0, green:0.616, blue:0.753, alpha:1),
    mutedText: UIColor.gray,
    lightGreyBackground: UIColor(white: 0.97, alpha: 1.0)
)

public let RelistenPlayerColors = AGAudioPlayerColors(main: RelistenAppColors.primary, accent: RelistenAppColors.textOnPrimary)

public let PhishODAppColors = _AppColors(
    primary: UIColor(red:0, green:128.0/255.0, blue:95.0/255.0, alpha:1),
    textOnPrimary: UIColor.white,
    highlight: UIColor(red:0.0, green:0.201961, blue:0.147289, alpha: 1.0),
    soundboard: UIColor(red:0.0/255.0, green:128.0/255.0, blue:95.0/255.0, alpha:1.0),
    remaster: UIColor(red:0, green:0.616, blue:0.753, alpha:1),
    mutedText: UIColor.gray,
    lightGreyBackground: UIColor(white: 0.97, alpha: 1.0)
)

public let PhishODPlayerColors = AGAudioPlayerColors(main: PhishODAppColors.primary, accent: PhishODAppColors.textOnPrimary)


public var AppColors = RelistenAppColors

public func AppColors_SwitchToPhishOD(_ viewController: UINavigationController?) {
    if AppColors != PhishODAppColors {
        AppColors = PhishODAppColors
        
        RelistenApp.sharedApp.setupAppearance(viewController)
        
        PlaybackController.sharedInstance.viewController.applyColors(PhishODPlayerColors)
    }
}

public func AppColors_SwitchToRelisten(_ viewController: UINavigationController?) {
    if AppColors != RelistenAppColors {
        AppColors = RelistenAppColors
        
        RelistenApp.sharedApp.setupAppearance(viewController)
        
        PlaybackController.sharedInstance.viewController.applyColors(RelistenPlayerColors)
    }
}
