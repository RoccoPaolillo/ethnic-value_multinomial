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
 update-neighbors
 choose
 ask turtles [if random 100 < move_anyway [move-to one-of patches  with [not any? turtles-here]]]
 tick
end


to update-neighbors                                        ;; utility of potential relocation cell (the option) is updated, through the composition of its surrounding neighborhood
 ask patches [                                             ;; fraction calculated for the characteristics of interest when at least one turtle is in the neighborhood (x/n in Zhang)
    if any? (turtles-on neighbors) [                       ;; used to avoid bug if not any turtles on neighbors
     set fraction-blue (count (turtles-on neighbors) with [ color = 105 ] / (count (turtles-on neighbors) ))     ;; blue ethnicity agents (regardless value)
     set fraction-orange (count (turtles-on neighbors) with [ color = 27 ] / (count (turtles-on neighbors) ))    ;; orange ethnicity agents (regardless value)
     set fraction-tolerant (count (turtles-on neighbors) with [shape = "circle"] / (count (turtles-on neighbors) ))  ;; tolerant agents (regardless ethnicity)
                                                                           ;; utility calculated as weight of desired composition (Z in Zhang) * neighborhood characteristic (the fraction)
     set utility-blue (Z-similar-wanted * fraction-blue)
     set utility-orange (Z-similar-wanted * fraction-orange)
     set utility-tolerant (Z-similar-wanted * fraction-tolerant)
  ]
    if utility_neighborhood = "utility-blue" [set pcolor white * utility-blue]             ;; patches colored according to the updated degree of specific utility (one per time to be selected)
    if utility_neighborhood = "utility-orange" [set pcolor white * utility-orange]         ;; the whiter, the higher the utility
    if utility_neighborhood = "utility-tolerant" [set pcolor white * utility-tolerant]
    if utility_neighborhood = "nothing" [set pcolor black]
  ]
end

to choose            ;; choice of turtles between two options
  ask turtles [
    let alternative one-of patches with [not any? turtles-here]     ;; from original Schelling: the alternative is an empty cell
      ifelse shape = "square"                                       ;; the individual choice differs according to the value-orientation and composition of neighborhood
     [ifelse color = 105                                            ;; agents choose and move to the alternative if its payoff (beta of agent * utility option) is higher than current location
    [if random 100 < ((([utility-blue] of alternative - [utility-blue] of patch-here) * beta-ethnic) * 100) [move-to alternative]]
    [if random 100 < ((([utility-orange] of alternative - [utility-orange] of patch-here) * beta-ethnic) * 100) [move-to alternative]]
     ][
      if random 100 < ((([utility-tolerant] of alternative - [utility-tolerant] of patch-here) * beta-value) * 100) [move-to alternative]
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
57
13
268
46
density
density
20
99
70.0
1
1
%
HORIZONTAL

SLIDER
142
301
310
334
Z-similar-wanted
Z-similar-wanted
0
1
0.7
0.1
1
%
HORIZONTAL

SLIDER
58
50
268
83
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
67
576
243
609
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
181
1475
226
Ethnic Segregation (squares)
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"]
3
1
11

MONITOR
1297
231
1475
276
Value Segregation (squares)
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"]
3
1
11

MONITOR
1297
348
1474
393
Ethnic Segregation (circles)
mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"]
3
1
11

MONITOR
1297
397
1474
442
Value Segregation (circles)
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"]
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

MONITOR
1297
281
1475
326
Neighborhood Density (squares)
mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\"] / 8
3
1
11

MONITOR
1297
447
1474
492
Neighborhood Density (circles)
mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\"] / 8
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
"Value Seg." 1.0 0 -13840069 true "" "plot mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"Neighborhood D." 1.0 0 -9276814 true "" "plot mean [count (turtles-on neighbors)] of turtles / 8"

PLOT
895
182
1285
331
Ethnicity-oriented agents (squares)
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
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"]"
"Value Seg." 1.0 0 -13840069 true "" "plot mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"]"
"Neighborhood D." 1.0 0 -9276814 true "" "plot mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\"] / 8"

PLOT
896
342
1286
498
Value-oriented agents (circles)
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
"Ethnic Seg." 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"]"
"Value Seg." 1.0 0 -13840069 true "" "plot mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"]"
"Neighborhood D." 1.0 0 -9276814 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"] / 8"

