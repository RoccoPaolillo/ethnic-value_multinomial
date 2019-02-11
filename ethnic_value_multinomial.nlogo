patches-own [
  fraction-blue
  fraction-orange
  fraction-tolerant
  fraction-intolerant
  utility-blue
  utility-orange
  utility-tolerant
  utility-intolerant
]


to setup
clear-all

  ask patches [
    if random 100 < density [           ;; population density
      sprout 1 [
        set color ifelse-value (random 100 < (fraction_majority) ) [105] [27]    ;; population devided in ethnicity: 1 (blue) and 2 (orange)
        ifelse random 100 < (fraction_tolerant)[set shape "circle"][set shape "square"]    ;; population divided into value-orientation: tolerant (circle) intolerant (square)
      ]
    ]
  ]
  update-neighbors
  reset-ticks
end


to GO
 choose
 update-neighbors
 ask turtles [if random 100 < move_anyway [move-to one-of patches  with [not any? turtles-here]]]
 tick
end


to update-neighbors                      ;; utility of potential relocation cell (the option) is updated, through the composition of its surrounding neighborhood
 ask patches [                           ;; fraction calculated for the characteristics of interest when at least one turtle is in the neighborhood (x/n in Zhang)
    if any? (turtles-on neighbors) [      ;; used to avoid bug if not any turtles on neighbors
     set fraction-blue (count (turtles-on neighbors) with [ color = 105 ] / (count (turtles-on neighbors) ))           ;; blue ethnicity agents (regardless value)
     set fraction-orange (count (turtles-on neighbors) with [ color = 27 ] / (count (turtles-on neighbors) ))          ;; orange ethnicity agents (regardless value)
     set fraction-tolerant (count (turtles-on neighbors) with [shape = "circle"] / (count (turtles-on neighbors) ))    ;; tolerant agents (regardless ethnicity)
                                                                   ;; utility calculated as weight of desired composition (Z in Zhang) * neighborhood characteristic (the fraction)
     set utility-blue (Z-similar-wanted * fraction-blue)           ;; utility for blue ethnicity-oriented agents
     set utility-orange (Z-similar-wanted * fraction-orange)       ;; utility for orange ethnicity-oriented agents
     set utility-tolerant (Z-similar-wanted * fraction-tolerant)   ;; utility for tolerant agents
  ]
    if color_patches = "nothing" [set pcolor black]                                 ;; color of patches. The whiter is the patch, the higher the reference fraction in the neighborhood is. This means that
    if color_patches = "fraction-blue" [set pcolor white * fraction-blue]           ;; the patch increases the utility as for the preference option.
    if color_patches = "fraction-orange" [set pcolor white * fraction-orange]
    if color_patches = "fraction-tolerant" [set pcolor white * fraction-tolerant]
  ]
end


to choose            ;; choice of turtles between two options (current cell vs alternative empty cell)
  ask turtles [
    let alternative one-of patches with [not any? turtles-here]     ;; from original Schelling: the alternative is an empty cell
      ifelse shape = "square"                                       ;; the probability that the agent relocates to an alternative patch relies on the difference between utility of alternative and
     [                                                              ;; current fraction * beta of subpopulation. The type of desired fraction (blue agents, or orange agents or tolerant agents) depends
      ifelse color = 105                                            ;; on value-orientation given by shape
      [if random 100 < ((([utility-blue] of alternative - [utility-blue] of patch-here) * beta-ethnic-blue) * 100) [move-to alternative]]                ;; choice blue ethnicity-oriented
      [if random 100 < ((([utility-orange] of alternative - [utility-orange] of patch-here) * beta-ethnic-orange) * 100) [move-to alternative]]          ;; choice orange ethnicity-oriented
     ][
      ifelse color = 105
      [if random 100 < ((([utility-tolerant] of alternative - [utility-tolerant] of patch-here) * beta-value-blue) * 100) [move-to alternative]]         ;; choice of blue value-oriented
      [if random 100 < ((([utility-tolerant] of alternative - [utility-tolerant] of patch-here) * beta-value-orange) * 100) [move-to alternative]]       ;; choice of otange value-oriented
     ]
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
334
10
887
564
-1
-1
10.7
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
49
143
125
176
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
205
145
287
178
GO
GO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
129
144
199
177
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
22
11
233
44
density
density
50
99
50.0
1
1
%
HORIZONTAL

SLIDER
146
366
314
399
Z-similar-wanted
Z-similar-wanted
0
1
1.0
0.1
1
%
HORIZONTAL

SLIDER
23
48
233
81
fraction_majority
fraction_majority
50
100
50.0
1
1
%
HORIZONTAL

SLIDER
77
497
253
530
move_anyway
move_anyway
0
20
0.0
0.1
1
%
HORIZONTAL

MONITOR
1297
10
1475
55
Ethnic Segregation
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]
3
1
11

MONITOR
1297
60
1476
105
Value segregation
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]
3
1
11

MONITOR
1297
109
1476
154
Neighborhood Density
mean [count (turtles-on neighbors)] of turtles / 8
3
1
11

