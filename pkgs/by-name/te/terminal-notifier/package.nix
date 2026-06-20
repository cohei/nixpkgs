{
  stdenv,
  runtimeShell,
  lib,
  fetchzip,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-notifier";

  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/julienXX/terminal-notifier/releases/download/${finalAttrs.version}/terminal-notifier-${finalAttrs.version}.zip";
    sha256 = "0gi54v92hi1fkryxlz3k5s5d8h0s66cc57ds0vbm1m1qk3z4xhb0";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mkdir -p $out/bin
    cp -r terminal-notifier.app $out/Applications
    cat >$out/bin/terminal-notifier <<EOF
    #!${runtimeShell}
    cd $out/Applications/terminal-notifier.app
    exec ./Contents/MacOS/terminal-notifier "\$@"
    EOF
    chmod +x $out/bin/terminal-notifier

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "-version";

  meta = {
    description = "Send User Notifications on macOS from the command-line";
    maintainers = [ ];
    homepage = "https://github.com/julienXX/terminal-notifier";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "terminal-notifier";
  };
})
