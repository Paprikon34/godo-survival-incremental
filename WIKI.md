# 🎮 Antigravity Game Wiki

Welcome to the official wiki! Here you can find all the details about weapons, upgrades, enemies, and game mechanics.

---

## 🛡️ Player Base Stats
| Stat | Value |
| :--- | :--- |
| **Move Speed** | 200 |
| **Base Health** | 100 |
| **Regeneration** | 0.5 HP / Second |
| **Base Damage** | 100% |
| **Base XP Gain** | 100% |
| **Luck** | 100% |

---

## ⚔️ Weapons
### 🟦 Magic Shotgun (Primary)
Fires blue projectiles at the nearest enemy within range.
- **Base Damage**: 10
- **Base Cooldown**: 1.0s
- **Range**: 800px
- **Scaling**: Each level adds **+1 Projectile** (Shotgun spread).

### 🟪 Magic Wand (Unlockable)
Fires purple projectiles directly towards your mouse cursor.
- **Base Damage**: 15
- **Base Cooldown**: 1.0s
- **Scaling**: Each level reduces Cooldown by **-10%** (multiplicative).

---

## 💎 Upgrades
| Upgrade | Effect |
| :--- | :--- |
| **Heal** | Instantly restores **20 HP**. |
| **Swiftness** | Increases Move Speed by **+10%**. |
| **Power** | Increases Damage by **+10%**. |
| **Smart** | Increases XP Gain by **+10%**. |
| **Vitality** | Increases Max Health by **+10%**. |
| **Luck** | Increases Luck by **+10%**. |
| **Despair** | Enemies get **+5% Speed/HP**, but you get **+10% XP**. |

---

## 👹 Enemies
All enemies scale with your level: **+0.5 HP per player level up**.

### 🔴 Basic Enemy
The standard grunt.
- **Health**: 10 (+0.5/lvl)
- **Speed**: 100
- **Damage**: 10 per collision

### 🟡 Fast Enemy
Spawns after 2 minutes (30% chance).
- **Health**: 5 (+0.5/lvl)
- **Speed**: 300
- **Damage**: 5 per collision

### 💀 Bosses
Large red enemies that drop **Golden Chests**.
- **Boss 1 (1:30)**: 100 HP, 80 Speed.
- **Boss 2 (3:00)**: 300 HP, 80 Speed.

---

## ⚙️ Game Mechanics
### 📦 Golden Chests
Dropped by Bosses. Grants a **free level** to one of your currently owned upgrades.

### 📈 Scaling Difficulty
1. **Level-Up**: Every time the player levels up, every enemy (current and future) gains **+0.5 HP**.
2. **Despair**: Every level of Despair adds **+5% HP and Speed** to all enemies instantly.

### 🍀 Luck Mechanics
Luck multiplier (default 100%) increases the probability of "Lucky" events. There is a **5% base chance** for these events even at 100% Luck.

| Event | Base Chance (100% Luck) | Formula |
| :--- | :--- | :--- |
| **4th Level-up Choice** | **5%** | `5% + Bonus Luck` |
| **2x XP Drop** | **5%** | `5% + Bonus Luck` |
| **3x XP Drop** | **0.5%** | `(Total Chance) * 10%` |
| **2 Chest Rewards** | **5%** | `5% + Bonus Luck` |
| **3 Chest Rewards** | **1%** | `(Total Chance) * 20%` |

*Bonus Luck = (Your Luck Stat - 100%)*

### 🛠️ Debug Console
Visible if "Debug" is enabled in settings. Displays real-time logs for:
- ⚔️ Damage dealt (and remaining enemy HP)
- 🆙 Level-up events
- 🎁 Chest rewards
- 👹 Boss spawns
