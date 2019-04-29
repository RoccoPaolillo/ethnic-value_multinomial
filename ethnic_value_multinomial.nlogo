globals [
 somme
  sum_prob
]

patches-own [
  utility
  expa
;  somme
  prob
]

turtles-own [
  beta-value
  beta-ethnic
  umin
  umax
  utility-myself

]

to  setup
 clear-all
;  set sum_prob 0
 ask patches [ if random 100 < density [sprout 1[set sum_prob 0
    ifelse random 100 < fraction_majority [        ;; ratio blue/orange is drawn (relative ethnic group size)
      set color 105
      ifelse random 100 < tolerant_majority [      ;; ratio value-oriented / ethnicity-oriented is drawn for majority group blue (relative value group size)
        set shape "circle"]
        [set shape "square"]
    ][
      set color 27
    ifelse random 100 < tolerant_minority [       ;; ratio value-oriented / ethnicity-oriented is drawn for minority group orange (relative value group size)
        set shape "circle"]
        [set shape "square"]
    ]
    attribute-beta   ;; to attribute beta in the initialization (can be updated)
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
   ; set size 0.5
    attribute-beta
    let alternative one-of patches with [not any? turtles-here]
    let options (patch-set alternative patch-here)
;    let neighs (patch-set  one-of patches with [not any? patch-here] patch-here)  ;;  patch-set of available options, i.e. empty nodes and current node
;    let option one-of neighs                       ;; one individual node
    let beta-ethnic-myself beta-ethnic
    let beta-value-myself beta-value
    let shape-myself shape
    let color-myself color
    let r random-float 1.01
    let q 0

  ask patch-here [set pcolor black] ; testing movement

  ask options [                                                                                                                          ;; for each possible location, utility is calculated for
                                                                                                                                        ;; ethnic homophily (concentration agents same color) and
     set  utility ( ((count (turtles-on neighbors)  with [color = color-myself] / count turtles-on neighbors) * beta-ethnic-myself) +
       ((count (turtles-on neighbors)  with [shape = shape-myself] / count turtles-on neighbors) * beta-value-myself) )       ;; value homophily (concentration agents same shape)
                   ;; times the specific beta

      set expa exp utility                                   ;; exponential of the utility
   ;    set somme sum [expa] of options
    ;   set prob (expa / somme)     ;; probability for each node to be chosen
    ]

     set somme sum [expa] of options

     ask options [ set prob (expa / somme)]

     set sum_prob sum [prob] of options

    ifelse [prob] of patch-here > r [move-to patch-here ask patch-here [set pcolor red]][move-to alternative ask alternative [set pcolor yellow]]



    ; foreach sort [option] of neighs [                        ;; choice of agent
;      the-option -> ask the-option [                      ;; probabilities for each option ranked as p1, p1+p2
;        set q q + prob]
;      if q > r [move-to option]                           ;; move to option if probability > r
;    ]

 set umin min [utility] of options
 set umax max [utility] of options
 ifelse umax != umin [set utility-myself (([utility] of patch-here - umin)/(umax - umin) ) ][set utility-myself 0]  ;; utility of agent for each location; to avoid bug if umax - umin = 0 (or beta = 0)

  ]

end

to attribute-beta

  ifelse random 100 < check_noise [
    move-to one-of patches with [not any?  turtles-here]            ;; noise: agents move to an empty cell
  ][
    ifelse color = 105 [
      ifelse shape = "square" [
        set beta-value value-square-blue
        set beta-ethnic ethnic-square-blue
      ][
        set beta-value value-circle-blue
        set beta-ethnic ethnic-circle-blue
      ]
    ][
      ifelse shape = "square" [
        set beta-value value-square-orange
        set beta-ethnic ethnic-square-orange
      ][
        set beta-value value-circle-orange
        set beta-ethnic ethnic-circle-orange
      ]
    ]
  ]

end

@#$#@#$#@
GRAPHICS-WINDOW
350
11
729
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
1
1
1
ticks
30.0

BUTTON
484
402
547
435
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
559
401
614
434
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
106
69
278
102
fraction_majority
fraction_majority
50
100
83.0
1
1
NIL
HORIZONTAL

SLIDER
106
110
278
143
tolerant_majority
tolerant_majority
50
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
106
33
278
66
density
density
50
99
93.0
1
1
NIL
HORIZONTAL

PLOT
737
12
976
162
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles"

SLIDER
59
420
197
453
value-square-blue
value-square-blue
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
55
271
189
304
ethnic-square-blue
ethnic-square-blue
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
57
457
197
490
value-circle-blue
value-circle-blue
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
56
307
190
340
ethnic-circle-blue
ethnic-circle-blue
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
208
421
348
454
value-square-orange
value-square-orange
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
203
271
346
304
ethnic-square-orange
ethnic-square-orange
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
207
458
348
491
value-circle-orange
value-circle-orange
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
202
308
346
341
ethnic-circle-orange
ethnic-circle-orange
0
100
17.0
1
1
NIL
HORIZONTAL

TEXTBOX
106
249
140
267
BLUE
11
0.0
1

TEXTBOX
253
399
305
417
ORANGE
11
0.0
1

TEXTBOX
162
225
239
243
BETA-ETHNIC
10
0.0
1

TEXTBOX
173
383
241
401
BETA-VALUE
11
0.0
1

MONITOR
476
447
574
492
% circle_blue
count turtles with [color = 105 and shape = \"circle\"] / count turtles with [color = 105] * 100
2
1
11

MONITOR
581
446
696
491
% circle_orange
count turtles with [color = 27 and shape = \"circle\"] / count turtles with [color = 27] * 100
1
1
11

MONITOR
477
497
575
542
% square_blue
count turtles with [color = 105 and shape = \"square\"] / count turtles with [color = 105] * 100
1
1
11

MONITOR
582
496
695
541
% square_orange
count turtles with [color = 27 and shape = \"square\"] / count turtles with [color = 27] * 100
1
1
11

MONITOR
431
547
547
592
% circle_population
count turtles with [shape = \"circle\"] / count turtles * 100
1
1
11

MONITOR
554
548
671
593
% square_population
count turtles with [shape = \"square\"] / count turtles * 100
1
1
11

SLIDER
106
146
278
179
tolerant_minority
tolerant_minority
50
100
50.0
1
1
NIL
HORIZONTAL

TEXTBOX
291
122
321
140
blue
11
0.0
1

TEXTBOX
287
159
323
177
orange
11
0.0
1

PLOT
742
182
1103
381
square-blue
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [shape = \"square\" and color = 105]"
"square-blue-neigh" 1.0 0 -13345367 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"circle-blue-neigh" 1.0 0 -14835848 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"square-orange-neigh" 1.0 0 -955883 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"circle-orange-neigh" 1.0 0 -5207188 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"

MONITOR
389
448
470
493
% blue
(count turtles with [color = 105] / count turtles) * 100
2
1
11

MONITOR
390
499
469
544
% orange
(count turtles with [color = 27] / count turtles) * 100
2
1
11

TEXTBOX
5
284
49
302
SQUARE
10
0.0
1

TEXTBOX
6
318
50
336
CIRCLE
10
0.0
1

TEXTBOX
113
400
145
418
BLUE
11
0.0
1

TEXTBOX
254
245
310
263
ORANGE
11
0.0
1

TEXTBOX
11
430
53
448
SQUARE
10
0.0
1

TEXTBOX
10
470
46
488
CIRCLE
10
0.0
1

SLIDER
112
545
284
578
check_noise
check_noise
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
237
225
277
243
tag color
9
0.0
1

TEXTBOX
242
384
295
402
tag shape
9
0.0
1

PLOT
1108
182
1473
380
circle-blue
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [shape = \"circle\" and color = 105]"
"square-blue-neigh" 1.0 0 -13345367 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"
"circle-blue-neigh" 1.0 0 -14835848 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"
"square-orange-neigh" 1.0 0 -955883 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"
"circle-orange-neigh" 1.0 0 -5207188 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 105]"

PLOT
743
385
1106
576
square-orange
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [shape = \"square\" and color = 27]"
"square-blue-neigh" 1.0 0 -13345367 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"circle-blue-neigh" 1.0 0 -14835848 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"square-orange-neigh" 1.0 0 -955883 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"
"circle-orange-neigh" 1.0 0 -5207188 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 27]"

PLOT
1111
383
1474
574
circle-orange
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [shape = \"circle\" and color = 27]"
"square-blue-neigh" 1.0 0 -13345367 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"
"circle-blue-neigh" 1.0 0 -14835848 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"
"square-orange-neigh" 1.0 0 -955883 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"
"circle-orange-neigh" 1.0 0 -5207188 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = 27]"

PLOT
985
11
1244
161
blue
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 105]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 105]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [color = 105]"

PLOT
1251
10
1498
160
orange
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 27]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = 27]"
"utility" 1.0 0 -16777216 true "" "plot mean [utility-myself] of turtles with [color = 27]"

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
