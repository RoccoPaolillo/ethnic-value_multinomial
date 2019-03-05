patches-own [
  utility
  expa
  prob
]

turtles-own [
  beta-value
  beta-ethnic
  move
]

to  setup
 clear-all
 ask patches [ if random 100 < density [sprout 1[
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

to update-turtles                    ;; procedure of agents is local, so that the evaluation of the neighborhood is assessed through the beta of the single agent called at each run
 ask turtles [                       ;; due to NetLogo language, as written here each agent runs the entire command, the next is then called
    attribute-beta                   ;; each agent evaluates possible alternatives (including patch-here) and decides where to relocate
    let neighs (patch-set  patches with [not any? turtles-here and any? turtles-on neighbors] patch-here)   ;; an array of all possible alternatives (patch-here and empty patches at each step) is calculated
    let option one-of neighs                                                            ;; which represent the discrete alternatives the agent can choose from. As in local variable and called by individual
    let beta-ethnic-myself beta-ethnic                                                  ;; agent at each run, the values and scopes of variables relate to that individual agents (its beta-ethnic and beta-value).
    let beta-value-myself beta-value                                                    ;; Once it has moved (or not), it will change the composition of the neighborhoods and vacant places for other agents.
    let shape-myself shape
    let color-myself color
    let r random-float 1.01
    let q 0

    ask neighs [                                                                   ;; utility of each alternative (patch) = composition of patch's neighborhood * individual beta. All possible alternatives execute
      ifelse shape-myself = "circle" [                                                                                                       ;; since value-orientation is a cross-category, and tolerant
        set  utility  (((count (turtles-on neighbors)  with [color = color-myself] / count turtles-on neighbors) * beta-ethnic-myself) +     ;; neighborhoods are those where circle (tolerant) agents relocate,
          ((count (turtles-on neighbors)  with [shape = shape-myself] / count turtles-on neighbors) * beta-value-myself))                    ;; the assessment of value-orientation of neighborhood is different if
      ][                                                                                                                                     ;; the caller agent is square ethnicity-oriented (!= shape (of myself))
        set  utility  (((count (turtles-on neighbors)  with [color = color-myself] / count turtles-on neighbors) * beta-ethnic-myself) +     ;; or circle value-oriented (= shape (of myself)).
          ((count (turtles-on neighbors)  with [shape != shape-myself] / count turtles-on neighbors) * beta-value-myself))                   ;; For ethnic composition it's the color of caller (= color (of myself))
      ]
      set expa exp utility                                 ;; exponential function of utility
      set prob ([expa] of self / (sum [expa] of neighs))   ;; the probability for each patch of the agentset is calculated as <exponential utility of option / sum of utility of all options (including denominator)
    ]

    foreach sort [option] of neighs [                         ;; this is to set the probability of agent to relocate to option (or don't move if it is patch-here: it just doesn't move).
      the-option -> ask the-option [                          ;; Option is each unit of the patch-set of alternatives, i.e. one single patch which has a probability associated
        set q q + prob]                                       ;; this to delineate the distribution p1+p2+p3... At p1 q equals 0, thus the only space is p1, at p2 it will be p1+p2, etc.
      ifelse q > r [move-to option set move 1][set move 0]    ;; if the probability associated with each option patch is higher than random number 0 to 1 (random-float 0.1+..) the agent moves to that patch
    ]                                                         ;; as all alternative patches are empty, and procedure run by one turtle, there is no conflict and the agent relocates. This means its previous
  ]                                                           ;; location is now available for other agents. Move 1-0 and ifelse (instead of if) just for the plot of agents not relocating, useless for behavior
end                                                           ;; agents continuously relocating means at each run one option is equal to the other and relocate constantly

to attribute-beta                                        ;; each agent is given a beta for the composition of neighborhood according to its characteristics.




  if beta-attributed-by = "value-orientation"[           ;; Beta are beta-ethnic for ethnic composition (agents with same color) - Beta-value for value composition (agents with circle color)
     ifelse random 100 < check_noise [set beta-ethnic 0 set beta-value 0][
    ifelse shape = "circle" [
      set beta-value value-circle                        ;; here beta is attributed according to valeu-orientation, regardless of ethnicity
      set beta-ethnic ethnic-circle
    ][
      set beta-value value-square
      set beta-ethnic ethnic-square
    ]
  ]
  ]

  if beta-attributed-by = "sub-group" [                 ;; here beta is attributed according to specific subgroups due to ethnicityXvalue-orientation
     ifelse random 100 < check_noise [set beta-ethnic 0 set beta-value 0] [
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
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
369
10
748
390
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
493
414
556
447
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
568
413
623
446
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
110
48
282
81
fraction_majority
fraction_majority
50
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
110
89
282
122
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
110
12
282
45
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
824
10
1121
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]"
"moving" 1.0 0 -16777216 true "" "plot count turtles with [move = 1] / count turtles"

SLIDER
58
537
196
570
value-square-blue
value-square-blue
0
100
24.0
1
1
NIL
HORIZONTAL

SLIDER
58
415
192
448
ethnic-square-blue
ethnic-square-blue
0
100
44.0
1
1
NIL
HORIZONTAL

SLIDER
56
574
196
607
value-circle-blue
value-circle-blue
0
100
26.0
1
1
NIL
HORIZONTAL

SLIDER
59
451
193
484
ethnic-circle-blue
ethnic-circle-blue
0
100
42.0
1
1
NIL
HORIZONTAL

SLIDER
207
538
347
571
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
206
415
349
448
ethnic-square-orange
ethnic-square-orange
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
206
575
347
608
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
205
452
349
485
ethnic-circle-orange
ethnic-circle-orange
0
100
50.0
1
1
NIL
HORIZONTAL

TEXTBOX
109
393
143
411
BLUE
11
0.0
1

TEXTBOX
252
516
304
534
ORANGE
11
0.0
1

TEXTBOX
168
380
245
398
BETA-ETHNIC
10
0.0
1

TEXTBOX
172
500
240
518
BETA-VALUE
11
0.0
1

CHOOSER
128
170
271
215
beta-attributed-by
beta-attributed-by
"value-orientation" "sub-group"
0

SLIDER
68
272
189
305
ethnic-square
ethnic-square
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
68
308
187
341
value-square
value-square
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
204
270
330
303
ethnic-circle
ethnic-circle
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
204
307
330
340
value-circle
value-circle
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
117
248
161
266
SQUARE
11
0.0
1

TEXTBOX
254
250
293
268
CIRCLE
11
0.0
1

TEXTBOX
152
228
274
246
VALUE-ORIENTATION
11
0.0
1

TEXTBOX
167
358
236
376
SUB-GROUP
12
0.0
1

MONITOR
459
460
557
505
% circle_blue
count turtles with [color = 105 and shape = \"circle\"] / count turtles with [color = 105] * 100
2
1
11

MONITOR
564
459
679
504
% circle_orange
count turtles with [color = 27 and shape = \"circle\"] / count turtles with [color = 27] * 100
1
1
11

MONITOR
460
510
558
555
% square_blue
count turtles with [color = 105 and shape = \"square\"] / count turtles with [color = 105] * 100
1
1
11

MONITOR
565
509
678
554
% square_orange
count turtles with [color = 27 and shape = \"square\"] / count turtles with [color = 27] * 100
1
1
11

MONITOR
687
460
803
505
% circle_population
count turtles with [shape = \"circle\"] / count turtles * 100
1
1
11

MONITOR
686
509
803
554
% square_population
count turtles with [shape = \"square\"] / count turtles * 100
1
1
11

SLIDER
110
125
282
158
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
295
101
325
119
blue
11
0.0
1

TEXTBOX
291
138
327
156
orange
11
0.0
1

PLOT
826
168
1064
318
square_blue
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
"moving" 1.0 0 -16777216 true "" "plot count turtles with [move = 1] / count turtles with [shape = \"square\" and color = 105]"

PLOT
1073
168
1312
318
circle_blue
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
"moving" 1.0 0 -16777216 true "" "plot count turtles with [move = 1] / count turtles with [shape = \"circle\" and color = 105]"

PLOT
827
323
1065
473
square_orange
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
"moving" 1.0 0 -16777216 true "" "plot count turtles with [move = 1] / count turtles with [shape = \"square\" and color = 27]  "

PLOT
1077
323
1314
473
circle_orange
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
"moving" 1.0 0 -16777216 true "" "plot count turtles with [move = 1] / count turtles with [shape = \"circle\" and color = 27]"

PLOT
824
479
1119
627
square_blue-type-agents
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
"square_blue" 1.0 0 -13345367 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"circle_blue" 1.0 0 -14835848 true "" "plot mean [count (turtles-on neighbors) with [color =  105 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"orange_square" 1.0 0 -6459832 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"square\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"
"orange_circle" 1.0 0 -612749 true "" "plot mean [count (turtles-on neighbors) with [color =  27 and shape = \"circle\"] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = 105]"

MONITOR
372
461
453
506
% blue
(count turtles with [color = 105] / count turtles) * 100
2
1
11

MONITOR
373
512
452
557
% orange
(count turtles with [color = 27] / count turtles) * 100
2
1
11

TEXTBOX
8
428
52
446
SQUARE
10
0.0
1

TEXTBOX
9
462
53
480
CIRCLE
10
0.0
1

TEXTBOX
112
517
144
535
BLUE
11
0.0
1

TEXTBOX
257
389
313
407
ORANGE
11
0.0
1

TEXTBOX
10
547
52
565
SQUARE
10
0.0
1

TEXTBOX
9
587
45
605
CIRCLE
10
0.0
1

SLIDER
481
569
653
602
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
6
284
61
302
BETA-ETHNIC
8
0.0
1

TEXTBOX
7
317
56
335
BETA-VALUE
8
0.0
1

@#$#@#$#@
## WHAT IS IT?

Inclusion of multinomial choice and random utility models in the EthnicValue segregation extension of Schelling "How different homophily preferences mitigate and spur ethnic and value segregation: Schelling's model extended”: https://github.com/RoccoPaolillo/EthnicValueSegregation

Multinomial choice models assume individual preferences for an option be the product of individual characteristics of chooser, characteristic of option, and a random term (McFadden, 1973, Zhang, 2004). Beta ß for each individual means how much a specific characteristic of the option is important to determine its utility. The bigger beta is (from 0 to infinite), the more determinant utility is in picking up the best choice, the lower the beta, the higher the random effect is in making a choice, which results random. As random utility, the way probability is calculated for each option (P = exp utility option /  sum exp all options), by including exponential function, allows for random term to be included. This implies that the choice  selected is  not necessarily the one with the highest utility.  

Here, the option is the node where to relocate, characteristics of interest are the ethnic composition and value composition of the neighborhood. In the ACS model, it was as if ethnicity-oriented only considered ethnic composition (same color), with high beta, and value-oriented value composition (agents with same shape = circle), according to the threshold version of Schelling's  model. Compared to the threshold version of Schelling's model, the concept of happy agent now is less relevant. An agent does not move because the concentration of similar ones does not match a fixed threshold. Neither they relocate randomly to another location. At each step, an agent makes a choice whether to relocate or not and to what option available, due to the combination of composition of neighborhood (as product of cascade effect through the simulation), corresponding beta and random utility. The observed phenomenon is still the level of emerged segregation, despite agents can move to other locations better satisfying the own desired preferences, still without a fixed benchmark of reference as in the threshold model, and despite the randomness of utility, with the best options not constantly chosen by agents. Frozen states are not expected as in the threshold model.


## HOW IT WORKS

Each agent is given a beta-ethnic for ethnic composition of the neighborhood (concentration of agents with same color) and beta-value for the concentration of tolerant agents (concentration of circle agents). Agents are divided into two ethnic groups and each group into ethnicity-oriented and value-oriented (the proportion to be set by observer). Beta-ethnic and beta-value are potentially independent of the value-orientation of the agent.

### Static state variables of agents:

* **Ethnicity** (color tag): Ethnicity 1 (blue) / Ethnicity 2 (orange)

* **Value Orientation** (shape tag): ethnicity-oriented intolerant (square) / value-oriented tolerant (circle)

* **Beta-ethnnic** to assess the ethnic composition of options (agents with similar color in potential neighborhood)

* **Beta-value** to assess the value composition of options (tolerant circle agents in potential neighborhood)

### Behavior of agents:

At each run, one agent calculates the utility of each option where they can relocate, which include their current node and all empty nodes. Utility of each node is based on both ethnic composition and value composition of their neighborhood modeled as Moore Distance (8 nodes), weighted by the corresponding beta. Utility for each potential node is calculated as the sum of:

* ethnic composition of the neighborhood of node option (agents with the same color) * beta-ethnic
* value composition of the neighborhood of node option (tolerant agents with shape circle) * beta-value

The probability for each node option to be chosen and the agent to relocate there follows a random utility model with the formula:

* exp utility of option / sum exp utility of all available options

where exponential function allows to include random term. This means that the option with maximal utility has the highest probability to be selected, but still this doesn't necessarily always happen and choice of some agents can be purely random.

If the option is picked up, the agent relocates to the node. If  the chosen option is its current patch, the agent results to not move. If it relocate, its patch becomes available for the next agent who runs the procedure.

## HOW TO USE IT

* density: density of the population (% number of patches with one agent in random initial condition). **Below 70% risk that there is not agent on neighborhood and simulation stops**
* fraction_majority: ratio ethnicity blue / ethnicity orange
* tolerant_majority: ratio value-oriented agents / ethnicity-oriented agents in the blue  ethnic group
* tolerant_minority: ratio value-oriented agents / ethnicity-oriented agents in the orange  ethnic group

**To hold ratio value-oriented / ethnicity-oriented at the population level, select fraction_majority and fraction_minority at the same level**

* beta-attributed-by: beta-ethnic and beta-value can be attributed by value-orientation (independent of ethnicity, as in the ACS paper) or by specific groups. Follow the notes tab in the interface.

Suggested use by **sub-group**, both for beta-ethnic (first row) and beta-value (second row):

* According to subgroup *ethnicity X value-orientation* (columns: ethnicity color; rows: value-orientation shape). Values of each subgroup are independent
* According to *ethnicity* independent on value-orientation: columns color must have the same value over the rows
* According to *value-orientation* independent on ethnicity: rows shape must have the same value over the columns

* check_noise: to test robustness: % of agents with beta-ethnic = 0 and beta-value = 0, increasing random term and always relocating



## THINGS TO NOTICE

* **Suggested** square_blue-type-agents: to show what types of agents (ethnictyXvalue-orientation) relocate in the neighborhood of the caller (here ethnicity-oriented of majority: blue square). I suggest to do the same for each group and have this as informative outputs.
* Ethnic segregation: agents in the neighborhood with same color
* Value segregation: agents in the neighborhood with same shape
* Moving: agents who relocate: the lower, the more agents are in a location which has higher utility (composition * beta) and lower probability to be left. Frozen states not reached

## THINGS TO TRY

### Initial conditions:

* density: suggested 99%. Below 70% risk to stop (no agents in neighborhood to calculate fraction)
* Ratio of majority over minority
* Ratio of value-oriented agents over ethnicity-oriented agents in each ethnic group

### Can be updated during the simulation run:

* Beta can be udpated during the simulation run
* Noise can be updated during the simulation run

## EXTENSIONS

Zhang (2004) makes further advancement by introducing a different utility calculation according to whether the minimum desired condition (there 50% neighborhood) is reached: as Z*fraction until 50% is reached, otherwise (2Z-M)+(M-Z)*fraction once the minimum condition is assured. Provided I have correctly implemented the random utility here, I think Zhang's extension can be implemented, including different calculation of utility under different conditions. The main point of the paper would still be to consider different and overlapping preferences in definition of utility

Beta-ethnic and Beta-value are here independent. A simpler solution might be to have them complementary, e.g. for each agent beta-value = 1 - beta-ethnic. This would mean they are complementary and opposite. As long as value-orientation is modeled as we did for tolerance in the ACS paper, I think it can work. Nevertheless, if value-orinetation is modeled as a second-degree category based on shared values, e.g. norms or political attitude, there is not need to consider them exclusive. I think both versions can be used, depending either on the theoretical assumption made in the paper (and I think this could better explore the ethnic boundary making relevant to Esser's)  or whether data show they are negatively correlated or underlying dimensions (e.g. factorial analysis). I think it can be discussed  later.

If the code works well, the usefulness I was looking for is that it works at the local level of the agent and it is flexible to whatever strategy is used to attribute beta to agents. So other dimensions could be included, e.g. socio-economic status which I am interested in since relevant considering literature in segregation and measures of immigrant integration and spatial assimilation.

Anyway I think this is the way, it better frames rational models at the conceptual level and connect with emprical data, i.e. running multinomial choice models in regression models, to do.

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
