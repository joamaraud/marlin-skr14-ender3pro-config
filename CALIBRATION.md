# 🎯 Guide de calibration - Ender 3 Pro BTT SKR V1.4

Guide pas-à-pas pour calibrer votre imprimante après l'installation du firmware Marlin.

## 📋 Ordre des calibrations

La calibration doit être effectuée **dans cet ordre** :

1. ✅ Premier démarrage et vérifications de base
2. 🌡️ Calibration PID (hotend et bed)
3. 📏 Calibration E-steps (extrudeur)
4. 🎚️ Calibration CR Touch (probe offsets)
5. 🗺️ Premier bed leveling (auto bed leveling)
6. 🧪 Tests fonctionnels de tous les modules
7. 💾 Sauvegarde finale EEPROM

**Temps estimé : 1-2 heures**

---

## 1. 📦 Premier démarrage

### Étape 1.1 : Vérification du flash

1. Mettre la carte SD dans la SKR V1.4
2. Allumer l'imprimante
3. Vérifier que `firmware.bin` a été renommé en `firmware.cur`
4. L'écran TFT doit s'allumer et afficher l'interface Marlin

### Étape 1.2 : Reset factory + Save

```gcode
M502           ; Load factory settings
M500           ; Save to EEPROM
M501           ; Load from EEPROM (vérification)
```

### Étape 1.3 : Vérifier les endstops

```gcode
M119           ; Afficher l'état des endstops
```

**Résultat attendu :**
```
x_min: open     (devient "TRIGGERED" quand pressé)
y_min: open     (devient "TRIGGERED" quand pressé)
z_min: open     (CR Touch - devient "TRIGGERED" quand sonde touche)
```

**Si un endstop est inversé :**
- Vérifier le câblage
- Ou inverser dans le firmware (endstop_inverting)

### Étape 1.4 : Vérifier les drivers TMC2209

```gcode
M122           ; TMC Debug Info
```

**Rechercher pour chaque driver (X, Y, Z, E0) :**
- `Driver enabled: true`
- `Communication: OK`
- `StealthChop: true`

**Si erreur de communication :**
- Vérifier jumpers UART (uniquement jumper UART installé)
- Vérifier que les drivers sont bien insérés

---

## 2. 🌡️ Calibration PID

Le PID permet un contrôle précis de la température du hotend et du plateau.

### Étape 2.1 : PID Hotend (200°C - PLA)

```gcode
M303 E0 S200 C8    ; Autotune hotend à 200°C, 8 cycles
; Attendre 5-10 minutes
```

**Résultat attendu :**
```
Classic PID
Kp: 21.73
Ki: 1.54
Kd: 76.55
```

**Appliquer les valeurs :**
```gcode
M301 P21.73 I1.54 D76.55    ; Utiliser VOS valeurs !
M500                         ; Sauvegarder
```

### Étape 2.2 : PID Plateau chauffant (60°C - PLA)

```gcode
M303 E-1 S60 C8    ; Autotune bed à 60°C, 8 cycles
; Attendre 10-15 minutes
```

**Résultat attendu :**
```
Classic PID
Kp: 74.25
Ki: 14.14
Kd: 388.21
```

**Appliquer les valeurs :**
```gcode
M304 P74.25 I14.14 D388.21    ; Utiliser VOS valeurs !
M500                           ; Sauvegarder
```

### Étape 2.3 : Tester la stabilité

```gcode
M104 S200          ; Chauffe hotend
M140 S60           ; Chauffe bed
M105               ; Monitor températures (répéter)
```

**Température stable = ±1-2°C max**

---

## 3. 📏 Calibration E-steps (Extrudeur)

Les E-steps définissent combien de pas sont nécessaires pour extruder 1mm de filament.

### Étape 3.1 : Valeur actuelle

```gcode
M503           ; Afficher config
; Chercher : M92 X80.00 Y80.00 Z400.00 E93.00
; E93.00 = valeur actuelle E-steps
```

### Étape 3.2 : Préparation