PLOT
894
10
1282
167
All agents
time
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"Value Seg." 1.0 0 -13840069 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"Neighborhood D." 1.0 0 -9276814 true "" "plot mean [count (turtles-on neighbors)] of turtles / 8"

SLIDER
23
86
235
119
fraction_tolerant
fraction_tolerant
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
18
252
152
285
beta-value-blue
beta-value-blue
0
100
79.0
0.1
1
NIL
HORIZONTAL

SLIDER
163
252
313
285
beta-ethnic-blue
beta-ethnic-blue
0
100
77.8
0.1
1
NIL
HORIZONTAL

CHOOSER
92
422
232
467
color_patches
color_patches
"nothing" "fraction-blue" "fraction-orange" "fraction-tolerant"
1

TEXTBOX
143
201
188
219
Choice
13
0.0
1

TEXTBOX
35
376
139
394
utility neighborhood
11
0.0
1

TEXTBOX
37
230
144
248
beta value-oriented
11
0.0
1

TEXTBOX
180
228
299
246
beta ethnicity-oriented
11
0.0
1

TEXTBOX
150
338
168
356
x
11
0.0
1

TEXTBOX
260
510
288
528
noise
11
0.0
1

SLIDER
165
293
310
326
beta-ethnic-orange
beta-ethnic-orange
0
100
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
17
294
152
327
beta-value-orange
beta-value-orange
0
100
100.0
0.1
1
NIL
HORIZONTAL

PLOT
891
176
1189
326
Blue ethnicity-oriented
time
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]\n"
"Value Seg." 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]\n"
"Neighborhood D." 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\" and color = 105] / 8"

PLOT
1195
176
1495
326
Blue value-oriented
time
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]\n"
"Value Seg." 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]\n"
"Neighborhood D." 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\" and color = 105] / 8"

PLOT
893
336
1191
486
Orange ethnicity-oriented
time
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Ethnic. Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"Value Seg." 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]\n"
"Neighborhood D." 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\" and color = 27] / 8"

PLOT
1200
335
1497
485
Orange value-oriented
time
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]\n"
"Value Seg." 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]\n"
"Neighborhood D." 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\" and color = 27] / 8"

TEXTBOX
248
59
283
77
blue
11
0.0
1

TEXTBOX
244
98
284
116
circle
11
0.0
1

