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
        ifelse random 100 < high_ses_blue
        [set color  108
        ifelse random 100 < tol_high_ses_blue
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
      ifelse random 100 <  high_ses_orange     ; ratio value-oriented / ethnicity-oriented is drawn for minority group orange (relative value group size)
        [set color 28
        ifelse random 100 < tol_high_ses_orange
        [set shape "circle"]
        [set shape "square"]
         ]
        [set color 25
        ifelse random 100 < tol_low_ses_orange
        [set shape "circle"]
        [set shape "square"]
        ]
      ]


    attribute-preferences  ;; to attribute beta in the initialization (can be updated)

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
    let alternative one-of patches with [not any? turtles-here and any? turtles-on neighbors]
    let options (patch-set alternative patch-here)
    let shape-myself shape
    let color-myself color
    let ses-myself color mod 2
    let r random-float 1.00




  ask options [
    let xe count (turtles-on neighbors)  with [abs (color - color-myself) = 3 or (color - color-myself) = 0 ]
    let xv count (turtles-on neighbors)  with [shape = shape-myself]
    let xs count (turtles-on neighbors) with [color mod 2 = ses-myself]
    let n  count (turtles-on neighbors)

    set uti_eth ifelse-value ((xe / n) <= [ethnic_peak] of myself) [xe  / n] [M + (( (1 - (xe / n)) * (1 - M)) / (1 - [ethnic_peak] of myself))]
    set uti_val ifelse-value ((xv / n) <= [value_peak] of myself) [xv  / n] [M + (( (1 - (xv / n)) * (1 - M)) / (1 - [value_peak] of myself))]
    set uti_ses ifelse-value ((xs / n) <= [ses_peak] of myself) [xs / n] [M + (( (1 - (xs / n)) * (1 - M)) / (1 - [ses_peak] of myself))]

      set raw_choice  ([beta_value] of myself * uti_val) + ([beta_ses] of myself * uti_ses)  + ([beta_ethnic] of myself * uti_eth)
      set expa  exp raw_choice  ;  includsion randomness


    ]

    set somme sum [expa] of options

    ask options [ set prob (expa / somme)]    ;; probability of each option

    ifelse [prob] of patch-here > r [
      move-to patch-here
      set utility_myself (([uti_eth] of patch-here + [uti_val] of patch-here + [uti_ses] of patch-here) / 3)
      ][
      move-to alternative] ;  implementation of random utility/multinomial choice. This is correct: frozen states
                                                                                                                         ;   appear when comparison between current patch and alternative is done
  ]

end

