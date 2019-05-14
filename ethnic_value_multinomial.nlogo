globals [
 somme
]

patches-own [
  uti_eth
  uti_val
  uti_ses
  raw_choice
  expa
  prob
]

turtles-own [
  beta_value
  beta_ethnic
  beta_ses
  ethnic_peak
  value_peak
  ses_peak
  utility_myself
]

to  setup

clear-all
;  set sum_prob 0
 ask patches [ set pcolor white
    if random 100 < density [sprout 1 [
    ifelse random 100 < fraction_blue [        ; ratio blue/orange is drawn (relative ethnic group size)
        ifelse random 100 < high_ses_blue      ; ratio high ses/low ses in blue population
        [set color  108
        ifelse random 100 < tol_high_ses_blue  ; ratio tolerant/intolerant in high ses blue population
        [set shape "circle"]
        [set shape "square"]
        ]
        [set color  105
        ifelse random 100 < tol_low_ses_blue
        [set shape "circle"]
        [set shape "square"]
        ]

        ]

       [
      ifelse random 100 <  high_ses_orange     ; ratio high ses/low ses in orange population
        [set color 28
        ifelse random 100 < tol_high_ses_orange  ; ratio tolerant/intolerant in high ses orange population
        [set shape "circle"]
        [set shape "square"]
         ]
        [set color 25
        ifelse random 100 < tol_low_ses_orange
        [set shape "circle"]
        [set shape "square"]
        ]
      ]


    attribute-preferences

      ]
    ]
   ]

 reset-ticks
end

to go
 update-turtles

 tick
end

to update-turtles


 ask turtles [

    attribute-preferences
    let alternative one-of patches with [not any? turtles-here and any? turtles-on neighbors]     ; alternative patch
    let options (patch-set alternative patch-here)            ; patchset of alternative options: current patch and alternative empty patch
    let shape-myself shape
    let color-myself color
    let ses-myself color mod 2
    let r random-float 1.00




  ask options [    ; utility and probability are calculated for both options current patch and alternative patch, utility calculated for ethnic,value and ses concentration.
                   ; Used single-peaked function as in Zhang and Flache/Sage, needed in local variable of options.
                     ; Used ifelse-value reporter as in Paolillo/Lorenz model: given a condition (e.g.fraction <= desired fraction), reports [reporter 1] if condition true, [reporter 2] if condition false

    let xe count (turtles-on neighbors)  with [abs (color - color-myself) = 3 or (color - color-myself) = 0 ]     ; concetration of same color agents (ethnicity) (two conditions because 2 ses colors)
    let xv count (turtles-on neighbors)  with [shape = shape-myself]                  ; concentration shape (value)
    let xs count (turtles-on neighbors) with [color mod 2 = ses-myself]               ; concentration same brightness (ses) (color mod 2 = 0 bright high ses agents; color mod 2 = 1 dark low ses agents)
    let n  count (turtles-on neighbors)                                               ; count turtles on neighbors


    set uti_eth ifelse-value ((xe / n) <= [ethnic_peak] of myself) [xe  / n] [M + (( (1 - (xe / n)) * (1 - M)) / (1 - [ethnic_peak] of myself))]     ; ethnic utility
    set uti_val ifelse-value ((xv / n) <= [value_peak] of myself) [xv  / n] [M + (( (1 - (xv / n)) * (1 - M)) / (1 - [value_peak] of myself))]       ; value utility
    set uti_ses ifelse-value ((xs / n) <= [ses_peak] of myself) [xs / n] [M + (( (1 - (xs / n)) * (1 - M)) / (1 - [ses_peak] of myself))]            ; ses utility

      set raw_choice  ([beta_value] of myself * uti_val) + ([beta_ses] of myself * uti_ses)  + ([beta_ethnic] of myself * uti_eth) ; raw chooice option = sum beta*utility for each characteristic
      set expa  exp raw_choice  ;  includsion randomness: beta*Utility + epsilon


    ]

    set somme sum [expa] of options           ; sum options' utility

    ask options [ set prob (expa / somme)]    ;; probability for each option (exp Utility / sum exp utility)

    ifelse [prob] of patch-here > r [        ; agents make a binary choice: agents stays if probability of patch-here is higher than r, moves to alternative otherwise
      move-to patch-here
      set utility_myself (([uti_eth] of patch-here + [uti_val] of patch-here + [uti_ses] of patch-here) / 3) ; utility if calculated if agent stays, as average of the 3 utilities of the current patch
      ][
      move-to alternative]
  ]

