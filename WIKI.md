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
| **Defense** | 0 |

---

## ⚔️ Weapons
### 🟦 Magic Shotgun (Primary)
Fires blue projectiles at the nearest enemy within range.
- **Base Damage**: 10
- **Base Cooldown**: 1.0s
- **Range**: 800px (Elliptical: sides have full reach, top/bottom are shorter).
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
| **Piercing** | Projectiles pierce **+1 Enemy**. |
| **Despair** | Enemies get **+5% Speed/HP**, but you get **+10% XP**. |
| **Defense** | Increases Defense by **+2.5**. |

---

## 👹 Enemies
All enemies scale with your level: **+0.5 HP per player level up**.

### 🔴 Basic Enemy
The standard grunt.
- **Health**: 10 (+0.5/lvl)
- **Speed**: 100
- **Damage**: 10 (0.5s rate)
- **XP Bounty**: 10

### 🟡 Fast Enemy
Spawns after 2 minutes (30% chance).
- **Health**: 5 (+0.5/lvl)
- **Speed**: 300
- **Damage**: 5 (0.5s rate)
- **XP Bounty**: 10

### 🏰 Tank Enemy
Spawns after 3 minutes (20% chance).
- **Health**: 30 (+0.5/lvl)
- **Speed**: 60
- **Damage**: 15 (0.5s rate)
- **XP Bounty**: 25

### 🟪 Splitting Enemy
Spawns after 5 minutes.
- **Health**: 50 (+0.5/lvl)
- **Speed**: 90
- **Ability**: Splits into 2 **Basic Enemies** upon death.
- **XP Bounty**: 50

### 💀 Bosses
Large red enemies that drop **Golden Chests**.
- **Boss 1 (1:30)**: 100 HP, 80 Speed, **500 XP Bounty**.
- **Boss 2 (3:00)**: 300 HP, 80 Speed, **500 XP Bounty**.

---

## ⚙️ Game Mechanics
### 📦 Golden Chests
Dropped by Bosses. Grants a **free level** to one of your currently owned upgrades.

### 📈 Scaling Difficulty
1. **Level-Up**: Every time the player levels up, every enemy (current and future) gains **+0.5 HP**.
2. **Despair**: Every level of Despair adds **+5% HP and Speed** to all enemies instantly.
3. **🕒 Spawn Rate**: The spawn interval decreases linearly over time, reaching maximum difficulty at **10 minutes**.
    - **Initial Rate**: 1 enemy every 2.0s
    - **Final Rate (10m)**: 1 enemy every 0.4s
    - **Ramp Time**: 600 seconds (10 minutes)
    - **Spawn Distance**: ~730px from player (off-screen radius).

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

### 🌊 Waves & Spawning
Spawning is handled via `WaveData` resources linked in the `MapData`.
- **Wave 1 (0:00)**: Basic + Fast enemies.
- **Wave 2 (1:30)**: **Boss I** appears.
- **Wave 3 (3:00)**: **Boss II** appears.
- **Wave 4 (4:00)**: **Elite Boss** (High HP, High Speed) appears.
- **Wave 5 (5:00)**: **Void Splitter** (Special Boss) appears.
    - **Ability**: Cellular Division. Splits into 4 Fragments at 50% HP.
- **Post-5m**: **Elite Enemies** begin spawning frequently.


### 🛠️ Debug Console
Visible if "Debug" is enabled in settings.
- **Real-time Logs**: Tracks damage dealt, level-up events, chest rewards, and boss spawns.
- **Enemy Counter**: Displays the number of currently active enemies in the top-right of the console.
- **Stacked Health Bars**: If multiple bosses are active, their health bars will stack vertically in the top-right corner.
- **Simplified Name**: All bosses are identified simply as "BOSS" in the UI for clarity.

### 💀 Cheat Menu (Developer Only)
Accessible only if "Cheats" are enabled in the global settings. Features a vertical button panel on the **right side**:
- **Time Manipulation**: Skip directly to Boss 1 (1:29), Boss 2 (2:59), Elite Boss (3:59), Void Splitter (4:59), or **Reset Timer** to 0:00.
- **Invincibility (God Mode)**: Toggle ignoring all incoming damage (Press again to disable).
- **Infinite Damage**: Toggle setting Damage Multiplier to 1000x (Press again to reset to 1x).
