# 🔌 Guide de câblage - Ender 3 Pro + BTT SKR V1.4

Ce guide détaille le câblage complet de tous les composants pour cette configuration.

## 📐 Schéma général

```
┌─────────────────────────────────────────────────────────┐
│              BTT SKR V1.4 TURBO                         │
│                                                         │
│  [X-MOTOR] [Y-MOTOR] [Z-MOTOR] [E0-MOTOR]             │
│  [X-STOP]  [Y-STOP]  [Z-STOP]  [E0-STOP]              │
│  [TFT]     [EXP1/2]  [SERVO]   [PS-ON]                │
│  [POWER-LOSS-PIN]                                      │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Composants et connexions

### 1. Moteurs pas-à-pas (TMC2209)

#### Configuration des drivers TMC2209

**Position des jumpers sous chaque driver :**
```
┌─────────────┐
│  [EN] [STP] │  ← Enlever TOUS les jumpers
│  [DIR] [MS1] │     pour mode UART
│  [MS2] [MS3] │
│  [UART]      │  ← Installer UNIQUEMENT le jumper UART
└─────────────┘
```

#### Connexions moteurs

| Moteur | Port SKR V1.4 | Câblage (Ender 3 Pro) |
|--------|---------------|------------------------|
| **Moteur X** | X-MOTOR | 2B 2A 1A 1B (noir, vert, rouge, bleu) |
| **Moteur Y** | Y-MOTOR | 2B 2A 1A 1B (noir, vert, rouge, bleu) |
| **Moteur Z** | Z-MOTOR | 2B 2A 1A 1B (noir, vert, rouge, bleu) |
| **Extrudeur** | E0-MOTOR | 2B 2A 1A 1B (câblage Sprite Pro) |

⚠️ **Important** : Vérifier l'ordre des fils ! Une inversion peut causer une rotation dans le mauvais sens.

**Test des moteurs :**
```gcode
M302 P1        ; Allow cold extrusion (test uniquement)
G91            ; Mode relatif
G1 X10 F1000   ; Test moteur X
G1 Y10 F1000   ; Test moteur Y
G1 Z10 F300    ; Test moteur Z
G1 E10 F100    ; Test extrudeur
```

### 2. Endstops (capteurs de fin de course)

#### Connexions

| Endstop | Port SKR V1.4 | Type | Notes |
|---------|---------------|------|-------|
| **X-MIN** | X-STOP | Mécanique | Fin de course gauche |
| **Y-MIN** | Y-STOP | Mécanique | Fin de course arrière |
| **Z-MIN** | Utilisé par CR Touch | - | Ne PAS connecter l'endstop Z physique |

#### Brochage endstops

```
Port X-STOP / Y-STOP :
┌─────────────┐
│  S   Signal │ ← Fil de signal (généralement blanc/jaune)
│  -   GND    │ ← Masse (noir)
│  +   VCC    │ ← Alimentation (rouge) - Non utilisé pour endstops mécaniques
└─────────────┘
```

**Test des endstops :**
```gcode
M119           ; Afficher l'état des endstops
               ; x_min: open/triggered
               ; y_min: open/triggered
               ; z_min: open/triggered (CR Touch)