to attribute-preferences

  ifelse random 100 < check_noise [
    move-to one-of patches with [not any?  turtles-here]            ;  noise: agents move to an empty cell
  ]
  [
    set ethnic_peak ifelse-value (shape = "square") [ethnic_square_peak][ethnic_circle_peak]
    set value_peak ifelse-value (shape = "square") [value_square_peak][value_circle_peak]
    set ses_peak ifelse-value (shape = "square") [ses_square_peak][ses_circle_peak]
  set beta_ethnic ifelse-value (shape = "square") [ethnic_square_beta][ethnic_circle_beta]
    set beta_value ifelse-value (shape = "square") [value_square_beta][value_circle_beta]
  set beta_ses ifelse-value (shape = "square") [ses_square_beta][ses_circle_beta]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
343
11
722
391
-1
-1
11.242424242424242
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

BUTTON
677
550
732
583
go
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
188
11
325
44
fraction_blue
fraction_blue
50
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
7
10
179
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

PLOT
754
10
1072
155
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
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [ count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles"

MONITOR
398
399
481
444
% circle_pop
(count turtles with [shape = \"circle\"] / count turtles) * 100
1
1
11

MONITOR
398
448
480
493
% square_pop
(count turtles with [shape = \"square\"] / count turtles) * 100
1
1
11

TEXTBOX
79
58
109
76
blue
11
0.0
1

TEXTBOX
229
57
265
75
orange
11
0.0
1

MONITOR
333
398
393
443
% blue
(count turtles with [color = 105 or color = 108] / count turtles) * 100
2
1
11

MONITOR
332
447
393
492
% orange
(count turtles with [color = 25 or color = 28] / count turtles) * 100
2
1
11

SLIDER
87
553
259
586
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
1519
188
1615
233
utility_average
mean [utility-myself] of turtles
2
1
11

MONITOR
1524
283
1591
328
sum_prob
sum_prob
17
1
11

SLIDER
11
77
167
110
high_ses_blue
high_ses_blue
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
172
76
326
109
high_ses_orange
high_ses_orange
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
485
400
563
445
% bright_pop
(count turtles with [color mod 2 = 0] / count turtles) * 100
2
1
11

MONITOR
486
448
564
493
% dark_pop
(count turtles with [color mod 2 = 1] / count turtles) * 100
2
1
11

SLIDER
14
240
189
273
ethnic_square_peak
ethnic_square_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
15
276
164
309
value_square_peak
value_square_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
13
313
166
346
ses_square_peak
ses_square_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
173
241
330
274
ethnic_circle_peak
ethnic_circle_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
176
278
330
311
value_circle_peak
value_circle_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
175
312
328
345
ses_circle_peak
ses_circle_peak
0
1
0.0
0.1
1
%
HORIZONTAL

SLIDER
79
363
251
396
M
M
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
17
434
160
467
ethnic_square_beta
ethnic_square_beta
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
16
471
159
504
value_square_beta
value_square_beta
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
15
507
159
540
ses_square_beta
ses_square_beta
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
171
433
318
466
ethnic_circle_beta
ethnic_circle_beta
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
171
471
317
504
value_circle_beta
value_circle_beta
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
171
509
318
542
ses_circle_beta
ses_circle_beta
0
100
100.0
1
1
NIL
HORIZONTAL

PLOT
754
158
1073
301
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
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [ count (turtles-on neighbors) >= 1 and color = 105 or color = 108]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 105 or color = 108]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) >= 1 and color = 105 or color = 108]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color = 105 or color = 108]"

SLIDER
174
151
328
184
tol_low_ses_orange
tol_low_ses_orange
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
677
505
734
538
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

PLOT
1084
156
1402
299
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
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [ count (turtles-on neighbors) >= 1 and color = 28 or color = 25]\n"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 28 or color = 25]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) >= 1 and color = 28 or color = 25]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [color = 28 or color = 25]"

SLIDER
172
115
328
148
tol_high_ses_orange
tol_high_ses_orange
0
100
83.0
1
1
NIL
HORIZONTAL

MONITOR
329
501
409
546
% blu_cir_brg
((count turtles with [color = 108 or color = 105 and shape = \"circle\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

SLIDER
11
115
169
148
tol_high_ses_blue
tol_high_ses_blue
0
100
19.0
1
1
NIL
HORIZONTAL

SLIDER
11
152
171
185
tol_low_ses_blue
tol_low_ses_blue
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
413
501
496
546
% blu_sqr_brg
((count turtles with [color = 108 or color = 105 and shape = \"square\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
329
549
410
594
% blu_cir_drk
((count turtles with [color = 108 or color = 105 and shape = \"circle\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
413
549
494
594
% blu_sqr_drk
((count turtles with [color = 108 or color = 105 and shape = \"square\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
499
504
579
549
% org_cir_brg
((count turtles with [color = 28 or color = 25 and shape = \"circle\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
584
505
668
550
%org_sqr_brg
((count turtles with [color = 28 or color = 25 and shape = \"square\" and color mod 2 = 0]) / count turtles) * 100
2
1
11

MONITOR
499
551
580
596
%org_cir_drk
((count turtles with [color = 28 or color = 25 and shape = \"circle\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
583
551
670
596
%_org_sqr_drk
((count turtles with [color = 28 or color = 25 and shape = \"square\"  and color mod 2 = 1]) / count turtles) * 100
2
1
11

MONITOR
575
400
653
445
%cirle_blue
(count turtles with [color = 108 or color = 105 and shape = \"circle\"] / count turtles with [color = 108 or color = 105]) * 100
2
1
11

MONITOR
576
446
652
491
%bright_blue
(count turtles with [color = 108 or color = 105 and color mod 2 = 0] / count turtles  with [color = 108 or color = 105]) * 100
2
1
11

MONITOR
659
398
733
443
% circle_org
(count turtles with [color = 28 or color = 25 and shape = \"circle\"] / count turtles with [color = 28 or color = 25]) * 100
2
1
11

MONITOR
660
444
734
489
% bright_org
(count turtles with [color = 28 or color = 25 and color mod 2 = 0] / count turtles  with [color = 28 or color = 25]) * 100
2
1
11

PLOT
754
304
1072
446
tolerant agents
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
"ethnic-seg" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [abs (color - [color] of myself) = 3 or (color - [color] of myself) = 0 ] / count (turtles-on neighbors)] of turtles with [shape = \"circle\" and count (turtles-on neighbors) >= 1]"
"value-seg" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [shape = \"circle\" and  count (turtles-on neighbors) >= 1]"
"ses-seg" 1.0 0 -2674135 true "" "plot mean [count (turtles-on neighbors) with [color mod 2 = [color] of myself mod 2] / count (turtles-on neighbors)] of turtles with [shape = \"circle\" and count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility_myself] of turtles with [shape = \"circle\"]"

PLOT
754
451
1073
592
high ses agents
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
1084
303
1403
445
intolerant agents
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
1081
453
1403
594
low ses agents
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

@#$#@#$#@
## WHAT IS IT?

Inclusion of multinomial choice and random utility models in the EthnicValue segregation extension of Schelling "How different homophily preferences mitigate and spur ethnic and value segregation: Schelling's model extended”: https://github.com/RoccoPaolillo/EthnicValueSegregation

The options of agents are nodes where to relocate. As in multinomial choice models, the utility of each option is the product of characteristics of the chooser agent and characteristics of the option. Here, relevant characteristics of the option are the ethnic composition and value composition of the potential neighborhood, while characteristics of the agents is the weight given to each composition represented by the parameter beta.
In the ACS model, ethnicity-oriented agents only considered ethnic composition (same color) and value-oriented agents value composition (agents with same shape = circle), following the threshold version of Schelling's model. In the current version of the model, each agent holds a beta weighting the importance of ethnic composition and value composition in defining utility for an option. 
At each step, an agent makes a choice whether to stay on its node or another available node. The option with the highest utility is chosen, although random utility models allow the inclusion of randomness with not the choice with the  highest utility to be necessarily chosen and some choices be random.



## HOW IT WORKS

Each agent is given a beta-ethnic for ethnic composition of the neighborhood (concentration of agents with the same color) and beta-value for the value concentration (concentration of agents with the same shape). Agents are divided into two ethnic groups and each group into different value orientation (the proportion to be set by observer). Beta-ethnic and beta-value are independent of the value-orientation of the agent.

### Static state variables of agents:

* **Ethnicity** (color tag): Ethnicity 1 (blue) / Ethnicity 2 (orange)

* **Value Orientation** (shape tag): value 1 (square) / value 2 (circle)

* **Beta-ethnic** weight to the ethnic composition of neighborhoods of options

* **Beta-value** to assess the value composition of neighborhoods

### Behavior of agents:

At each run, one agent calculates the utility of each option where they can relocate, which include their current node and all empty nodes. Utility for each potential node is calculated as the sum of:

* ethnic composition of the neighborhood of node option (agents with the same color) * beta-ethnic
* value composition of the neighborhood of node option (agents with the same shape) * beta-value

for both neighborhood is Moore Distance (8 nodes).

The probability for each node option to be chosen follows a random utility model with the formula:

* exp utility of option / sum exp utility of all available options

If the option is picked up, the agent relocates to the node. If  the chosen option is its current patch, the agent results to not move. If it relocates, its patch becomes available for the next agent who runs the procedure.

## HOW TO USE IT

* density: density of the population (% number of patches with one agent in random initial condition). **Below 70% risk that there is not agent on neighborhood and simulation stops**
* fraction_majority: ratio ethnicity blue / ethnicity orange
* tolerant_majority: ratio value-oriented agents / ethnicity-oriented agents in the blue  ethnic group
* tolerant_minority: ratio value-oriented agents / ethnicity-oriented agents in the orange  ethnic group

**To hold ratio value-oriented / ethnicity-oriented at the population level, select fraction_majority and fraction_minority at the same level**

### beta-ethnic and beta-value:
* for each subgroup
* for each ethnicity = same value within the column blue/orange
* for each value-orientation  = same value within the row square/circle
* check_noise: percentage turtles relocating randomly to empty node


## THINGS TO NOTICE

* ethnic segregation: agents in neighborhood with same color
* value segregation: agents in neighborhood with same shape
* utility of agent for current node, calculated as (u-umin) / (umax-umin) once at least either beta-ethnic or beta-value is different from 0
For overall population, ethnic group and subgroup
* type of agents in the neighborhood (-neigh) for each subgroup

## REFERENCES

McFadden, D. (1973). Conditional logit analysis of qualitative choice behavior. In Paul Zarembka (Eds.).  Frontiers in Econometrics (Chapter 4, pp. 105-142). Academic Press: New York, NY.
Zhang, J. (2004). Residential segregation in an all-integrationist world. Journal of Economic Behavior & Organization, 54(4), 533-550.
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
