# Expanded avatar wardrobe

Implemented October 25, 2026.

## Player experience

- Male and female collections have separate remembered outfits. Switching bases restores that base's draft; Save persists both outfits. Reset restores the saved outfits.
- Existing clothing and accessories remain free. New free designs include a sports cap, studs, woven bracelet, striped tee, chinos, blouse, wide pants and flats.
- New earrings and bracelets have independent slots alongside headwear, glasses and necklaces.
- Locked items show their coin price. Selecting one opens a full-body preview with the current balance and an explicit purchase button. Insufficient funds show how many more coins are needed.
- Unlocks are permanent within the local game save. Buying applies the item to the draft; Save commits the outfit. Discarding outfit changes does not undo a purchase.
- Shared accessories are bought once and usable on both bases. Purchases use earned game coins only.

## Special items

| Collection | Item | Coins |
| --- | --- | ---: |
| Shared | Beret | 60 |
| Shared | Crown | 200 |
| Shared | Pearls | 70 |
| Shared | Gem pendant | 140 |
| Shared | Hoop earrings | 60 |
| Shared | Star earrings | 100 |
| Shared | Gold bangle | 60 |
| Shared | Gem cuff | 110 |
| Shared | High tops | 90 |
| Shared | Strappy sandals | 60 |
| Male | Varsity top | 120 |
| Male | Barong | 180 |
| Male | Sports shorts | 60 |
| Male | Loafers | 80 |
| Female | Bolero | 120 |
| Female | Peplum top | 160 |
| Female | Pleated shorts | 60 |
| Female | Skirt | 100 |
| Female | Heels | 140 |

## Persistence and validation

`AvatarCatalog` owns stable item IDs, prices and collection eligibility. The repository validates these again when purchasing or saving. Coin debits and ownership changes use one SQLite transaction; duplicate purchases do not charge twice and write failures roll back the debit. Earned coin increments also use a transaction.

Ownership and separate outfits use `wardrobe_owned_v1` and `wardrobe_presets_v1` in the existing progress table; no schema migration is needed. Legacy avatars retain their free items. Local saves do not provide cloud recovery after clearing app data or uninstalling.

## Verification

- `flutter analyze`: no issues.
- `flutter test --reporter expanded`: 82 tests passed.
- Coverage includes purchase rollback, simultaneous purchases/rewards, duplicate purchase requests, insufficient funds, incompatible items, database reopen, independent outfits, cancel, pending purchase taps, failed purchase UI and small-screen layout.
- Existing avatar golden remains unchanged. New visual gallery: `test/features/avatar/goldens/special_wardrobe.png`.
- Physical-device appearance and touch interaction still need a device smoke test.