```

### 3. CR Touch (BLTouch clone)

Le CR Touch se connecte sur **deux ports** de la SKR V1.4 :

#### A. Port SERVO (signal de contrôle)

```
Port SERVO (à côté de Z-STOP) :
┌─────────────┐
│  S  Signal  │ ← Fil ORANGE du CR Touch
│  -  GND     │ ← Fil MARRON du CR Touch
│  +  5V      │ ← Fil ROUGE du CR Touch
└─────────────┘
```

#### B. Port Z-STOP (signal de détection)

```
Port Z-STOP :
┌─────────────┐
│  S  Signal  │ ← Fil NOIR du CR Touch
│  -  GND     │ ← Fil BLANC du CR Touch (connecté au GND)
│  +  5V      │ ← Non utilisé
└─────────────┘
```

#### Schéma complet CR Touch

```
CR Touch (5 fils)
│
├─ ROUGE   → SERVO (+5V)
├─ MARRON  → SERVO (GND)
├─ ORANGE  → SERVO (Signal)
├─ NOIR    → Z-STOP (Signal)
└─ BLANC   → Z-STOP (GND)
```

**Test du CR Touch :**
```gcode
M280 P0 S10    ; Deploy probe (sortir la sonde)
M280 P0 S90    ; Stow probe (rentrer la sonde)
M280 P0 S120   ; Self-test
M119           ; Vérifier que z_min change quand on appuie sur la sonde
```

#### Mesure des offsets

Les offsets configurés (-44, -6, -2.5) sont des valeurs de départ. Pour les mesurer précisément :

1. **Offset X/Y** : Mesurer la distance entre la pointe de la buse et le centre de la sonde
2. **Offset Z** : Utiliser la méthode du papier
   ```gcode
   G28              ; Home
   G1 Z0            ; Descendre à Z0
   M211 S0          ; Désactiver les soft endstops
   ; Ajuster Z avec LCD jusqu'à ce que la buse touche le papier
   M114             ; Lire la position Z
   ; Cette valeur est votre offset Z (généralement négatif)
   M851 Z-2.5       ; Définir l'offset (ajuster selon mesure)
   M500             ; Sauvegarder
   ```

### 4. BTT Smart Filament Sensor V1.0

Le capteur de filament se connecte sur le port **E0-STOP**.

```
Port E0-STOP (ou E0-DET) :
┌─────────────┐
│  S  Signal  │ ← Fil de signal (jaune/blanc)
│  -  GND     │ ← Masse (noir)
│  +  VCC     │ ← Alimentation 5V (rouge)
└─────────────┘
```

#### Configuration du capteur

Le BTT SFS V1.0 envoie un signal **LOW** quand le filament est **absent**.

**Firmware configuré :**
```cpp
#define FIL_RUNOUT_STATE LOW
#define FIL_RUNOUT_PULLUP
#define FILAMENT_RUNOUT_DISTANCE_MM 7
```

**Test du capteur :**
```gcode
M412 S1        ; Activer le filament sensor
M412           ; Vérifier l'état
; Retirer le filament - le capteur doit se déclencher
```

### 5. BTT Relay V1.2 (Auto-shutdown)

Le relais se connecte sur le port **PS-ON**.

```
Port PS-ON (près de l'alimentation) :
┌─────────────┐
│  +  Signal  │ ← Fil de contrôle vers le relais
│  -  GND     │ ← Masse commune
└─────────────┘
```

#### Schéma de câblage BTT Relay

```
┌──────────────────────────────────────┐
│        BTT Relay V1.2                │
│                                      │
│  [PS-ON] ← Depuis SKR V1.4 PS-ON    │
│  [GND]   ← GND SKR V1.4              │
│  [5V]    ← 5V SKR V1.4 (optionnel)   │
│                                      │
│  [IN]    ← Alimentation 24V entrée   │
│  [OUT]   ← Alimentation 24V sortie   │
│           (vers SKR V1.4 + PSU)      │
└──────────────────────────────────────┘
```

**Configuration :**
```cpp
#define PSU_ACTIVE_STATE LOW
#define POWER_TIMEOUT 30  // Éteint après 30s d'inactivité
```

**Test du relais :**
```gcode
M80            ; Allumer (si éteint)
M81            ; Éteindre (attention : coupe l'alimentation !)
```

⚠️ **Attention** : M81 coupe l'alimentation ! Assurez-vous que le câblage est correct avant de tester.

### 6. UPS 24V BTT V1.0 (Power Loss Recovery)

L'UPS détecte les coupures de courant et maintient l'alimentation le temps de sauvegarder.

```
Port POWER-LOSS (peut varier selon version SKR) :
┌─────────────┐
│  S  Signal  │ ← Signal de détection de coupure
│  -  GND     │ ← Masse
└─────────────┘
```

#### Schéma UPS

```
┌──────────────────────────────────────┐
│        UPS 24V BTT V1.0              │
│                                      │
│  [24V IN]  ← Alimentation principale │
│  [24V OUT] → Vers SKR V1.4           │
│  [SIGNAL]  → Vers port Power-Loss    │
│  [GND]     → GND SKR V1.4            │
└──────────────────────────────────────┘
```

**Firmware configuré :**
```cpp
#define POWER_LOSS_RECOVERY
#define PLR_ENABLED_DEFAULT true
#define POWER_LOSS_ZRAISE 2  // Monte Z de 2mm en cas de coupure
```

**Test (délicat) :**
```gcode
M413 S1        ; Activer power-loss recovery
M413           ; Vérifier l'état
; Démarrer une impression de test
; Débrancher l'alimentation durant l'impression
; Rebrancher - l'imprimante devrait proposer de reprendre
```

### 7. TFT35 (Écran tactile)

Le TFT35 se connecte via les ports **EXP1** et **EXP2**.

```
Câblage ribbon cables :
┌────────────────────────────────┐
│  SKR V1.4          TFT35       │
│                                │
│  [EXP1] ←──────→ [EXP1]       │
│  [EXP2] ←──────→ [EXP2]       │
│                                │
│  + Connexion série optionnelle  │
│  [TFT-TX] ←────→ [RX]          │
│  [TFT-RX] ←────→ [TX]          │
│  [GND]    ←────→ [GND]         │
└────────────────────────────────┘
```

**Modes du TFT35 :**
1. **Mode Marlin** : Écran graphique (via EXP1/EXP2)
2. **Mode tactile** : Interface TFT (via connexion série)

Basculer entre les modes avec le bouton sur l'écran.

### 8. Thermistances

#### Hotend

```
Port TH0 (E0 Thermistor) :
┌─────────────┐
│  T0  Signal │ ← Thermistance hotend
│  T0  Signal │
└─────────────┘
```

#### Plateau chauffant

```
Port TB (Bed Thermistor) :
┌─────────────┐
│  TB  Signal │ ← Thermistance bed
│  TB  Signal │
└─────────────┘
```

### 9. Chauffages

#### Hotend

```
Port HE0 (Heater 0) :
┌─────────────┐
│  +  24V     │ ← Cartouche chauffante hotend
│  -  GND     │
└─────────────┘
```

#### Plateau chauffant

```
Port BED :
┌─────────────┐
│  +  24V     │ ← Plateau chauffant
│  -  GND     │
└─────────────┘
```

### 10. Ventilateurs

| Ventilateur | Port SKR | Tension | Contrôle |
|-------------|----------|---------|----------|
| **Part cooling** | FAN0 | 24V | PWM (M106/M107) |
| **Hotend fan** | FAN1 | 24V | Automatique >50°C |
| **Board fan** | FAN2 (optionnel) | 24V | Toujours ON |

## 🔌 Alimentation

### Connexions alimentation principale

```
Alimentation 24V DC :
┌──────────────────────────┐
│  +V  ────→ Power IN (+)  │
│  -V  ────→ Power IN (-)  │
└──────────────────────────┘

⚠️ Respecter la polarité !
```

### Distribution

```
PSU 24V
  │
  ├─→ UPS 24V BTT ──→ SKR V1.4 (via BTT Relay)
  ├─→ Plateau chauffant (via MOSFET si >15A)
  └─→ Ventilateurs
```

## ✅ Checklist de vérification

Avant de mettre sous tension :

- [ ] Tous les moteurs sont correctement câblés
- [ ] Jumpers TMC2209 en position UART uniquement
- [ ] CR Touch connecté sur SERVO + Z-STOP
- [ ] Filament sensor sur E0-STOP
- [ ] BTT Relay correctement câblé (⚠️ test M81 prudent)
- [ ] UPS branché entre PSU et SKR
- [ ] TFT35 connecté sur EXP1/EXP2
- [ ] Polarités respectées (alimentation, chauffages)
- [ ] Pas de court-circuit visible
- [ ] Firmware flashé sur SKR V1.4

## 🧪 Tests post-câblage

### 1. Premier démarrage
```gcode
M119           ; Test endstops
M122           ; Test drivers TMC
M303 E0 S200 C8 ; PID hotend
M303 E-1 S60 C8 ; PID bed
M500           ; Sauvegarder
```

### 2. Test mouvements
```gcode
G28            ; Home all axes
G1 X100 Y100 F3000 ; Déplacement centre
M280 P0 S10    ; Test CR Touch deploy
M280 P0 S90    ; Test CR Touch stow
```

### 3. Test chauffages
```gcode
M104 S200      ; Chauffe hotend
M140 S60       ; Chauffe bed
M105           ; Monitor températures
M106 S255      ; Ventilateur 100%
M106 S0        ; Ventilateur OFF
```

## 📸 Photos de référence

Pour des photos détaillées du câblage :
- [BTT SKR V1.4 Pinout officiel](https://github.com/bigtreetech/BIGTREETECH-SKR-V1.3/tree/master/BTT%20SKR%20V1.4)
- [TMC2209 Setup Guide](https://www.youtube.com/results?search_query=tmc2209+uart+setup)

## 🆘 Problèmes courants

| Problème | Solution |
|----------|----------|
| Moteur ne bouge pas | Vérifier jumpers UART, courant driver (M906) |
| Moteur tourne à l'envers | Inverser direction dans firmware ou inverser paire de fils |
| CR Touch ne se déploie pas | Vérifier câblage SERVO, tester M280 P0 S10 |
| Filament sensor ne détecte pas | Vérifier FIL_RUNOUT_STATE (LOW/HIGH) |
| M81 ne coupe pas | Vérifier PSU_ACTIVE_STATE, câblage BTT Relay |

---

**En cas de doute, débrancher l'alimentation avant toute manipulation !**
