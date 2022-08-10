# Testing
To test your changes, just `DEBUG=1 make run` the app and test it.
Make sure auto-copy and mouse-pasting works in some native Apps,
in Chromium-based browsers, and in Electron Apps.

## Tested Apps
Mousepaste was successfully tested with the follwing apps.

| App           | Selection Type | Comment |
| ------------- | -------------- | ------- |
| Script Editor | AX             |         |
| Brave         | AX             |         |
| Slack         | AX             |         |
| KeepassXC     | AX             |         |
| iTerm2        | AX             | Disable iTerms own Copy Selection to avoid leaving selections on the Pasteboard. |
| Terminal      | AX             |         |
| Finder        | AX             | Currently also file names are copied if you click too fast (detected as double click). |
| Notes         | AX             |         |
| Safari        | `Cmd+C`        |         |
| VSCode        | `Cmd+C`        | Electron Apps still have limited AX support on MacOS. AX support is possible via screen reader mode (`Alt+F1`, `Cmd+E`, `Shift+Esc`, but beware of the assistive AX sounds and disabled word wrap that come with that feature). |

## Compatibility to other Pasteboard tools
The following Pastboard apps are compatible with Mousepaste.

| App           | Status         | Comment |
| ------------- | -------------- | --------|
| Flycut        | no issues      | mouse selection is ignored even though is appears on the pasteboard briefly |
