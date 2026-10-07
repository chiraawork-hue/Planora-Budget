# Planora Budget V24 — Real Location Search

## One-time setup
1. Open `index.html` in a text editor.
2. Search for: `PASTE_YOUR_GEOAPIFY_KEY_HERE`
3. Replace only that text with your Geoapify API key. Keep the surrounding single quotes.
4. Save, then upload the V24 files to the Planora Budget GitHub repository.
5. The Geoapify key should remain restricted to `https://chiraawork-hue.github.io` in Geoapify.

## Location UX
- Real online Geoapify autocomplete, focused on Indonesia.
- 420 ms debounce to reduce unnecessary requests.
- Previous searches are aborted when the query changes.
- Up to 6 results.
- Loading and error states.
- If Geoapify finds no result, user can save the typed place manually.
- Selected place is shown as a compact 📍 chip and saved under the Moment caption.
- Coordinates generate a tappable Google Maps destination link.
- No V23 dummy places remain.
