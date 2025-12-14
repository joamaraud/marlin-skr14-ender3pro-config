; Start G-code pour Ender 3 Pro - BTT SKR V1.4
; Configuration: CR Touch + TMC2209 + Auto Bed Leveling
G90 ; Positionnement absolu
M82 ; Extrudeur absolu
M104 S{material_print_temperature_layer_0} ; Chauffe hotend
M140 S{material_bed_temperature_layer_0} ; Chauffe bed
M190 S{material_bed_temperature_layer_0} ; Attend bed
M109 S{material_print_temperature_layer_0} ; Attend hotend
G28 ; Home tous axes
G29 ; Auto bed leveling
M420 S1 ; Active bed leveling
G92 E0 ; Reset extrudeur
G1 Z2.0 F3000 ; Monte Z
G1 X10.1 Y20 Z0.3 F5000.0 ; Position départ
G1 X10.1 Y200.0 Z0.3 F1500.0 E15 ; Ligne de purge 1
G1 X10.4 Y200.0 Z0.3 F5000.0
G1 X10.4 Y20 Z0.3 F1500.0 E30 ; Ligne de purge 2
G92 E0 ; Reset extrudeur
G1 Z2.0 F3000 ; Monte Z