1. Chauffer le hotend à 200°C (PLA) : `M104 S200`
2. Attendre : `M109 S200`
3. Marquer le filament à **120mm** au-dessus de l'entrée de l'extrudeur
4. Activer l'extrusion à froid : `M302 P1` (si nécessaire)

### Étape 3.3 : Extrusion de test

```gcode
G91                ; Mode relatif
G1 E100 F100       ; Extruder 100mm à vitesse lente
G90                ; Mode absolu
```

### Étape 3.4 : Mesure

1. Mesurer la distance restante entre la marque et l'entrée de l'extrudeur
2. Calculer : `Filament extrudé réel = 120 - distance_restante`

**Exemple :**
- Distance restante : 22mm
- Filament extrudé réel : 120 - 22 = **98mm**

### Étape 3.5 : Calcul des nouveaux E-steps

```
Nouveaux E-steps = (E-steps actuels * 100) / Filament extrudé réel
Nouveaux E-steps = (93 * 100) / 98 = 94.90
```

### Étape 3.6 : Appliquer les nouveaux E-steps

```gcode
M92 E94.90         ; Définir nouveaux E-steps
M500               ; Sauvegarder
```

### Étape 3.7 : Vérification

Répéter l'étape 3.2 à 3.4 pour vérifier que 100mm sont bien extrudés.

---

## 4. 🎚️ Calibration CR Touch (Probe Offsets)

Les offsets définissent la position de la sonde par rapport à la buse.

### Étape 4.1 : Test du CR Touch

```gcode
M280 P0 S10        ; Deploy probe
; La sonde doit sortir
M280 P0 S90        ; Stow probe
; La sonde doit rentrer
M280 P0 S120       ; Self-test
; LED rouge clignotante = OK
```

### Étape 4.2 : Offsets X et Y (mesure physique)

**Méthode :**
1. Placer une règle sur le plateau
2. Mesurer la distance en X entre la pointe de la **buse** et le centre de la **sonde**
3. Mesurer la distance en Y entre la pointe de la **buse** et le centre de la **sonde**

**Exemple Sprite Pro avec CR Touch :**
- Offset X : -44mm (sonde à gauche de la buse)
- Offset Y : -6mm (sonde devant la buse)

```gcode
M851 X-44 Y-6      ; Définir offsets X/Y
M500               ; Sauvegarder
```

### Étape 4.3 : Offset Z (méthode du papier)

**Préparation :**
```gcode
M104 S200          ; Chauffe hotend (expansion thermique)
M190 S60           ; Chauffe bed
M109 S200          ; Attend températures
G28                ; Home tous axes
M211 S0            ; Désactiver soft endstops
```

**Calibration :**
1. Placer une feuille de papier entre la buse et le plateau
2. Via l'écran LCD : Menu → Motion → Move Axis → Move Z → 0.1mm
3. Descendre Z jusqu'à sentir une **légère résistance** sur le papier
4. Lire la position Z :
   ```gcode
   M114             ; Afficher position
   ; Z: -2.45       <- Cette valeur est votre offset Z
   ```

5. Définir l'offset :
   ```gcode
   M851 Z-2.45      ; Utiliser VOTRE valeur !
   M500             ; Sauvegarder
   M211 S1          ; Réactiver soft endstops
   ```

### Étape 4.4 : Vérification offset Z

```gcode
G28                ; Home
G1 Z0 F300         ; Descendre à Z0
; Tester avec papier - doit avoir légère résistance
```

**Si trop haut/bas :**
```gcode
M851 Z-2.30        ; Ajuster (plus négatif = plus bas)
M500
```

---

## 5. 🗺️ Premier Bed Leveling

L'auto bed leveling mesure la géométrie du plateau pour compenser les imperfections.

### Étape 5.1 : Préparation

```gcode
M104 S200          ; Chauffe hotend
M140 S60           ; Chauffe bed
M109 S200          ; Attend hotend
M190 S60           ; Attend bed
```

### Étape 5.2 : Lancer le bed leveling

