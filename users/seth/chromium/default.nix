{
  pkgs,
  # lib,
  ...
}: let
  extensionIds = [
    "egnjhciaieeiiohknchakcodbpgjnchh" # tab wrangler
    "ekhagklcjbdpajgpjgmbionohlpdbjgc" # zotero connector
    "hkligngkgcpcolhcnkgccglchdafcnao" # web archives
    "khgocmkkpikpnmmkgmdnfckapcdkgfaf" # 1password Beta
    "gfbliohnnapiefjpjlpjnehglfpaknnc" # surfingkeys
    "egpjdkipkomnmjhjmdamaniclmdlobbo" # firenvim
  ];
in {
  # REF: https://github.com/will-lol/.dotfiles/blob/main/home/extensions/chromium.nix
  programs.helium = {
    enable = true;
    dictionaries = [pkgs.hunspellDictsChromium.en_US];
    extensions = map (id: {inherit id;}) extensionIds;
    # extensions = let
    #   createChromiumExtensionFor = browserVersion: {
    #     id,
    #     sha256,
    #     version,
    #   }: {
    #     inherit id;
    #     crxPath = builtins.fetchurl {
    #       url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
    #       name = "${id}.crx";
    #       inherit sha256;
    #     };
    #     inherit version;
    #   };
    #   createChromiumExtension = createChromiumExtensionFor (lib.versions.major pkgs.ungoogled-chromium.version);
    # in [
    #   # (createChromiumExtension {
    #   #   # ublock origin
    #   #   id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    #   #   sha256 = "sha256:0ycnkna72n969crgxfy2lc1qbndjqrj46b9gr5l9b7pgfxi5q0ll";
    #   #   version = "4.7.0";
    #   # })
    #   (createChromiumExtension {
    #     # surfingkeys
    #     id = "khgocmkkpikpnmmkgmdnfckapcdkgfaf";
    #     sha256 = "sha256:0ycnkna72n969crgxfy2lc1qbndjqrj46b9gr5l9b7pgfxi5q0ll";
    #     # version = "4.7.0";
    #   })
    # ];
    # commandLineArgs = [
    #   "--ignore-gpu-blocklist"
    #   "--disk-cache=$XDG_RUNTIME_DIR/helium-cache"
    #   "--no-first-run"
    #   "--disable-wake-on-wifi"
    #   "--disable-breakpad"
    #   "--no-default-browser-check"
    #   "--enable-features=TouchpadOverscrollHistoryNavigation"
    # ];
  };

  imports = [./extension.nix];

  home.file = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin builtins.listToAttrs (
    map (id: {
      name = "Library/Application Support/Google/Chrome/External Extensions/${id}.json";
      value = {
        text = builtins.toJSON {
          external_update_url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&x=id%3D${id}%26installsource%3Dondemand%26uc";
          # external_update_url = "https://clients2.google.com/service/update2/crx";
        };
      };
    })
    extensionIds
  );
}
