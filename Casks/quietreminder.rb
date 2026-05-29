cask "quietreminder" do
  version "1.4.2"
  sha256 "19324aba8187ccec099a86a54b6f5092f44f54bc758787af06d4b50a5fd76f15"

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

  # Build is not signed with an Apple Developer ID. Make the app launchable on
  # any Mac out of the box:
  #   1. Strip ALL extended attributes (com.apple.quarantine, com.apple.macl,
  #      com.apple.provenance) so Gatekeeper does not block launch.
  #   2. Force-register the bundle with Launch Services so double-clicking from
  #      Finder / Dock launches the real binary.
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

    Quiet Reminder needs Calendar access to read upcoming events.
    Grant access when prompted on first launch.
  EOS
end