```gcode
G28                ; Home tous axes
G29                ; Auto bed leveling (5x5 = 25 points)
; Attendre 5-10 minutes
```

**Pendant le G29 :**
- La sonde se déploie automatiquement
- 25 points sont mesurés (grille 5x5)
- Les valeurs sont enregistrées en mémoire

### Étape 5.3 : Visualiser la mesh

```gcode
M420 V1            ; Afficher la mesh bed leveling
```

**Exemple de résultat :**
```
Bed Level Correction Matrix:
+0.12 +0.08 +0.03 -0.02 -0.05
+0.10 +0.06 +0.01 -0.03 -0.06
+0.08 +0.04 +0.00 -0.04 -0.07
```

**Analyse :**
- Valeurs positives : plateau plus haut
- Valeurs négatives : plateau plus bas
- Variation < 0.3mm = bon
- Variation > 0.5mm = plateau déformé ou mal vissé

### Étape 5.4 : Sauvegarder la mesh

```gcode
M500               ; Sauvegarder en EEPROM
M420 S1            ; Activer le bed leveling
M500               ; Sauvegarder l'état activé
```

### Étape 5.5 : Test d'impression

Imprimer un carré de test (20x20mm, première couche uniquement) pour vérifier l'adhésion uniforme.

---

## 6. 🧪 Tests fonctionnels des modules

### Test 6.1 : Filament Sensor (BTT SFS V1.0)

```gcode
M412 S1            ; Activer filament sensor
M412               ; Vérifier état : Filament runout ON
```

**Test :**
1. Charger du filament
2. Lancer une impression de test
3. Retirer le filament pendant l'impression
4. L'imprimante doit se mettre en pause et exécuter M600

### Test 6.2 : Advanced Pause (M600)

```gcode
M104 S200          ; Chauffe hotend
M109 S200
M600               ; Changement de filament
; Suivre les instructions à l'écran :
; 1. Retrait du filament
; 2. Insertion nouveau filament
; 3. Purge
; 4. Resume
```

### Test 6.3 : Power Loss Recovery

⚠️ **Test à risque - faire sur impression non critique**

```gcode
M413 S1            ; Activer power-loss recovery
M413               ; Vérifier : Power-loss recovery ON
```

**Test :**
1. Lancer une impression de test (>10 minutes)
2. Débrancher l'alimentation (UPS maintient quelques secondes)
3. Rebrancher
4. Au démarrage, l'écran doit proposer "Continue print?"

### Test 6.4 : Auto Power Off (BTT Relay)

⚠️ **Vérifier le câblage avant !**

```gcode
M81                ; Extinction automatique
; L'imprimante doit s'éteindre complètement
```

**En fin d'impression :**
Le firmware éteindra automatiquement l'imprimante après 30 secondes d'inactivité (POWER_TIMEOUT).

---

## 7. 💾 Sauvegarde finale et vérification

### Étape 7.1 : Afficher toute la configuration

```gcode
M503               ; Dump complet de la config
```

**Vérifier :**
- E-steps : `M92 ... E94.90` (votre valeur calibrée)
- PID hotend : `M301 P... I... D...` (vos valeurs)
- PID bed : `M304 P... I... D...` (vos valeurs)
- Probe offsets : `M851 X-44.00 Y-6.00 Z-2.45` (vos valeurs)
- Bed leveling : `M420 S1` (activé)

### Étape 7.2 : Sauvegarde finale

```gcode
M500               ; Save all to EEPROM
```

### Étape 7.3 : Backup EEPROM (optionnel mais recommandé)

Copier la sortie de `M503` dans un fichier texte (`eeprom_backup.txt`) sur votre PC.

En cas de problème, vous pourrez recharger ces valeurs manuellement.

---

## 📊 Tableau récapitulatif des calibrations