MONITOR
1125
499
1279
544
% ethnicity-oriented blue
(count turtles with [color = 105 and shape = \"square\"] / count turtles with [color = 105]) * 100
2
1
11

MONITOR
1285
498
1421
543
% value-oriented blue
(count turtles with [color = 105 and shape = \"circle\"] / count turtles with [color = 105]) * 100
2
1
11

MONITOR
1127
549
1279
594
% ethnicity-oriented orange
(count turtles with [color = 27 and shape = \"square\"] / count turtles with [color = 27]) * 100
2
1
11

MONITOR
1285
548
1422
593
% value-oriented orange
(count turtles with [color = 27 and shape = \"circle\"] / count turtles with [color = 27]) * 100
2
1
11

MONITOR
1027
498
1121
543
% blue agents
(count turtles with [color = 105] / count turtles) * 100
2
1
11

MONITOR
1028
549
1121
594
% orange
(count turtles with [color = 27] / count turtles) * 100
2
1
11

TEXTBOX
239
448
271
466
white
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is an extension of Thomas Schelling’s model of segregation. In the original model, agents follow a homophily behavior defining similarity based on the exclusive category of ethnicity. In multicultural contexts other criteria might be relevant to define similarity, namely tolerance towards diversity. In our extension, we add value-oriented agents to ethnicity-oriented agents and observe consequences on ethnic segregation, value segregation and population density in neighborhood.

The previous model accompanied the paper "Paolillo, R., & Lorenz, J. (2018). How different homophily preferences mitigate and spur ethnic and value segregation: Schelling’s model extended. Advances in Complex Systems, 21(06n07)".

In the original  model (Paolillo & Lorenz, 2018), agents define similarity based on their value-orientation: tolerant agents consider as similar those sharing tolerant attitudes regardless of ethnicity (value homophily, shape tag) and intolerant agents those sharing the same ethnicity regardless of tolerant attitudes (ethnic homophily, shape color). As in the original Schelling, agents stay  in a neighborhood in case the fraction of those considered as similar is higher or similar to desired threshold, independent for ethnic homophily and value homophily.

Here we adapt our extension to the multinomial choice perspective (McFadden, 1973; Zhang, 2004).

## HOW IT WORKS

Agents state variables are still ethnicity (blue and orange) and value orientation (ethnicity-oriented and value-oriented), which can be crossed. 
Differently from the original model (Paolillo & Lorenz, 2018), agents do not relocate randomly and do not update the satisfaction with neighborhood according to threshold parameter. At each step, one agent is given a choice between their current cell (patch-here) and an alternative patch. The probability for an agent to choose the alternative follows the multinomial choice perspective. 

In detail, the probability to choose the option depends on the difference between the utility of alternative (*U*alternative) and current patch (*U*here), weighted for the ß representing individual preference of agents (value-orientation):

ß(⌂(*U*alternative-*U*here)

which is applied to each group.

### Static state variables of turtles:

* **Ethnicity** (color tag): Ethnicity 1 (blue) / Ethnicity 2 (orange)
* **Value-orientation** (shape tag): ethnicity-oriented (square) / value-oriented (circle)

### Dynamic state variables of patches:

** Utility is an objective attribute of patches where agents can relocate. Utility is given by the characteristic of neighborhood and weight given to utility (Z). Characteristics of the neighborhood of interest are:

- fraction of blue agents (regardless of their value-orientation)
- fraction of orange agents (regardless of their value-orientation)
- fraction of tolerant agents (regardless of their ethnicity)

Utility is calculated following Zhang (2004): Z(x/n), i.e., utility * characteristic of the choice. Utility equal to 1 equals to utility maximization.

The choice of each agent depends on the difference between the utility of alternative patch and current patch, according to the fraction of interest to agents due to their value-orientation. The higher the difference, the higher the probability of an agent to pick the alternative as best choice. Nevertheless, the probability that  the agent will relocate  depends  on the ß which gives the utility indicator-representative taste (McFadden, 1973) of the agent depending on the category they belong to.


## HOW TO USE IT


### Initial conditions: 
* *density* → density society: probability of an agent to appear on a cell
* *fraction_majority* → relative group size ethnicity: ratio Ethnicity 1 (blue) / Ethnicity 2 (orange)
* *fraction_tolerant* - relative group size value-orientation in each ethnic group: ratio value-oriented agents (circle)/ethnicity-oriented agents (square)


### Global parameters:

* *beta-ethnic-blue*: for blue ethnicity-oriented group
* *beta-ethnic-orange*: for orange ethnicity-oriented group
* *beta-value-blue*: for blue value-oriented group
* *beta-value-orange*: for orange value-oriented group
* *Z-similar-wanted*: utility of fraction of similar agents in the neighborhood (Moore distance). Same  for all agents, since utility is considered a deterministic characteristic of the option (Zhang, 2004).


## THINGS TO NOTICE

* Ethnic segregation: mean fraction of agents in the neighborhood with the same ethnicity (color tag)
* Value segregation: mean fraction of agents  in the neighborhood with the same value (shape tag)
* Neighborhood density: mean number of agents in the neighborhood


## DOUBTS/NOTES MORE RELEVANT

1) Since each agent executes the probability choice in a forever button, eventually everyone will pick up the option that maximizes utility, so that there is convergence toward segregation. Given the same initial configurations, same segregation patterns and state equilibrium of the system emerge. Different beta (together with Z-similar-wanted) moderate the speed of the process (as in Zhang). In the end the result is the same, to check better

2) Should utility (Z-similar-wanted) be left to 1? As I get, it would reflect utility maximization and have a theoretical fit. The same combination can be reached calibrating Z and ß, e.g. Z= 0.1 - ß100 is the same as Z= 1 and ß = 10 (payoff excel). Would you directly use utility calculation and n = half neighborhood as in Zhang?

3) I think the code now reflects straightforward the assumption of the model. Ideally an agent should assess any possible option (= composition of the neighborhood) and choose according to the own ß. At the moment it would be the same, since ß would be 0 (e.g. for fraction tolerant of neighborhood which is irrelevant to ethnicity-oriented), but it would reflect better how regression models are built, and allow to include in next steps different attributes in the same agent and make it more realistic.

## REFERENCES


McFadden, D. (1973). Conditional logit analysis of qualitative choice behavior. In Paul Zarembka (Eds.).  Frontiers in Econometrics (Chapter 4, pp. 105-142). Academic Press: New York, NY.
Paolillo, R., & Lorenz, J. (2018). How different homophily preferences mitigate and spur ethnic and value segregation: Schelling’s model extended. Advances in Complex Systems, 21(06n07), 1850026.
Zhang, J. (2004b). A dynamic model of residential segregation. Journal of Mathematical Sociology, 28(3), 147-170.

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
Polygon -16777216 true false 45 210 90 255 255 90 210 45
Polygon -16777216 true false 255 210 210 255 45 90 90 45

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

face-happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face-sad
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

person2
false
0
Circle -7500403 true true 105 0 90
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 285 180 255 210 165 105
Polygon -7500403 true true 105 90 15 180 60 195 135 105

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

square
false
0
Rectangle -7500403 true true 30 30 270 270

square - happy
false
0
Rectangle -7500403 true true 30 30 270 270
Polygon -16777216 false false 75 195 105 240 180 240 210 195 75 195

square - unhappy
false
0
Rectangle -7500403 true true 30 30 270 270
Polygon -16777216 false false 60 225 105 180 195 180 240 225 75 225

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Polygon -16777216 true false 255 210 90 45 45 90 210 255
Polygon -16777216 true false 45 210 210 45 255 90 90 255

square-small
false
0
Rectangle -7500403 true true 45 45 255 255

square-x
false
0
Rectangle -7500403 true true 30 30 270 270
Line -16777216 false 75 90 210 210
Line -16777216 false 210 90 75 210

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

triangle2
false
0
Polygon -7500403 true true 150 0 0 300 300 300

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
