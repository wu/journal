#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail -o errtrace

trap 'echo EXITED: "${BASH_SOURCE}" "${LINENO}"' ERR

echo "setting theme to graphite..."
defaults write -g AppleAquaColorVariant 6

echo "Setting highlight color to pink..."
defaults write -g AppleHighlightColor "1.000000 0.749020 0.823529"

echo "Setting interface style to dark..."
defaults write -g AppleInterfaceStyle Dark

echo "disable auto-correct and smart quotes..."
defaults write -g NSAutomaticCapitalizationEnabled 0
defaults write -g NSAutomaticDashSubstitutionEnabled 0
defaults write -g NSAutomaticPeriodSubstitutionEnabled 0
defaults write -g NSAutomaticQuoteSubstitutionEnabled 0
defaults write -g NSAutomaticSpellingCorrectionEnabled 0
defaults write -g NSAutomaticTextCompletionEnabled 0
defaults write -g WebAutomaticSpellingCorrectionEnabled 0

echo "allow full keyboard access to all controls..."
defaults write -g AppleKeyboardUIMode 2

echo "enable hot corners..."
defaults write com.apple.dock wvous-br-corner -int 2
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 0
killall Dock

echo "setting screensaver to arabesque..."
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>CleanExit</key>
        <string>YES</string>
        <key>PrefsVersion</key>
        <integer>100</integer>
        <key>moduleDict</key>
        <dict>
                <key>moduleName</key>
                <string>Arabesque</string>
                <key>path</key>
                <string>/System/Library/Screen Savers/Arabesque.saver</string>
                <key>type</key>
                <integer>0</integer>
        </dict>
        <key>tokenRemovalAction</key>
        <integer>0</integer>
</dict>
</plist>
' >> screensaver.plist
plutil -convert binary1 screensaver.plist
defaults -currentHost import com.apple.screensaver screensaver.plist
rm screensaver.plist

echo "Complete!"
