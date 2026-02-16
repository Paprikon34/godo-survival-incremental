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

### 🗡️ Dagger (Unlockable)
Fires a dagger in the direction the player is currently facing.
- **Base Damage**: 20
- **Base Cooldown**: 0.8s
- **Scaling**: Each level reduces Cooldown by **-10%** (multiplicative).

### 🪓 Scythe (Unlockable)
Orbiting weapon that rotates around the player, dealing damage to any enemy it touches.
- **Base Damage**: 20
- **Orbit Radius**: 250px
- **Scaling**: Each level adds **+1 Scythe** to the orbit.

### ⚔️ Sword (Unlockable)
Swings in a wide arc in the direction the player is facing. High damage but short range.
- **Base Damage**: 25
- **Swing Arc**: 200 degrees
- **Scaling**: Each level increases damage and reduces cooldown.

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
| **Regeneration** | Increases Regen by **+0.1 HP/s**. |

---

## 💎 Permanent Upgrades
Available in the Main Menu using Gold. Can be disabled at any time.

| Upgrade | Effect | Max Level |
| :--- | :--- | :--- |
| **Max Health** | +10 Base HP | 5 |
| **Damage** | +5% Damage | 5 |
| **Speed** | +20 Movement Speed | 3 |
| **Regeneration** | +0.5 HP/s Regen | 3 |

## 👹 Enemies
All enemies scale with your level: **+0.5 HP per player level up**.

### 🔴 Slime
The standard grunt.
- **Health**: 10 (+0.5/lvl)
- **Speed**: 100
- **Damage**: 10 (0.5s rate)
- **XP Bounty**: 10

### 🟡 Skull
Spawns after 2 minutes (100% chance in later waves).
- **Health**: 5 (+0.5/lvl)
- **Speed**: 300
- **Damage**: 5 (0.5s rate)
- **XP Bounty**: 10

### 🏰 Tank Enemy
Spawns after 3 minutes.
- **Health**: 30 (+2/lvl)
- **Speed**: 60
- **Damage**: 15 (0.5s rate)
- **XP Bounty**: 25

### 👹 Elite Slime (Red Tint)
Spawns after 5 minutes. Tougher versions of the standard slime.
- **Health**: 45 (+0.5/lvl)
- **Speed**: 120
- **Damage**: 10 (0.5s rate)
- **XP Bounty**: 50

### 🟪 Splitting Enemy
Spawns after 5 minutes.
- **Health**: 50 (+0.5/lvl)
- **Speed**: 90
- **Ability**: Splits into 2 **Slimes** upon death.
- **XP Bounty**: 50

### 💀 Bosses
Large red enemies that act as **Portal Guardians**.
- **Boss 1 (1:30)**: 1000 HP, 120 Speed. (Enhanced AI)
	- **Behavior**: Uses a weighted decision system every 3 seconds to choose an attack.
	- **Attacks**:
		- **Barrage (30%)**: Fires a rapid stream of bullets at the player.
		- **Circular Blast (30%)**: Fires a ring of 12 projectiles.
		- **Spiral (20%)**: Fires a rotating double-helix pattern of bullets.
		- **Dash (15%)**: Dashes rapidly towards the player (Orange tint).
		- **Summon (5%)**: Spawns 4 minions in a wide circle (Green tint).
- **Boss 2 (3:00)**: 700 HP, 90 Speed.
- **Elite Boss (4:00)**: 1100 HP, 100 Speed.
- **Void Splitter (5:00)**: 1500 HP, 70 Speed.

Upon defeat, Bosses spawn a **Dimensional Portal** instead of a chest. Entering this portal transports the player to a **Boss Arena** to fight the **Actual Boss**.

---

## ⚙️ Game Mechanics
### 📦 Golden Chests
Accessed by defeating the **Actual Boss** in the **Boss Arena**. Grants a **free level** to one of your currently owned upgrades.

### 📈 Scaling Difficulty
1. **Level-Up**: Every time the player levels up, every enemy (current and future) gains **+0.5 HP**.
2. **Despair**: Every level of Despair adds **+5% HP and Speed** to all enemies instantly.
3. **🕒 Spawn Rate**: The spawn interval decreases linearly over time, reaching maximum difficulty at **10 minutes**.
	- **Initial Rate**: 1 enemy every 2.0s
	- **Final Rate (10m)**: 1 enemy every 0.4s
	- **Ramp Time**: 600 seconds (10 minutes)
	- **Spawn Distance**: ~730px from player (off-screen radius).
4. **Minimum Density**: 
	- **0:00 - 2:00**: Minimum **7 enemies**.
	- **2:00+**: Minimum **10 enemies**.
	Drops/raises dynamically to maintain pacing and challenge.

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
- **Wave 4 (4:00)**: **Elite Boss** (1000 HP, high speed) appears.
- **Wave 5 (5:00)**: **Void Splitter** (1500 HP Boss) appears.
	- **Ability**: Cellular Division. Splits into 4 Fragments at 50% HP.
- **Post-5m**: **Elite Slimes** (Red) begin spawning frequently alongside standard Slimes.


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
- **Force Spawn Enemy**: Spawns a random enemy from the current wave.
- **Force Boss**: Instantly spawns the Enhanced Boss 1 near the player.
- **+1 Level**: Instantly levels up the player once.
- **+10 Levels**: Instantly levels up the player ten times.