end

to attribute-preferences        ; updated preferences for agents

  ifelse random 100 < check_noise [
    move-to one-of patches with [not any?  turtles-here]            ;  noise: agents move randomly to an empty cell
  ]
  [
    set ethnic_peak ifelse-value (shape = "square") [ethnic_square_peak][ethnic_circle_peak]      ; ethnic peak for square agents and circle agents
    set value_peak ifelse-value (shape = "square") [value_square_peak][value_circle_peak]         ; value peak for square agents and circle agents
    set ses_peak ifelse-value (shape = "square") [ses_square_peak][ses_circle_peak]               ; ses peak for square agents and circle agents
  set beta_ethnic ifelse-value (shape = "square") [ethnic_square_beta][ethnic_circle_beta]        ; beta for ethnic utility for square agents and circle agents
    set beta_value ifelse-value (shape = "square") [value_square_beta][value_circle_beta]         ; beta for value utility for square agents and circle agents
  set beta_ses ifelse-value (shape = "square") [ses_square_beta][ses_circle_beta]                 ; beta for ses utility for square agents and circle agents
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
353
10
766
424
-1
-1
12.3
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
11
10
147
43
density
density
50
99
99.0
1
1
NIL
HORIZONTAL

SLIDER
13
67
147
100
high_ses_blue
high_ses_blue
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
156
10
310
43
fraction_blue
fraction_blue
50
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
161
64
310
97
high_ses_orange
high_ses_orange
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
11
104
147
137
tol_high_ses_blue
tol_high_ses_blue
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
162
102
310
135
tol_high_ses_orange
tol_high_ses_orange
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
10
140
148
173
tol_low_ses_blue
tol_low_ses_blue
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
160
138
312
171
tol_low_ses_orange
tol_low_ses_orange
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
9
231
156
264
ethnic_square_peak
ethnic_square_peak
0
1
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
165
231
318
264
ethnic_circle_peak
ethnic_circle_peak
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
10
266
156
299
value_square_peak
value_square_peak
0
1
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
165
267
317
300
value_circle_peak
value_circle_peak
0
1
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
9
304
157
337
ses_square_peak
ses_square_peak
0
1
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
164
304
318
337
ses_circle_peak
ses_circle_peak
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
86
361
258
394
M
M
0
1
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
15
420
151
453
ethnic_square_beta
ethnic_square_beta
0
100
46.0
1
1
NIL
HORIZONTAL

SLIDER
174
423
313
456
ethnic_circle_beta
ethnic_circle_beta
0
100
79.0
1
1
NIL
HORIZONTAL

SLIDER
14
457
151
490
value_square_beta
value_square_beta
0
100
71.0
1
1
NIL
HORIZONTAL

SLIDER
173
459
313
492
value_circle_beta
value_circle_beta
0
100
61.0
1
1
NIL
HORIZONTAL

SLIDER
14
493
152
526
ses_square_beta
ses_square_beta
0
100
33.0
1
1
NIL
HORIZONTAL

SLIDER
170
494
314
527
ses_circle_beta
ses_circle_beta
0
100
78.0
1
1
NIL
HORIZONTAL

SLIDER
90
538
262
571
check_noise
check_noise
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
359
425
416
470
% blue 
(count turtles with [color = 105 or color = 108] / count turtles) * 100
2
1
11

MONITOR
421
425
496
470
% circle_pop
(count turtles with [shape = \"circle\"] / count turtles) * 100
2
1
11

MONITOR
500
424
589
469
% bright_pop
(count turtles with [shape = \"circle\"] / count turtles) * 100
2
1
11

MONITOR
596
425
679
470
%circle_blue
(count turtles with [color = 108 or color = 105 and shape = \"circle\"] / count turtles with [color = 108 or color = 105]) * 100
2
1
11

MONITOR
684
424
766
469
% circle_org
(count turtles with [color = 28 or color = 25 and shape = \"circle\"] / count turtles with [color = 28 or color = 25]) * 100
2
1
11

MONITOR
359
471
419
516
% orange
(count turtles with [color = 25 or color = 28] / count turtles) * 100
2
1
11

MONITOR
422
471
501
516
%square_pop
(count turtles with [shape = \"square\"] / count turtles) * 100
2
1
11

MONITOR
505
471
589
516
%dark_pop
(count turtles with [color mod 2 = 1] / count turtles) * 100
2
1
11

MONITOR
597
471
677
516
%bright_blue
(count turtles with [color = 108 or color = 105 and color mod 2 = 0] / count turtles  with [color = 108 or color = 105]) * 100
2
1
11

MONITOR
683
470
766
515
%bright_org
(count turtles with [color = 28 or color = 25 and color mod 2 = 0] / count turtles  with [color = 28 or color = 25]) * 100
2
1
11

MONITOR
354
519
430
564
%blu_cir_brg
((count turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
431
518
510
563
%blu_sqr_brg
((count turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
511
519
589
564
%org_cir_brg
((count turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
591
519
677
564
%org_sqr_brg
((count turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
353
563
429
608
%blu_cir_drk
((count turtles with [color = 108 or color = 105 and shape = \"circle\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
432
563
510
608
%blu_sqr_drk
((count turtles with [color = 108 or color = 105 and shape = \"square\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
513
564
590
609
%org_cir_drk
((count turtles with [color = 28 or color = 25 and shape = \"circle\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
591
564
677
609
%_org_sqr_drk
((count turtles with [color = 28 or color = 25 and shape = \"square\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

BUTTON
688
527
753
560
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
688
563
752
596
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
787
10
1098
160
all agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [ count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles"

PLOT
786
161
1101
311
blue agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [ color = 105 or color = 108 and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color = 105 or color = 108 and count (turtles-on neighbors) >= 1 ]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 105 or color = 108 and count (turtles-on neighbors) >= 1 ]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color = 105 or color = 108]"

PLOT
1111
162
1420
312
orange agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethni-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and count (turtles-on neighbors) >= 1]\n"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color = 28 or color = 25 and count (turtles-on neighbors) >= 1 ]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color = 28 or color = 25]"

PLOT
787
313
1101
463
circle agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethni-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [shape = \"circle\" and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [shape = \"circle\" and  count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [shape = \"circle\" and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [shape = \"circle\"]"

PLOT
1111
313
1421
463
square agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [shape = \"square\" and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [shape = \"square\" and  count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [shape = \"square\" and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [shape = \"square\"]"

PLOT
787
467
1107
607
bright  agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color mod 2 = 0 and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color mod 2 = 0 and  count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color mod 2 = 0 and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color mod 2 = 0]"

PLOT
1112
464
1422
606
dark agents
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color mod 2 = 1 and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color mod 2 = 1 and  count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color mod 2 = 1 and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color mod 2 = 1]"

PLOT
1109
10
1421
160
specific subgroup
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic-seg" 1.0 0 -5825686 true "" "if subgroup = \"blu-hig-sqr\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-sqr\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-hig-crl\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-crl\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-sqr\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-sqr\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-crl\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-crl\" [plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\n\n\n"
"value-seg" 1.0 0 -10899396 true "" "if subgroup = \"blu-hig-sqr\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-sqr\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 108 or color = 105 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-hig-crl\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-crl\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-sqr\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 28 or color = 25  and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-sqr\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-crl\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ color = 28 or color = 25  and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-crl\" [plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]"
"ses-seg" 1.0 0 -2674135 true "" "if subgroup = \"blu-hig-sqr\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-sqr\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-hig-crl\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-crl\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-sqr\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-sqr\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-crl\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-crl\" [plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\n"
"utility" 1.0 0 -16777216 true "" "if subgroup = \"blu-hig-sqr\" [plot mean [utility_myself] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-sqr\" [plot mean [utility_myself] of turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-hig-crl\" [plot mean [utility_myself] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"blu-low-crl\" [plot mean [utility_myself] of turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-sqr\" [plot mean [utility_myself] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-sqr\" [plot mean [utility_myself] of turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-hig-crl\" [plot mean [utility_myself] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 0 and count (turtles-on neighbors) >= 1]]\nif subgroup = \"org-low-crl\" [plot mean [utility_myself] of turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 1 and count (turtles-on neighbors) >= 1]]"

CHOOSER
1350
116
1442
161
subgroup
subgroup
"blu-hig-sqr" "blu-low-sqr" "blu-hig-crl" "blu-low-crl" "org-hig-sqr" "org-low-sqr" "org-hig-crl" "org-low-crl"
4

@#$#@#$#@
## WHAT IS IT?

Inclusion of multinomial choice models and random utility to "How different homophily preferences mitigate and spur ethnic and value segregation: Schelling’s model extended”: https://github.com/RoccoPaolillo/EthnicValueSegregation

## HOW IT WORKS

Agents differ by three characteristics: ethnicity (color: blue and orange) value-orientation (shape: circle and square), socio-economic status (brightness: brigt and dark). Each agents makes a choice whether to stay on the current patch or relocate to an alternative empty patch. Following Zhang and McFadden (1973) The probability for an agent to choose an option (here neighborhood) consists of the utility derived from the characteristic of the option (u) and constant beta (ß) indicating how important that characteristic is for the agent. 3 characteristics of the neighborhood are considered, for each one a constant beta and utility are defined. Utility is calculated according to a single-peaked function in Zhang (2004):

- ethnic homophily: % agents with same color (ethnicity)
- value homophily: % agents with same shape (value-orientation)
- ses homophily: % agents with same brightness (social class)

So, the raw probability for an option (neighborhood) to be chosen is equal to:

P: beta_ethnic*utility_ethnic + beta_value*utility_value + beta_ses*utility_ses

For the actual probability of an option, a random term is added using exp function

Each probability is compared to random temr r: if probability of current patch > r, then the agent stays on its patch, moves to alternative otherwise

## HOW TO USE IT

Initial setting (static parameters):

- density of population

- nested sorting of agents into ethnicity --> social class --> value orientation:
	* fraction blue/orange
	* fraction high ses/low ses in blue population
	* fraction high ses/low ses in orange population
	* fraction tolerant/intolerant in high ses blue population
	* fraction tolerant/intolerant in low ses blue population
	* fraction tolerant/intolerant in high ses orange population
	* fraction tolerant/intolerant in low ses orange population


Agents' definition of utility for each characteristic and relative beta depends on the value-orientation of agents (circle vs square). Each parameter is independent from the others, and each one for the circle agents and square agents:

- peak of desired fraction of similar ones for utility (normalized to 1):
	* ethnic_peak
	* value_peak
	* ses_peak



- beta constant of how desired is that characteristic of the neighborhood:
	* ethnic_beta
	* value_beta
	* ses_beta

The parameters are independent for square agents and circle agents.

- M for right-side slope of single-peaked function, equal for all agents
- check_noise: % of agents moving randomly independent of utility (robustness)

## THINGS TO NOTICE

- Average segregation for the three characteristics (as fraction of similar ones in Moore distance 8 patches):
	* ethnic segregation
	* value segregation
	* ses segregation
- Average degree of utility agents (calcualted  as average of the three utility for current patch:
(ethnic utility + value utility + ses utility ) / 3

Plots  refer to:
- entire population
- blue vs orange population
- circle vs square population
- high ses vs low ses population
- subpopulation ethnicityXvalue-orientationXses (to be selected)

## THINGS TO TRY

Set up distribution of agents in each category ethnicity > ses > value-orientation.
Set slides for utility referred to different neighborhood characteristics + M
Set slides for beta for that neighborhood characteristic

## EXTENDING THE MODEL

I think more clear dynamics and conditions would emerge if utility is defined independently for each subgroup, but at cost of increasing number of parameters.

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
