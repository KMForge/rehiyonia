# Pink explorer splash

Created with the built-in imagegen tool on 2026-10-25.

- `loading-explorers-v2.png`: adapted from the user's supplied explorer artwork. Embedded title, button, ribbon and lettering were removed to make space for Flutter controls. This is decorative artwork, not an authoritative geographic map.
- `rehiyonia-logo-pink-v2.png`: pink variant of the original generated logo, preserving transparency.
- `android/app/src/main/res/drawable-nodpi/rehiyonia_logo_pink.png`: the same pink logo packaged for the Android launch screen.

The native launch frame is static. Flutter supplies logo fade/scale/float, slow camera zoom, water shimmer, floating lights and lantern glow. These are ambient effects over a still illustration; the characters are not rigged animations. Reduce Motion displays a still frame. The splash remains visible for at least 4.5 seconds and also waits for actual startup readiness before opening the first-launch nickname dialog or Home. Loading percentage remains tied to completed startup tasks.

## Background edit prompt

Use case: precise-object-edit. Asset type: portrait Flutter game splash background. Image 1 is the edit target provided by the user. Keep the same friendly illustrated Philippine explorer scene, the two child explorers, the map/game board, tropical foliage, cliffs, sea, lighting, palette, framing, and vertical composition. Remove only the large REHIYONIA title, compass title mark, the 'Find words. Discover the Philippines.' subtitle, the pink START EXPLORING button, and the bottom '18 Regions • One Adventure' ribbon. Naturally reconstruct the sky and lower foliage behind those removed UI elements. Also remove any tiny embedded text/labels and letter-grid words so the art remains a clean background behind live Flutter UI. Preserve the board grid as blank decorative tiles and preserve the rest of the illustration. No new text, no logo, no buttons, no watermark.

## Logo edit prompt

Use case: precise-object-edit. Asset type: transparent mobile game title logo. Image 1 is the edit target. Preserve the exact REHIYONIA spelling, letter shapes, compass-and-sun emblem, island-and-wave motif, proportions, layout, highlights, shadows, and transparent background. Change only the logo color system: make the letter faces a vibrant warm pink-to-rose treatment, with a pale cream inner highlight, darker magenta depth and outline, and subtle gold accent lines. Recolor the compass rose primarily pink and rose with small gold highlights; keep the island green and waves turquoise so the travel theme remains clear. No extra text, no background, no watermark. Keep edges clean and readable at mobile size.
