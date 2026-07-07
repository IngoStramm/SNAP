# SNAP - Swift NPC Auto Purchase

SNAP automatically buys configured vendor items when you open an NPC/vendor window, while respecting quantity and gold limits. It is intended for limited-supply or easily missed vendor consumables in WoW Classic/TBC-style clients.

## Features

- Buy only explicitly configured item IDs.
- Per-item settings:
  - Enable/disable.
  - Maximum purchases per vendor visit.
  - Buy until you have a target quantity.
  - Maximum unit price.
- Global safety settings:
  - Maximum gold spent per vendor visit.
  - Gold to keep on the character.
  - Test mode that reports what would be bought without buying.
- Item ID entry supports Shift-clicking item links/items when the Item ID field is armed.
- Options are available from `/snap` and from `Options > AddOns > SNAP`.
- English and ptBR UI text.

## Commands

```text
/snap
/snap config
/snap options
/snap help
/snap on
/snap off
/snap test
/snap debug
/snap scan
/snap add <itemID|item link> [max purchases per visit]
/snap remove <itemID>
/snap list
/snap status
```

## Compatibility

- Interface: `20506`
- Saved variables: `SNAPDB` per character
- Tested for the WoW TBC Anniversary addon environment.

## Installation

Download `SNAP.zip` from the latest GitHub Release and extract it into:

```text
World of Warcraft/_anniversary_/Interface/AddOns/
```

After extraction, the addon folder should be:

```text
World of Warcraft/_anniversary_/Interface/AddOns/SNAP/
```

Restart the game or reload the UI.

Do not use GitHub's green **Code > Download ZIP** button for installation. That downloads the source repository snapshot, not the packaged addon.

## Notes

SNAP cannot buy before you interact with the vendor. It reacts after the merchant window opens and can only buy items permitted by the WoW addon API.
