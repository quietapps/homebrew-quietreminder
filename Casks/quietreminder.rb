cask "quietreminder" do
  version "1.4.7"
  sha256 "52e2449cfcc7e91b73df37c823d2466dbc2609877cfa10d1cb4c8555e57a5ea7"

  url "https://github.com/quietapps/QuietReminder/releases/download/v#{version}/QuietReminder-#{version}.zip",
      verified: "github.com/quietapps/QuietReminder/"
  name "Quiet Reminder"
  desc "Flies a banner across your screen before every meeting"
  homepage "https://github.com/quietapps/QuietReminder"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: ">= :tahoe"

  app "Quiet Reminder.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Quiet Reminder.app"],
                   sudo: false
    system_command "/System/Library/Frameworks/CoreServices.framework/" \
                   "Versions/A/Frameworks/LaunchServices.framework/" \
                   "Versions/A/Support/lsregister",
                   args: ["-f", "#{appdir}/Quiet Reminder.app"],
                   sudo: false,
                   must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/app.quiet.QuietReminder.plist",
    "~/Library/Application Support/Quiet Reminder",
    "~/Library/Caches/app.quiet.QuietReminder",
    "~/Library/HTTPStorages/app.quiet.QuietReminder",
    "~/Library/Saved Application State/app.quiet.QuietReminder.savedState",
  ]

  caveats <<~EOS
    Quiet Reminder is currently distributed unsigned. The post-install hook
    strips Gatekeeper attributes automatically, but if the app refuses to
    launch on a fresh Mac, do this once:

      1. Open Finder → /Applications
      2. Right-click Quiet Reminder.app → Open
      3. Click "Open" in the dialog
      4. macOS remembers your choice for every future launch

    Or run this in Terminal once after install:
      xattr -cr "/Applications/Quiet Reminder.app"

    On first launch, click "Enable Calendar access in Settings" in the menu bar
    to grant calendar access.
  EOS
end
