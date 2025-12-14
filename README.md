# Configuration Marlin 2.1.x pour Ender 3 Pro
**Build personnalisé avec BTT SKR V1.4 Turbo + CR Touch + modules BTT**

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Marlin](https://img.shields.io/badge/Marlin-2.1.x-red.svg)
![Platform](https://img.shields.io/badge/platform-LPC1769-green.svg)

## 📋 Vue d'ensemble

Configuration complète et optimisée de Marlin 2.1.x (bugfix-2.1.x) pour une **Ender 3 Pro** équipée de composants BigTreeTech professionnels.

## 🔧 Spécifications matérielles

### Composants principaux

| Composant | Modèle | Description |
|-----------|--------|-------------|
| **Carte mère** | BTT SKR V1.4 Turbo | 32-bit ARM Cortex-M3 LPC1769 @ 120MHz |
| **Drivers** | TMC2209 (x4) | Drivers silencieux UART avec StealthChop |
| **Écran** | TFT35 | Écran tactile BigTreeTech 3.5" |
| **Extrudeur** | Creality Sprite Pro | Extrudeur direct drive |
| **Probe** | CR Touch | Clone BLTouch pour auto bed leveling |
| **Filament sensor** | BTT Smart Filament Sensor V1.0 | Détection de rupture de filament |
| **Auto-shutdown** | BTT Relay V1.2 | Extinction automatique après impression |
| **Power loss recovery** | UPS 24V BTT V1.0 | Reprise après coupure de courant |

### Dimensions

- **Volume d'impression** : 235 x 235 x 220 mm
- **Plateau** : Mobile en Y (style Ender 3 Pro)
- **Alimentation** : 24V

## ✨ Fonctionnalités activées

✅ **Auto Bed Leveling** - Grille bilinéaire 5x5 avec CR Touch  
✅ **TMC2209 UART** - Mode silencieux avec monitoring des drivers  
✅ **Hybrid Threshold** - Passage automatique en spreadCycle à haute vitesse  
✅ **Filament Runout Sensor** - Détection de rupture de filament avec M600  
✅ **Power Loss Recovery** - Reprise d'impression après coupure  
✅ **Auto Power Off** - Extinction automatique via BTT Relay  
✅ **Advanced Pause** - Changement de filament M600  
✅ **Arc Support** - Support des commandes G2/G3  
✅ **PID Tuning** - PID pour hotend et plateau chauffant  
✅ **SD Card Support** - Impression depuis carte SD  
✅ **Z Safe Homing** - Homing Z au centre du plateau  

## 🚀 Installation rapide

### Prérequis

- [Visual Studio Code](https://code.visualstudio.com/)
- [PlatformIO IDE](https://platformio.org/platformio-ide) (extension VSCode)
- Carte SD formatée en FAT32

### Étapes de compilation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/joamaraud/marlin-skr14-ender3pro-config.git
   cd marlin-skr14-ender3pro-config
   ```

2. **Ouvrir dans VSCode**
   ```bash
   code .
   ```

3. **Compiler le firmware**
   - Ouvrir PlatformIO (icône dans la barre latérale)
   - Environnement : `LPC1769` (déjà configuré par défaut)
   - Cliquer sur `Build` (ou appuyer sur `Ctrl+Alt+B`)

4. **Flasher le firmware**
   - Le fichier compilé se trouve dans `.pio/build/LPC1769/firmware.bin`
   - Copier `firmware.bin` à la racine de la carte SD
   - Éteindre l'imprimante
   - Insérer la carte SD dans le slot de la SKR V1.4
   - Allumer l'imprimante
   - Le fichier sera renommé en `firmware.cur` une fois flashé (succès)

## 📚 Documentation

- **[WIRING.md](WIRING.md)** - Schémas de câblage détaillés pour tous les modules
- **[CALIBRATION.md](CALIBRATION.md)** - Guide de calibration étape par étape
- **[docs/troubleshooting.md](docs/troubleshooting.md)** - Résolution de problèmes courants

## 🎯 G-code exemples

Des G-codes optimisés pour cette configuration sont disponibles dans le dossier `/gcode` :

- **start-gcode.gcode** - G-code de démarrage avec auto bed leveling
- **end-gcode.gcode** - G-code de fin avec extinction automatique

### Utilisation dans le slicer

**PrusaSlicer / SuperSlicer**
- Paramètres de l'imprimante → G-code personnalisé
- Copier le contenu de `start-gcode.gcode` dans "G-code de début"
- Copier le contenu de `end-gcode.gcode` dans "G-code de fin"

**Cura**
- Paramètres → Imprimante → Gérer les imprimantes
- G-code de début / G-code de fin

## ⚙️ Configuration résumée

### Paramètres moteurs (Configuration.h)

```cpp
#define DEFAULT_AXIS_STEPS_PER_UNIT   { 80, 80, 400, 93 }
#define DEFAULT_MAX_FEEDRATE          { 500, 500, 5, 25 }
#define DEFAULT_MAX_ACCELERATION      { 500, 500, 100, 1000 }
#define DEFAULT_ACCELERATION          500
```

### TMC2209 (Configuration_adv.h)

```cpp
// Courants moteurs
X_CURRENT: 800mA
Y_CURRENT: 800mA
Z_CURRENT: 800mA
E0_CURRENT: 800mA

// Hybrid Threshold
X_HYBRID_THRESHOLD: 100 mm/s
Y_HYBRID_THRESHOLD: 100 mm/s
Z_HYBRID_THRESHOLD: 3 mm/s
E0_HYBRID_THRESHOLD: 30 mm/s
```

### CR Touch

```cpp
#define NOZZLE_TO_PROBE_OFFSET { -44, -6, -2.5 }
```

⚠️ **Important** : Ces offsets doivent être mesurés précisément sur votre machine

## 🔍 Commandes de diagnostic

### Test des modules

```gcode
M503              ; Afficher la configuration EEPROM
M122              ; Status des drivers TMC
M412 S1           ; Activer le filament sensor
M81               ; Test extinction auto (BTT Relay)
G29               ; Lancer un auto bed leveling
M420 S1           ; Activer la compensation du bed
```

### Calibrations essentielles

```gcode
M303 E0 S200 C8   ; PID autotune hotend (200°C, 8 cycles)
M303 E-1 S60 C8   ; PID autotune bed (60°C, 8 cycles)
M500              ; Sauvegarder en EEPROM
```

## ⚠️ Notes importantes

1. **E-steps** : La valeur par défaut (93) doit être calibrée pour le Sprite Pro
2. **Probe offsets** : Les offsets X/Y/Z du CR Touch doivent être mesurés précisément
3. **BTT Relay** : Vérifier la polarité (LOW/HIGH) selon votre câblage
4. **Firmware.bin** : Toujours vérifier que le fichier est renommé en `firmware.cur` après flash
5. **Premier boot** : Effectuer un `M502` (reset factory) puis `M500` (save) après le premier flash

## 📦 Structure du dépôt

```
marlin-skr14-ender3pro-config/
├── README.md                    # Ce fichier
├── WIRING.md                    # Schémas de câblage
├── CALIBRATION.md               # Guide de calibration
├── Marlin/
│   ├── Configuration.h          # Configuration principale
│   ├── Configuration_adv.h      # Configuration avancée
│   └── [autres fichiers Marlin]
├── platformio.ini               # Configuration PlatformIO (LPC1769)
├── gcode/
│   ├── start-gcode.gcode       # G-code de démarrage
│   └── end-gcode.gcode         # G-code de fin
└── docs/
    └── troubleshooting.md      # Dépannage

```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Ouvrir une issue pour signaler un problème
- Proposer des améliorations via Pull Request
- Partager vos résultats et configurations

## 📄 Licence

Ce projet utilise le firmware Marlin, distribué sous licence GPLv3.

- Marlin Firmware: [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
- Configuration files: Libre d'utilisation et de modification

## 🔗 Liens utiles

- [Marlin Documentation](https://marlinfw.org/docs/basics/introduction.html)
- [BigTreeTech GitHub](https://github.com/bigtreetech)
- [SKR V1.4 Documentation](https://github.com/bigtreetech/BIGTREETECH-SKR-V1.3/tree/master/BTT%20SKR%20V1.4)
- [TMC2209 Datasheet](https://www.trinamic.com/products/integrated-circuits/details/tmc2209-la/)

## 🙏 Remerciements

- Équipe Marlin Firmware
- Communauté BigTreeTech
- Communauté Ender 3

---

**Made with ❤️ for the 3D printing community**
