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
    # { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    #        { id = "hdokiejnpimakedhajhdlcegeplioahd"; } # LastPass
    #        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
    #        { id = "kbfnbcaeplbcioakkpcpgfkobkghlhen"; } # Grammarly
    #        { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic
    #        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock for YouTube
    #        { id = "gebbhagfogifgggkldgodflihgfeippi"; } # Return YouTube Dislike
    #        { id = "fdpohaocaechififmbbbbbknoalclacl"; } # GoFullPage
    #        { id = "clpapnmmlmecieknddelobgikompchkk"; } # Disable Automatic Gain Control
    #        { id = "cdglnehniifkbagbbombnjghhcihifij"; } # Kagi
    #        { id = "dpaefegpjhgeplnkomgbcmmlffkijbgp"; } # Kagi Summariser
    #        { id = "mdkgfdijbhbcbajcdlebbodoppgnmhab"; } # GoLinks
    #        { id = "glnpjglilkicbckjpbgcfkogebgllemb"; } # Okta
    #        { id = "cfpdompphcacgpjfbonkdokgjhgabpij"; } # Glean
    #        { id = "idefohglmnkliiadgfofeokcpjobdeik"; } # Ramp
  ];
in {
  # REF:
  # - https://github.com/will-lol/.dotfiles/blob/main/home/extensions/chromium.nix
  # - https://github.com/isabelroses/dotfiles/blob/main/modules/home/programs/chromium.nix

  programs.helium = {
    enable = true;
    dictionaries = [pkgs.hunspellDictsChromium.en_US];
    extensions = map (id: {inherit id;}) extensionIds;
    # FIXME: https://github.com/nix-community/home-manager/issues/2216
    # FIXME: also THIS! https://github.com/johnae/world/blob/main/users/modules/chromiums.nix
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

  # Extension files are managed by extension.nix module
  # which correctly handles the Helium directory path:
  # Library/Application Support/net.imput.helium/External Extensions/
}
