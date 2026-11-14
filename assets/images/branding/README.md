# Temporary Rehiyonia branding

Generated on 2026-10-25 with the built-in image generation tool using the imagegen skill. These are bundled local assets, not network downloads. Replace these versioned PNGs with final commissioned branding when ready.

- `loading-islands-v1.png`: portrait loading-screen artwork. Decorative Philippine-inspired montage, not an accurate map or a single real location.
- `rehiyonia-logo-v1.png`: transparent title logo, separate from the background so the UI can size and animate it independently.
- `rehiyonia-logo-pink-v2.png`: existing pink-and-gold logo shared by the splash and Home screens, including the sun/compass and blue waves. Home adds a separate localized subtitle ribbon.
- `home-sky-scene-v1.jpg`, `home-travel-footer-v1.jpg`, `home-foliage-left-v1.jpg`, and `home-foliage-right-v1.jpg`: optimized layers derived from the existing travel backdrop. Their combined compressed size is approximately 179 KiB. Flutter positions each layer separately without stretching the full composition, and caps image decode widths. All text, controls, the geographic map, and the player's customized avatar are live Flutter widgets.

The original backdrop (generated on 2026-11-12 with the built-in image generation tool and imagegen skill) is retained at `design/home/home-travel-background.png`, outside the runtime asset bundle. It includes the jeepney and flag, mountain and historical bell tower, tropical foliage, camera, postcards, backpack, lantern, and compass. Regenerate the JPEG layers with `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/prepare_home_artwork.ps1`. All runtime artwork remains bundled for offline use.

## Generation prompts

Background:

> Use case: stylized-concept. Asset type: portrait mobile game loading background for Rehiyonia, a Philippine geography word-search adventure for children. Original polished painterly game key art: luminous tropical archipelago, turquoise lagoon, distant conical volcano, green rice terraces, small traditional outrigger boat, foreground stone path and lush foliage. Warm sunrise, deep navy shadows and gold light, inviting sense of discovery, high-end animated adventure aesthetic. Vertical composition with quiet open sky in upper third for a separate logo, darker uncomplicated bottom quarter for loading UI. No text, no logos, no UI, no weapons, no watermark. This is a decorative fantasy montage, not a literal map.

Logo (transparent background enabled):

> Use case: logo-brand. Asset type: original temporary game title logo on a genuinely transparent background. Exact text "REHIYONIA" spelled R E H I Y O N I A, one line, large legible adventurous rounded block lettering, ivory faces with tasteful gold edging and deep ocean-blue outline, compact compass and sun emblem centered above the name, small island-wave motif integrated under lettering. Premium friendly Philippine exploration word puzzle game identity. Wide compact centered composition, no background scenery, no slogan, no extra text, no watermark; not based on any existing game logo.
