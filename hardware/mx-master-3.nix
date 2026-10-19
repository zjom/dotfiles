# Hardware node (NixOS): a Logitech MX Master 3 mouse. logid configures the
# scroll wheel and maps the gesture button (under the thumb) to niri actions.
{
  flake.modules.nixos.mx-master-3 =
    { ... }:
    let
      keys = keys: {
        type = "Keypress";
        inherit keys;
      };
      gesture = direction: action: {
        inherit direction;
        mode = "OnRelease";
        inherit action;
      };
    in
    {
      services.logiops = {
        enable = true;
        config.devices = [
          {
            # The name that logid reports, not the Bluetooth name.
            name = "Wireless Mouse MX Master 3";
            dpi = 1000;
            # The wheel changes from ratchet mode to free spin when it turns
            # fast.
            smartshift = {
              on = true;
              threshold = 30;
            };
            hiresscroll = {
              hires = true;
              invert = false;
              target = false;
            };
            buttons = [
              {
                # The gesture button. A press without movement opens the
                # overview. Movement focuses the next column or workspace.
                cid = 195; # 0xc3
                action = {
                  type = "Gestures";
                  gestures = [
                    (gesture "None" (keys [
                      "KEY_LEFTALT"
                      "KEY_O"
                    ]))
                    (gesture "Left" (keys [
                      "KEY_LEFTALT"
                      "KEY_LEFT"
                    ]))
                    (gesture "Right" (keys [
                      "KEY_LEFTALT"
                      "KEY_RIGHT"
                    ]))
                    (gesture "Up" (keys [
                      "KEY_LEFTALT"
                      "KEY_UP"
                    ]))
                    (gesture "Down" (keys [
                      "KEY_LEFTALT"
                      "KEY_DOWN"
                    ]))
                  ];
                };
              }
            ];
          }
        ];
      };
    };
}
