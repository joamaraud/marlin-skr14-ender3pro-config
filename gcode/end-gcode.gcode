; End G-code pour Ender 3 Pro - BTT SKR V1.4
; Configuration: CR Touch + TMC2209 + BTT Relay
G91 ; Positionnement relatif
G1 E-2 F2700 ; Rétraction
G1 E-2 Z0.2 F2400 ; Rétraction + monte Z
G1 X5 Y5 F3000 ; Déplace légèrement
G1 Z10 ; Monte Z de 10mm
G90 ; Positionnement absolu
G1 X0 Y230 ; Présente l'impression
M106 S0 ; Éteint ventilateur
M104 S0 ; Éteint hotend
M140 S0 ; Éteint bed
M84 ; Désactive moteurs
M81 ; Arrêt automatique (BTT Relay)
