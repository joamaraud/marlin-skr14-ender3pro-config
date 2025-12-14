# 🔧 Guide de dépannage - Ender 3 Pro BTT SKR V1.4

Ce guide couvre les problèmes courants et leurs solutions.

## 📑 Table des matières

1. [Problèmes de flash du firmware](#1-problèmes-de-flash-du-firmware)
2. [Problèmes de carte mère (SKR V1.4)](#2-problèmes-de-carte-mère-skr-v14)
3. [Problèmes de drivers TMC2209](#3-problèmes-de-drivers-tmc2209)
4. [Problèmes de CR Touch / BLTouch](#4-problèmes-de-cr-touch--bltouch)
5. [Problèmes d'auto bed leveling](#5-problèmes-dauto-bed-leveling)
6. [Problèmes de filament sensor](#6-problèmes-de-filament-sensor)
7. [Problèmes de power-loss recovery](#7-problèmes-de-power-loss-recovery)
8. [Problèmes d'auto shutdown (BTT Relay)](#8-problèmes-dauto-shutdown-btt-relay)
9. [Problèmes de TFT35](#9-problèmes-de-tft35)
10. [Problèmes de chauffe](#10-problèmes-de-chauffe)
11. [Problèmes de première couche](#11-problèmes-de-première-couche)
12. [Erreurs G-code courantes](#12-erreurs-g-code-courantes)

---

## 1. Problèmes de flash du firmware

### ❌ Le firmware ne flash pas (firmware.bin reste inchangé)

**Symptômes :**
- Le fichier `firmware.bin` reste `firmware.bin` (pas renommé en `.cur`)
- L'écran n'affiche rien ou affiche l'ancienne version

**Causes possibles :**

1. **Carte SD mal formatée**
   - Solution : Reformater en FAT32 (taille allocation 4096 bytes)
   - Outil Windows : Clic droit → Formater → FAT32
   - Outil Linux : `sudo mkfs.vfat -F 32 /dev/sdX1`

2. **Carte SD dans le mauvais slot**
   - La SKR V1.4 a 2 slots SD : un sur la carte, un sur le TFT
   - **Solution** : Utiliser le slot SD de la **carte mère SKR V1.4** (pas celui du TFT)

3. **Firmware.bin mal nommé**
   - Nom exact : `firmware.bin` (minuscules, pas d'espace)
   - **Éviter** : `Firmware.bin`, `firmware .bin`, `firmware.BIN`

4. **Bootloader absent**
   - SKR V1.4 Turbo a normalement le bootloader installé d'usine
   - Solution : Flasher le bootloader via ST-Link (avancé)

### ❌ L'écran reste noir après flash

**Solutions :**
1. Vérifier que le firmware.bin a bien été flashé (renommé en .cur)
2. Débrancher/rebrancher l'alimentation (pas juste reset)
3. Vérifier connexions EXP1/EXP2 du TFT
4. Tester le TFT en mode standalone (débrancher EXP1/EXP2)

---

## 2. Problèmes de carte mère (SKR V1.4)

### ❌ La carte ne démarre pas (LED rouge off)

**Vérifications :**
1. Alimentation 24V correctement branchée (+ et -)
2. Fusible de la carte intact
3. Pas de court-circuit visible

### ❌ LED rouge allumée mais pas de communication USB

**Solutions :**
1. Driver USB : [Installer driver CH340](https://github.com/bigtreetech/BIGTREETECH-SKR-V1.3/tree/master/Driver)
2. Câble USB : Utiliser un câble USB **avec données** (pas juste charge)
3. Port série : Vérifier `SERIAL_PORT 0` dans Configuration.h

### ❌ Écran LCD affiche des caractères bizarres

**Solutions :**
1. Vérifier `LCD_LANGUAGE en` dans Configuration.h
2. Vérifier définition écran : `REPRAP_DISCOUNT_FULL_GRAPHIC_SMART_CONTROLLER`
3. Reflasher le firmware

---

## 3. Problèmes de drivers TMC2209

### ❌ Moteur ne bouge pas

**Diagnostic :**
```gcode
M122    ; TMC Debug
; Chercher : Communication: FAIL
```

**Solutions :**

1. **Vérifier jumpers UART**
   - Seul le jumper **UART** doit être installé (sous le driver)
   - Retirer TOUS les autres jumpers (MS1, MS2, MS3)

2. **Driver mal inséré**
   - Vérifier orientation : Repère GND aligné avec marquage carte
   - Réinsérer fermement le driver

3. **Courant trop faible**
   ```gcode
   M906 X800 Y800 Z800 E800    ; Définir courant 800mA
   M500                         ; Sauvegarder
   ```

### ❌ Moteur fait du bruit / vibre

**Causes :**

1. **Pas en mode UART**
   - Symptôme : Moteur très bruyant, pas silencieux
   - Solution : Vérifier jumpers (seulement UART)

2. **StealthChop désactivé**
   ```gcode
   M122    ; Vérifier StealthChop: true
   ```

3. **Microsteps incorrects**
   - Valeur attendue : 16 microsteps
   - Dans Configuration_adv.h : `#define X_MICROSTEPS 16`

### ❌ TMC driver overtemp warning

**Solutions :**
1. Ajouter des dissipateurs thermiques sur les drivers
2. Améliorer ventilation de la carte
3. Réduire le courant :
   ```gcode
   M906 X700 Y700 Z700 E700
   M500
   ```

### ❌ Moteur tourne à l'envers

**Solutions :**
1. **Via G-code (préféré) :**
   ```gcode
   M569 X0 I1    ; Inverser direction moteur X
   M500
   ```

2. **Via câblage :**
   - Inverser **une paire** de fils du moteur (exemple : 2B ↔ 2A)

---

## 4. Problèmes de CR Touch / BLTouch

### ❌ CR Touch ne se déploie pas

**Diagnostic :**
```gcode
M280 P0 S10    ; Deploy
; La sonde doit sortir
```

**Solutions :**

1. **Vérifier câblage SERVO**
   ```
   CR Touch ROUGE  → SERVO (+5V)
   CR Touch MARRON → SERVO (GND)
   CR Touch ORANGE → SERVO (Signal)
   ```

2. **Vérifier #define BLTOUCH dans Configuration.h**

3. **Tester self-test**
   ```gcode
   M280 P0 S120   ; Self-test
   ; LED rouge doit clignoter rapidement = OK
   ```

### ❌ CR Touch ne détecte pas (Z_MIN toujours open)

**Vérifications :**

1. **Câblage Z-STOP**
   ```
   CR Touch NOIR  → Z-STOP (Signal)
   CR Touch BLANC → Z-STOP (GND)
   ```

2. **Test manuel**
   ```gcode
   M280 P0 S10    ; Deploy
   M119           ; Status endstops
   ; Appuyer sur la sonde manuellement
   M119           ; z_min doit passer à "TRIGGERED"
   ```

3. **Vérifier Configuration.h**
   ```cpp
   #define Z_MIN_ENDSTOP_HIT_STATE HIGH  // ou LOW selon version
   ```

### ❌ CR Touch erreur "Probing failed"

**Solutions :**

1. **Z offset trop haut**
   ```gcode
   M851 Z-3.0     ; Augmenter offset Z (plus négatif)
   M500
   ```

2. **PROBING_MARGIN trop grand**
   - Dans Configuration.h : `#define PROBING_MARGIN 10`
   - Plateau 235mm - 2×10mm = 215mm disponibles (OK)

3. **Bed trop proche**
   - Vérifier que le plateau peut descendre suffisamment en Z

### ❌ CR Touch erreur "Failed to enable Bed Leveling"

**Solution :**
```gcode
M420 S1    ; Activer bed leveling
M500       ; Sauvegarder
```

---

## 5. Problèmes d'auto bed leveling

### ❌ G29 échoue après quelques points

**Causes :**

1. **Timeout probe**
   - Solution : Nettoyer la sonde CR Touch
   - Vérifier pas d'obstacle sur le plateau

2. **Bed leveling trop désactivé**
   ```gcode
   M420 S0    ; Désactivé
   G29        ; Refaire le leveling
   M420 S1    ; Activer
   M500       ; Sauvegarder
   ```

### ❌ G29 fonctionne mais pas appliqué pendant l'impression

**Vérifications :**

1. **Bed leveling désactivé**
   ```gcode
   M420 V1    ; Afficher status
   ; Bed Leveling ON/OFF
   ```

2. **G-code de start manquant**
   - Ajouter dans start G-code :
   ```gcode
   G28        ; Home
   G29        ; Bed leveling
   M420 S1    ; Activer compensation
   ```

3. **Fade height trop basse**
   - Par défaut : 10mm (OK)
   - Vérifier avec M503 : `M420 Z10.00`

### ❌ Mesh bed leveling semble incorrect

**Solutions :**

1. **Refaire G29 à température de travail**
   ```gcode
   M104 S200
   M140 S60
   M109 S200
   M190 S60
   G28
   G29
   M500
   ```

2. **Vérifier la mesh**
   ```gcode
   M420 V1    ; Visualiser
   ; Valeurs anormales > 1mm = problème mécanique
   ```

3. **Problème mécanique**
   - Vérifier vis du plateau (bien serrées, pas tordues)
   - Vérifier pas de bosse sur le plateau

---

## 6. Problèmes de filament sensor

### ❌ Sensor ne détecte pas la rupture

**Diagnostic :**
```gcode
M412       ; Status
; Filament runout: ON
```

**Vérifications :**

1. **Câblage E0-STOP**
   ```
   BTT SFS Signal (jaune) → E0-STOP (S)
   BTT SFS GND (noir)     → E0-STOP (-)
   BTT SFS VCC (rouge)    → E0-STOP (+)
   ```

2. **État du capteur inversé**
   - Configuration actuelle : `FIL_RUNOUT_STATE LOW`
   - Si ne fonctionne pas, tester `HIGH` dans Configuration.h

3. **Distance de détection**
   ```cpp
   #define FILAMENT_RUNOUT_DISTANCE_MM 7
   ```
   - Augmenter si détection trop sensible
   - Réduire si détection trop tardive

### ❌ Faux positifs (pause sans raison)

**Solutions :**

1. **Augmenter FILAMENT_RUNOUT_DISTANCE_MM**
   ```cpp
   #define FILAMENT_RUNOUT_DISTANCE_MM 15
   ```

2. **Capteur mal positionné**
   - Vérifier que le filament passe bien dans le capteur
   - Nettoyer le capteur (poussière)

---

## 7. Problèmes de power-loss recovery

### ❌ Pas de proposition de reprise après coupure

**Vérifications :**

1. **PLR désactivé**
   ```gcode
   M413 S1    ; Activer
   M413       ; Vérifier : Power-loss recovery: ON
   ```

2. **Pas d'UPS / signal de détection**
   - Vérifier câblage UPS → port POWER-LOSS
   - Tester avec UPS débranché = pas de détection

3. **Fichier de reprise absent**
   - Sur la carte SD : chercher `/SD_RECOVER.BIN`
   - Si absent : coupure trop rapide (UPS insuffisant)

### ❌ Reprise échoue (décalage, problème d'adhésion)

**Causes :**

1. **Z pas assez élevé**
   ```cpp
   #define POWER_LOSS_ZRAISE 5    // Augmenter à 5mm
   ```

2. **Plateau refroidi**
   - Activer `PLR_HEAT_BED_ON_REBOOT` dans Configuration_adv.h

---

## 8. Problèmes d'auto shutdown (BTT Relay)

### ❌ M81 ne coupe pas l'alimentation

**Vérifications :**

1. **PSU_CONTROL désactivé**
   - Vérifier Configuration.h : `#define PSU_CONTROL`

2. **État actif inversé**
   ```cpp
   #define PSU_ACTIVE_STATE LOW    // Tester HIGH si ne marche pas
   ```

3. **Câblage BTT Relay**
   - Vérifier connexion PS-ON ↔ BTT Relay
   - Vérifier polarité (LOW/HIGH)

### ❌ Coupe trop tôt / trop tard

**Ajuster le timeout :**
```cpp
#define POWER_TIMEOUT 30    // Secondes (ajuster)
```

---

## 9. Problèmes de TFT35

### ❌ Écran tactile ne répond pas

**Solutions :**

1. **Basculer en mode Marlin**
   - Bouton sur l'écran pour changer de mode
   - Mode Marlin (graphique) ou mode TFT (tactile)

2. **Firmware TFT à jour**
   - Mettre à jour le firmware du TFT séparément
   - [TFT Firmware](https://github.com/bigtreetech/BIGTREETECH-TouchScreenFirmware)

### ❌ Écran affiche "No printer attached"

**Solutions :**
1. Vérifier câble série TFT-TX ↔ RX, TFT-RX ↔ TX
2. Vérifier `SERIAL_PORT_2 -1` dans Configuration.h
3. Redémarrer l'imprimante

---

## 10. Problèmes de chauffe

### ❌ Hotend ne chauffe pas / erreur "HEATING FAILED"

**Vérifications :**

1. **Thermistance débranchée**
   - Vérifier connexion TH0 (thermistance)
   - M503 : température ambiante ~20-25°C

2. **Cartouche chauffante**
   - Vérifier connexion HE0
   - Tester résistance : ~12-16Ω pour 24V/40W

3. **PID mal calibré**
   ```gcode
   M303 E0 S200 C8    ; Recalibrer PID
   ```

### ❌ Thermal runaway error

**Causes :**

1. **Thermistance défectueuse**
   - Remplacer thermistance

2. **Cartouche chauffante sous-dimensionnée**
   - Vérifier puissance (40W minimum recommandé)

3. **PID instable**
   - Recalibrer PID avec ventilateur éteint

---

## 11. Problèmes de première couche

### ❌ Première couche ne colle pas

**Solutions :**

1. **Z offset trop haut**
   ```gcode
   M851 Z-2.70    ; Diminuer (plus négatif)
   M500
   ```

2. **Bed leveling pas appliqué**
   ```gcode
   M420 S1
   M500
   ```

3. **Plateau pas propre**
   - Nettoyer avec alcool isopropylique

### ❌ Buse gratte le plateau

**Solutions :**

1. **Z offset trop bas**
   ```gcode
   M851 Z-2.20    ; Augmenter (moins négatif)
   M500
   ```

2. **Bed leveling incorrect**
   - Refaire G29

---

## 12. Erreurs G-code courantes

### ❌ "Unknown command M300"

**Solution :** Activer buzzer dans Configuration.h
```cpp
#define SPEAKER
```

### ❌ "Error: EEPROM version mismatch"

**Solution :**
```gcode
M502    ; Reset factory settings
M500    ; Save
```

### ❌ "Cold extrusion prevented"

**Solution :**
```gcode
M302 P1    ; Allow cold extrusion (temporaire)
; Ou chauffer : M104 S200
```

---

## 🆘 Dernier recours

### Reset complet

1. Reflasher le firmware
2. `M502` (factory reset)
3. `M500` (save)
4. Refaire toutes les calibrations (voir CALIBRATION.md)

### Retour à une version antérieure

Si un firmware ne fonctionne pas :
1. Récupérer ancien `firmware.bin` (backup)
2. Reflasher l'ancien firmware
3. `M502` + `M500`

---

## 📞 Besoin d'aide ?

**Avant de demander de l'aide, préparer :**
- Sortie de `M503` (configuration complète)
- Sortie de `M122` (status drivers TMC)
- Sortie de `M119` (status endstops)
- Photos du câblage si problème matériel

**Communautés :**
- [Reddit r/ender3](https://reddit.com/r/ender3)
- [Marlin Discord](https://discord.gg/n5NJ59y)
- [Facebook Ender 3 France](https://facebook.com/groups/ender3france)

---

**Ce guide est mis à jour régulièrement. N'hésitez pas à contribuer !**
