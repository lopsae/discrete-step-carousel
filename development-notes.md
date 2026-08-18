Development Notes
=================


Simulator Screenshots
---------------------
To set the simulator status bar for screenshots:
```sh
xcrun simctl status_bar booted override \
  --time "9:41" \
  --batteryState discharging \
  --batteryLevel 100 \
  --dataNetwork hide
```