| Paramètre | Commande | Valeur par défaut | Valeur calibrée | Status |
|-----------|----------|-------------------|-----------------|--------|
| **E-steps** | M92 E | 93.00 | 94.90 (exemple) | ☐ |
| **PID Hotend Kp** | M301 P | - | 21.73 (exemple) | ☐ |
| **PID Hotend Ki** | M301 I | - | 1.54 (exemple) | ☐ |
| **PID Hotend Kd** | M301 D | - | 76.55 (exemple) | ☐ |
| **PID Bed Kp** | M304 P | - | 74.25 (exemple) | ☐ |
| **PID Bed Ki** | M304 I | - | 14.14 (exemple) | ☐ |
| **PID Bed Kd** | M304 D | - | 388.21 (exemple) | ☐ |
| **Probe Offset X** | M851 X | -44.00 | -44.00 (à mesurer) | ☐ |
| **Probe Offset Y** | M851 Y | -6.00 | -6.00 (à mesurer) | ☐ |
| **Probe Offset Z** | M851 Z | -2.50 | -2.45 (exemple) | ☐ |
| **Bed Leveling** | G29 + M500 | - | Mesh sauvegardée | ☐ |
| **Filament Sensor** | M412 S1 | OFF | ON | ☐ |
| **Power-Loss** | M413 S1 | ON | ON | ☐ |

---

## 🎓 Calibrations avancées (optionnel)

### Calibration de la flow rate

Après les E-steps, affiner avec la flow rate (multiplicateur global).

**Test cube 20x20x20mm :**
1. Imprimer un cube de calibration
2. Mesurer l'épaisseur des parois (cible : 0.4mm avec buse 0.4mm)
3. Ajuster flow dans le slicer :
   ```
   Nouveau flow = (épaisseur cible / épaisseur mesurée) * 100
   Nouveau flow = (0.4 / 0.38) * 100 = 105%
   ```

### Calibration Linear Advance

Pour améliorer les coins et réduire les artefacts.

```gcode
M900 K0.0          ; Désactiver
M900 K0.05         ; Tester valeur K (ajuster selon résultat)
M500               ; Sauvegarder si bon
```

### Calibration Pressure Advance (avec Klipper uniquement)

Marlin utilise Linear Advance (ci-dessus).

---

## 🆘 Problèmes fréquents lors de la calibration

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| **PID ne converge pas** | Ventilateur de refroidissement actif | M106 S0 avant M303 |
| **E-steps : filament glisse** | Tension extrudeur | Ajuster tension levier extrudeur |
| **Probe offset Z trop haut** | Expansion thermique | Toujours calibrer hotend/bed chauds |
| **G29 échoue (probe error)** | Câblage CR Touch | Vérifier connexions SERVO + Z-STOP |
| **Première couche pas adhérente** | Z offset mal calibré | Ajuster M851 Z par incrément de 0.05mm |
| **Bed leveling pas appliqué** | M420 S0 | M420 S1 puis M500 |

---

## ✅ Checklist finale

Avant la première "vraie" impression :

- [ ] Firmware flashé et vérifié (firmware.cur)
- [ ] M502 + M500 (reset factory)
- [ ] Endstops testés (M119)
- [ ] TMC2209 communicating (M122)
- [ ] PID hotend calibré et sauvegardé
- [ ] PID bed calibré et sauvegardé
- [ ] E-steps calibrés et vérifiés
- [ ] CR Touch offsets X/Y/Z calibrés
- [ ] Bed leveling G29 effectué et sauvegardé
- [ ] Filament sensor testé (M412 S1)
- [ ] Power-loss recovery testé (optionnel)
- [ ] M503 sauvegardé en backup
- [ ] M500 sauvegarde finale
- [ ] Impression de test réussie (cube 20x20mm)

**🎉 Votre imprimante est maintenant calibrée et prête à imprimer !**

---

## 📚 Ressources complémentaires

- [Marlin G-code Reference](https://marlinfw.org/meta/gcode/)
- [Teaching Tech Calibration](https://teachingtechyt.github.io/calibration.html)
- [E-steps Calculator](https://www.prusa3d.com/calculator/)
- [PID Tuning Guide](https://reprap.org/wiki/PID_Tuning)

