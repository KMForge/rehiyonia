# Rehiyonia launcher icon

Created using the built-in imagegen tool. Source artwork is kept here outside the Flutter asset bundle; Android packages the generated density-specific launcher resources.

- `rehiyonia-icon.png`: opaque source for legacy launcher icons.
- `rehiyonia-icon-foreground.png`: transparent source for adaptive launcher icons.
- Run `powershell -File tool/generate_launcher_icons.ps1` from the repository to regenerate Android PNG resources. Requires Windows System.Drawing.
- Android API 26+ uses `mipmap-anydpi-v26/ic_launcher.xml`, the padded foreground and a blush background. Earlier launchers use the opaque density-specific icons.
- Release version: 1.0.4, build 5. Existing Android signing configuration uses the development/debug certificate; this APK is for sideload testing.

## Original generation prompt

Create a polished square mobile game launcher icon for Rehiyonia, a cheerful Philippine geography word-search exploration game. One large highly legible playful magenta-pink capital R with a soft cream bevel and subtle deep berry shadow, integrated with a small golden compass star at its upper right and a tiny turquoise map fold at its lower left. Premium friendly illustrated casual game art, clean bold silhouette, minimal details, polished soft dimensional lighting. Solid warm pale blush background filling the entire square edge to edge. All emblem details contained within the central 60 percent of the square, generous empty background around it for Android circular masking. Exactly one letter R, no other text, no wordmark, no frame, no rounded-square outer border, no mockup, no watermark. 1024x1024 square production app icon.

## Transparent foreground edit prompt

Remove only the pale pink background from this app icon. Preserve exactly the pink R, cream edges, golden compass, turquoise map, and their silhouette and internal details. Everything outside the emblem must be fully transparent, including outer cast shadows on the removed backdrop. Keep the square canvas and same emblem placement. This is the transparent foreground layer for an Android adaptive launcher icon.
