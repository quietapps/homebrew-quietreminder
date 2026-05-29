cask "quietreminder" do
  version "1.4.5"
  sha256 "21a7f89d04876a8c1f7a434bc7b289550c3551ad8b1f1bb6d75732fb41f533cb"

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

    On first launch, Quiet Reminder opens System Settings → Privacy → Calendars.
    Enable the toggle next to Quiet Reminder, then return to the app — it activates
    automatically within a few seconds.
  EOS
end
