# Regional travel badges

The approved pink-and-blue passport gallery keeps two columns on phones and three on wider screens. Each cream card contains a real Philippine landmark photograph in a postage frame, the region and landmark names, a faded copy of the same photograph on the right, and the existing earned stars. Locked photographs remain recognizable with reduced saturation and a pink lock; earned photographs use full color, a gold border, and "Badge Earned!". The existing passport-cover illustration and locally bundled Fredoka font are reused.

The gallery displays the existing 18-region catalog, ordered by saved region ID. NIR remains ID 18 with code NIR and its own photograph of The Ruins in Talisay City. regionalBadgeRegions selects one saved record per supported ID. Progress remains the actual earned count over 18, using the existing condition isUnlocked && starsEarned > 0. Viewing photographs never awards badges or writes player data.

regionLandmarksProvider loads bundled assets/data/region_landmarks.json once. Its parser validates all 18 existing ID/code pairs and rejects missing or duplicate regions. LandmarkPhoto uses local JPEG assets, BoxFit.cover, and bounded image decoding; there are no runtime photo downloads. The scrollable detail sheet shows the complete photo, landmark location, and offline photo credits, source URL, license URL, and modification notice.

The photos are obtained by scripts/fetch_region_landmarks.ps1 from the reviewed sources pinned in tool/region_landmark_sources.json. The script retains creator and license metadata, resizes originals locally, and generates bundled metadata with file hashes. See assets/images/region_landmarks/README.md for every source and license. Photographic adaptations retain their original licenses; those licenses apply to the photos independently of the application code.

No gameplay, avatar, reward, navigation, database-schema, or saved-progress changes are required for this photo enhancement. Existing database migration behavior remains covered by the disk-backed badge-persistence tests.

Validation includes gallery layout and NIR state tests, small-phone rendering with enlarged text, all-18 completion, source/asset identity and JPEG decoding checks, duplicate-source rejection, locked/earned photo rendering, and existing persistence, Home, and gameplay regression checks.