MONITOR
900
506
1014
551
# Ethnicity 1 (blue)
count turtles with [color = 105]
17
1
11

MONITOR
1019
507
1145
552
# Ethnicity 2 (orange)
count turtles with [color = 27]
17
1
11

MONITOR
1151
506
1308
551
# ethnicity-oriented (squares)
count turtles with [first shape = \"s\"]
17
1
11

MONITOR
1313
506
1459
551
# value-oriented (circles)
count turtles with [first shape = \"c\"]
17
1
11

MONITOR
900
553
1014
598
# (blue squares)
count turtles with [color = 105 and first shape = \"s\"]
17
1
11

MONITOR
1152
553
1307
598
# (orange squares)
count turtles with [color = 27 and first shape = \"s\"]
17
1
11

MONITOR
1018
554
1144
599
# (blue circles)
count turtles with [color = 105 and first shape = \"c\"]
17
1
11

MONITOR
1313
552
1461
597
# (orange circles)
count turtles with [color = 27 and first shape = \"c\"]
17
1
11

SLIDER
58
88
270
121
fraction_tolerant
fraction_tolerant
0
100
51.0
1
1
%
HORIZONTAL

SLIDER
19
237
153
270
beta-value
beta-value
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
164
237
314
270
beta-ethnic
beta-ethnic
0
1
0.2
0.1
1
NIL
HORIZONTAL

CHOOSER
98
351
236
396
utility_neighborhood
utility_neighborhood
"nothing" "utility-blue" "utility-orange" "utility-tolerant"
3

PLOT
40
408
295
566
utility_neighborhood
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
"ut-blue" 1.0 0 -13345367 true "" "plot mean[utility-blue] of patches"
"ut-org" 1.0 0 -612749 true "" "plot mean [utility-orange] of patches"
"ut-val" 1.0 0 -10899396 true "" "plot mean [utility-tolerant] of patches"

TEXTBOX
144
197
182
215
Choice
11
0.0
1

TEXTBOX
31
311
135
329
utility neighborhood
11
0.0
1

TEXTBOX
38
220
145
238
beta value-oriented
11
0.0
1

TEXTBOX
181
218
300
236
beta ethnicity-oriented
11
0.0
1

TEXTBOX
158
279
176
297
x
11
0.0
1

TEXTBOX
250
589
278
607
noise
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model of **residential segregation** accompanies the paper _"How different homophily preferences mitigate and spur ethnic and value segregation"_

This is an extension of Thomas Schelling's model of segregation. In the original model, agents follow a homophily behavior defining similarity based on the exclusive category of ethnicity. In multicultural contexts other criteria might be relevant to define similarity, namely tolerance towards diversity. In our extension, we add value-oriented agents to ethnicity-oriented agents and observe consequences on ethnic segregation, value segregation and population density in neighborhood.

## HOW IT WORKS

The population is equally split in ethnicity-oriented agents and value-oriented agents. Both types of agents relocate in a neighborhood as long as its composition reflects the desired fraction of similar agents, but they define similarity based on different criteria. Ethnicity-oriented agents define similarity based on  shared ethnicity, value-oriented agents on shared values, here assumed as value of ethnic tolerance. The simulation stops when all agents are happy with their relocation.

### Static state variables of agents:

* **Ethnicity** (color tag): Ethnicity 1 (blue) / Ethnicity 2 (orange)

* **Value orientation** (shape tag): ethnicity-oriented (square) / value-oriented (circle)

### Behavior of agents:

All agents aim at living in a neighborhood that matches the desired fraction of similar ones and relocate otherwise. The goal of agents is the same, but the definition of similarity differs according to their value-orientation:

* Ethnicity-oriented agents (squares) consider as similar those agents sharing the same ethnicity (color), regardless of their value-orientation. 

* Value-oriented agents (circles) consider as similar only agents sharing their value-orientation (shape), regardless of their ethnicity.


## HOW TO USE IT

Setup Version, Initial Conditions and Global Parameters. Then press *setup* and *GO*
Global Parameters can be updated during the simulation.

### Version:
* Extension: split of the population in value-oriented agents and ethnicity-oriented agents
* Original_Schelling: original Schelling, only ethnicity-oriented agents. Relative group size = equal sizes

### Initial conditions: 
* *density* → density society: probability of an agent to appear on a cell
* *fraction_majority* → relative group size: ratio Ethnicity 1 (blue) / Ethnicity 2 (orange)

### Global parameters:
* *ethnic_homophily* → ethnic homophily threshold: 
for each ethnicity-oriented agent, desired fraction of agents with same ethnicity in Moore neighborhood
* *value_homophily* → value homophily threshold:
for each value-oriented agent, desired fraction of agents with same value orientation in Moore neighborhood
* *move_anyway* → robustness check: agents move randomly

### Example Configuration:
* Select buttons for initial conditions and homophily thresholds.
Do not forget to press *setup* and *GO*

## THINGS TO NICE

In the plots for *All agents* and specifically for *ethnicity-oriented agents (square)* and *value-oriented agents (circles)*:

* Ethnic segregation: mean fraction of agents in the neighborhood with the same ethnicity (color tag)
* Value segregation: mean fraction of agents  in the neighborhood with the same value (shape tag)
* Neighborhood density: mean number of agents in the neighborhood
* Unhappy: fraction of unhappy agents relocating / number agents of the category

In *Tools → BehaviorSpace*, the experiments that generate our datasets are available.

## REFERENCES

**On Schelling's model**:
Schelling, T. C. (1969). Models of segregation. The American Economic Review, 59(2), 488-493.

**NetLogo version of Schelling's model**:
Wilensky, U. (1997). NetLogo Segregation model. http://ccl.northwestern.edu/netlogo/models/Segregation. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## ACKNOWLEDGEMENTS

This project has received funding from the European Union's Horizon 2020 research and innovation programme under the Marie Skłodowska-Curie grant agreement No 713639”
Rocco Paolillo benefitted from the grant above.
Jan Lorenz work benefitted from a grant from the German Research Foundation DFG "Opinion Dynamics and Collective Decisions" LO2024
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
<experiments>
  <experiment name="Extension" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count turtles</metric>
    <metric>count turtles with [happy? = false]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 105 and first shape  =  "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 105 and first shape  =  "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 27 and first shape  =  "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 27 and first shape  =  "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 105 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 105 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 27 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 27 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [first shape = "c"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 105 and first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 27 and first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 105 and first shape = "c"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 27 and first shape = "c"] / 8</metric>
    <enumeratedValueSet variable="Version">
      <value value="&quot;Extension&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="fraction_majority" first="50" step="10" last="90"/>
    <steppedValueSet variable="value_homophily" first="0" step="10" last="100"/>
    <steppedValueSet variable="ethnic_homophily" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="move_anyway">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Original_Schelling" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count turtles</metric>
    <metric>count turtles with [happy? = false]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 105 and first shape  =  "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 105 and first shape  =  "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 27 and first shape  =  "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1  and color = 27 and first shape  =  "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 105 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 105 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 27 and first shape = "s"]</metric>
    <metric>mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = 27 and first shape = "c"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [first shape = "c"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 105 and first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 27 and first shape = "s"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 105 and first shape = "c"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color  = 27 and first shape = "c"] / 8</metric>
    <enumeratedValueSet variable="Version">
      <value value="&quot;Original_Schelling&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="fraction_majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="value_homophily">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ethnic_homophily" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="move_anyway">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
