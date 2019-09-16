globals [ percent-similar-eth mean-dist-neigh percent-similar-val]

patches-own [
  uti-eth
  uti-val
]

turtles-own [
  ethnicity
  eth-weight
  val-weight
  test-weight
 parameter-eth
  parameter-val
similar-ethnics
 diff_eth
 diff_val
  total-neighbors
proba
  ethnic-utility
  value-utility
  diff_e
  diff_v
  dist-mean-neigh
  similar-weight
]

to setup
  clear-all
  ask patches [set pcolor white
    if random 100 < density [sprout 1 [
      attribute-preferences
      set shape "square"
      ifelse random 100 < fraction_blue                 ; ratio locals (blue) / minority (orange). Used variable "ethnicity" for ethnic concentration and avoid problems with visualization
      [set ethnicity "local"
        set color  scale-color blue eth-weight 2 -0.5    ; shades given by ethnic weight (the darker, the more ethnic weight influences the choice)
      ][
        set ethnicity "minority"
        set color scale-color orange eth-weight 2 -0.5
      ]

      ]
    ]
  ]
 update-turtles
 update-globals
  reset-ticks
end

to go
  update-turtles     ; attributes and weights of turtles
  move-turtles       ; relocation decision of turtles
  update-globals     ; global reportes
tick
end



to attribute-preferences                                         ; attribute weights (beta how important is the characteristic of neighborhood) for relocation decision
  let x random-gamma alpha 1
  let y random-gamma beta 1
  set eth-weight (x / (x + y))                                   ; ethnic weight derived from beta distribution
  if discrete-weight [set eth-weight precision eth-weight 1]     ; this in case weights must be discrete and not continuous, not necessary
  set val-weight (1 - eth-weight)                                ; value weight calculated
  set test-weight (eth-weight + val-weight)                      ; just to check ethnic weight + value weight sum to 1
end


to move-turtles                                                    ; choice for each turtle
  ask  turtles [

   let ethnicity-myself ethnicity
   let alternative one-of patches with [not any? turtles-here]
   let my_weight eth-weight
   let options (patch-set alternative patch-here)              ; set of alternatives for each turtle as local procedure for current agent. The set of choice includes current patch and one random empty patch

    ask options [                   ; for each of two alternatives value utility and ethnic utility is calculated (see below report)

      let xe count (turtles-on neighbors) with [ethnicity = ethnicity-myself]    ; number of similar ethnics in neighborhood (Moore 8 neighborhood)
      let xv count (turtles-on neighbors) with [  abs (eth-weight - my_weight) <= weight_distance]  ; number of value similars in the neighborhood.
                                                                                                    ; Value similars are those whose ethnic weight (importance of ethnic characteristic in choice relocation)
                                                                                                    ; falls  into the agent's interval.
      let n count (turtles-on neighbors)                                         ; total number turtles in neighborhood (Moore 8 neighborhood)

      set uti-eth utility-eth xe n           ; ethnic utility is calculated (proportion of similar ethnics, see below report for function)


     set uti-val utility-val xv n
    ]


    set diff_eth ([uti-eth] of alternative - [uti-eth] of patch-here)                     ; difference ethnic utility between current location and alternative position
    set diff_val ([uti-val] of alternative - [uti-val] of patch-here)                     ; difference value utility between current location and alternative position

    set proba (1 / (1 + exp((-(parameter-eth) * diff_eth) + (-(parameter-val) * diff_val) )))  ; probability to relocate to alternative location is computed. It includes random utility
                                                                                               ; in a logistic function 1/1+exp((-beta_e(Diff_Ue)) + (-betav(Diff_Uv))).
                                                                                               ; Probability is 0.5 for parameter-eth/parameter-val equal 0; increases according to the relative best option
                                                                                               ; if parameter-eth/parameter-val approaches to infinite.

    if random-float 1 < proba [move-to alternative]     ; final decision to relocate: if probability calculated as above with logistic function is higher than random-float number [0,1], then the agent relocates

  ]


end


to-report utility-eth [a b]                                                    ; ethnic utility:  this code allows for implementing single peaked function and threshold function.
                                                                               ; utility is 1 at the ideal concentration (i_e), M[0,1]: linearly decreasing slope at right (higher than) ideal concentration
  report ( ifelse-value (b = 0) [ifelse-value (i_e = 0) [1][0]]                ; S[0,1]: linearly increasing slope at left (less than) ideal concentration.
    [ifelse-value (a = (b * i_e)) [1]                                          ; combined b=0 (total num agents in neighborhood), i_e = 0 (desired concentration) and ifelse define utility when no agent is there
      [ifelse-value (a < (b * i_e))                                            ; e.g. the agent wants no one co-ethnic in the neighborhood (i_e = 0), then with no one agent (b=0), utility is 1.
        [ precision ((a / (b * i_e) ) * S) 3                                   ; if i_e != 0, then b=0 will score utility according to the distance with the ideal point.
        ][ precision ( M + ((1 -  (a / b)) * (1 - M)) / (1 - i_e)) 3 ]         ; I thought this better than score utility = 0 a priori
      ]                                                                        ; (please see the R-code for checking function and results)
    ]
)
end

to-report utility-val [c d]                                                      ; value utility: c represents absolute difference between the agent ethnic weight and the average ethnic weight of turtles on
                                                                               ; neighborhood. It replicates as threshold function or decreasing utility
  report ( ifelse-value (d = 0) [ifelse-value (i_v = 0) [1][0]]                ; S[0,1]: linearly increasing slope at left (less than) ideal concentration.
    [ifelse-value (c = (d * i_v)) [1]                                          ; combined b=0 (total num agents in neighborhood), i_e = 0 (desired concentration) and ifelse define utility when no agent is there
      [ifelse-value (c < (d * i_v))                                            ; e.g. the agent wants no one co-ethnic in the neighborhood (i_e = 0), then with no one agent (b=0), utility is 1.
        [ precision ((c / (d * i_v) ) * S_v) 3                                   ; if i_e != 0, then b=0 will score utility according to the distance with the ideal point.
        ][ precision ( M_v + ((1 -  (c / d)) * (1 - M_v)) / (1 - i_v)) 3 ]         ; I thought this better than score utility = 0 a priori
      ]                                                                        ; (see the R-code for checking function and results)
    ]
)                                                                           ; (please see the R-code for checking function and results)
end


to update-turtles                           ; updates of preferences of turtles

  ask turtles[
; let value-neigh (turtle-set self turtles-on neighbors)
let my_weight eth-weight
    set parameter-eth  (k * eth-weight)      ; ethnic parameter (beta in random utility models: how important ethnic utility is to the probability to relocate)
    set parameter-val  (k * val-weight)      ; value parameter (beta in random utility mode: how important the value utility is to probability to relocate)
                                                  ; both are calculated from constant k (slider) times ethnic-weight and value-weight.

    set similar-ethnics (count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself])                              ; these are just to have reporters to check in the simulation
    set similar-weight (count (turtles-on neighbors) with [abs (eth-weight - my_weight) <= weight_distance])
    set total-neighbors (count turtles-on neighbors)
    ifelse any? (turtles-on neighbors)
    [set dist-mean-neigh (abs ((mean [eth-weight] of turtles-on neighbors) - eth-weight))]
    [set dist-mean-neigh 0]
    set ethnic-utility [uti-eth] of patch-here
    set value-utility  [uti-val]  of patch-here
    set diff_e diff_eth
    set diff_v diff_val

  ]
end

to update-globals

  let tot-ethnics sum [ similar-ethnics ] of turtles               ; reporters for emerging properties: ethnic segregation as Schelling; mean distance between agent's ethnic weight and average of ethnic weights in the neighborhood
  let tot-weight sum [ similar-weight ] of turtles
 let tot-neighbors sum [ total-neighbors ] of turtles
  set percent-similar-val (tot-weight / tot-neighbors) * 100
  set percent-similar-eth (tot-ethnics / tot-neighbors) * 100
  set mean-dist-neigh mean [dist-mean-neigh] of turtles
end
@#$#@#$#@
GRAPHICS-WINDOW
206
12
710
517
-1
-1
9.73
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
0
0
1
ticks
30.0

SLIDER
79
10
200
43
density
density
0
99
85.0
1
1
NIL
HORIZONTAL

SLIDER
78
49
200
82
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
11
139
181
172
alpha
alpha
0.1
8
4.3
0.1
1
NIL
HORIZONTAL

SLIDER
10
175
182
208
beta
beta
0.1
8
3.2
0.1
1
NIL
HORIZONTAL

BUTTON
406
527
469
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

PLOT
728
26
987
176
weight-choice-population
NIL
NIL
0.0
1.0
0.0
10.0
true
true
"" ""
PENS
"eth-weight" 1.0 1 -2674135 true "" "set-histogram-num-bars 100\nhistogram [eth-weight] of turtles"
"val-weight" 1.0 1 -16777216 true "" "set-histogram-num-bars 100\nhistogram [val-weight] of turtles"

SLIDER
7
286
181
319
i_e
i_e
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
18
494
188
527
i_v
i_v
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
61
366
190
399
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
60
328
190
361
S
S
0
1
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
730
521
850
566
%_sim_ethnic
percent-similar-eth
3
1
11

MONITOR
1102
25
1235
70
mean-parameter-ethnic
mean [parameter-eth] of turtles
3
1
11

MONITOR
1103
76
1237
121
mean-parameter-value
mean [parameter-val] of turtles
3
1
11

SLIDER
10
213
182
246
k
k
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
481
528
544
561
NIL
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

SWITCH
578
527
719
560
discrete-weight
discrete-weight
1
1
-1000

PLOT
729
371
991
515
similar-ethnics
NIL
NIL
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"%_sim_eth" 1.0 0 -2674135 true "" "plot percent-similar-eth"
"%_sim_val" 1.0 0 -16777216 true "" "plot percent-similar-val"

PLOT
999
370
1256
514
ethnic-weight-distance
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
"mean dist" 1.0 0 -16777216 true "" "plot mean-dist-neigh"

MONITOR
996
25
1097
70
mean-eth-weight
mean [eth-weight] of turtles
3
1
11

MONITOR
998
77
1101
122
mean-value-weight
mean [val-weight] of turtles
3
1
11

MONITOR
1001
519
1113
564
eth_weight_neigh
mean-dist-neigh
3
1
11

TEXTBOX
7
16
69
51
population parameters
11
0.0
1

MONITOR
995
132
1076
177
prop_eth>val
count turtles with [eth-weight > val-weight] / count turtles
2
1
11

MONITOR
1160
130
1237
175
prop_val>eth
count turtles with [val-weight > eth-weight] / count turtles
2
1
11

MONITOR
1079
131
1157
176
prop_eth=val
count turtles with [eth-weight = val-weight] / count turtles
2
1
11

MONITOR
1247
26
1360
71
sd_parameter-eth
standard-deviation [parameter-eth] of turtles
2
1
11

PLOT
727
233
982
362
utility-current
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
"ethnic" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles"
"value" 1.0 0 -16777216 true "" "plot mean [value-utility] of turtles"

PLOT
998
233
1251
360
alternative - current
NIL
NIL
0.0
10.0
-1.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -2674135 true "" "plot mean [diff_e] of turtles"
"value" 1.0 0 -16777216 true "" "plot mean [diff_v] of turtles"

PLOT
1262
234
1499
362
prob_move_alternative
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
"mean" 1.0 0 -16777216 true "" "plot mean [proba] of turtles"

TEXTBOX
15
90
185
133
beta-distribution ethnic weights\nMultiply by k for final value/ethnic parameter. k = 0 tot. random
11
0.0
1

TEXTBOX
45
252
158
270
Ethnic preference
12
0.0
1

TEXTBOX
35
269
157
287
ethnic-similar threshold
11
0.0
1

TEXTBOX
11
334
46
361
left i_e slope
11
0.0
1

TEXTBOX
9
371
52
397
right i_e slope
11
0.0
1

TEXTBOX
43
406
164
424
Ethnic preference
12
0.0
1

SLIDER
14
440
186
473
weight_distance
weight_distance
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
64
534
193
567
S_v
S_v
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
65
571
193
604
M_v
M_v
0
1
0.3
0.1
1
NIL
HORIZONTAL

TEXTBOX
41
478
173
496
value-similar threshold
11
0.0
1

TEXTBOX
26
424
176
442
interval ethnic weight similarity
11
0.0
1

TEXTBOX
15
537
51
567
left i_v slope
11
0.0
1

TEXTBOX
13
572
55
601
right i_v slope
11
0.0
1

TEXTBOX
739
184
982
217
the darker the agent, the more ethnic utility is important than value utility
11
0.0
1

TEXTBOX
218
537
390
592
S=0,M=1: threshold\nS=1: single-peaked function. M regulates utility above threshold\nSame for S_v and M_v
11
0.0
1

MONITOR
1247
81
1358
126
sd_parameter-val
standard-deviation [parameter-val] of turtles
2
1
11

@#$#@#$#@
## WHAT IS IT?

The model introduces a beta distribution of ethnic weights and value weights and compare different functional forms for ethnic preferences and value preference (threshold vs single-peaked function).

Agents have fixed preferences for the desired proportion of ethnic concentration and value concentration, the latter being conceptualized as the distance between ethnic weights of agents.

The probability of relocation between current option and alternative option within random utility is modeled as binary logit model with logistic function 1/1+exp((-beta_e*(diff_Ue)) + (-beta_v*(diff_Uv))) instead of conditional logit and roulette wheel (exp(beta*U_e + beta*U_v))/sum(exp(beta*U_e + beta*U_v)) for each option as in the old ethnic_value_multinomial. In test_utility they are compared.

Blue agents: locals
Orange agents: minority
Brightness of agents: ratio between ethnic weight and value weight: the darker is the agent, the more ethnic weight is important in relocation decision; the brighter the agent, the more value weight is important.

Parameter for importance of ethnic utility = eth-weight * k
Parameter for importance of value utility = val-weight * k

eth-weight [0,1] from beta distribution / val-weight = 1 - eth-weight
eth-weight and val-weight vary among agents according to beta distribution
k = 0: totally random choice; k=inf the best option according to utility is taken.
The distribution among agents of final ethnic parameter and value parameter will be the same.

## HOW IT WORKS

Ethnic composition: a proportion as in Schelling, with similarity based on shared ethnicity
Value composition: a proportion as in Schelling, with value similarity assigned if the ethnic weight of other agents falls into the desired distance of the agent.

At each step, turtles compare the current position (patch) and one alternative position (an empty patch). For both of them ethnic utility and value utility is calculated. The probability is calculated for each agent to relocate to the alternative location according to the logistic function. 
P = 0: the agent stays in his current node
P = 1: the agent moves to the alternative node

The determinism of the choice is based on ethnic weights and value weights of the agents derived by beta distribution (times constant K)

## HOW TO USE IT

- Density: density of population
- Fraction_blue: ratio blue/orange
- alpha and beta: distribution of ethnic weights from beta distribution from 0 to 1. Value weights are calculated as 1-ethnic weight
- i_e: ideal proportion of similars of the own ethnic group agents desire in a neighgborhood
- weight_distance: the necessary distance to consider an agent as value similar depending on their ethnic weight. Only agents who follow within the interval are considered similar in the computation of value utility
- i_v: ideal proportion of similar agents considered as value similar
- S and M: to model the functional form for ethnic utility (S: steepness left ideal point [0,1] lineary increasing, M steepness right ideal point [0,1] linearly decreasing):
	- S=0,M=1: Schelling's threshold function
	- S=1,M=0: Symmetic single-peaked function
- S_v: regulates the steepness (decreasing function) of value utility:
	- S=0,M=1: Schelling's threshold function
	- S=1,M=0: Symmetic single-peaked function
- k: a constant to calculate the final parameter for ethnic composition and value composition (beta parameter of determinism in random utility models).  Considering eth-weight and val-weight span 0-1, while beta ranges from 0 (random choice) to infinite (best option), k * ethnic-weight / k * value-weight allows to keep the difference in agents' distribution and move ethnic/value weight from 0 to infinite. Example: if ethnic weight = 0.2 and value weight = 0.8,
with k = 0 -> parameter weight = 0, parameter value = 0 (total random choice)
with k = 1 -> parameter weight = 0.2, parameter value = 0.8,
with k = 10 -> parameter weight = 2, parameter value = 8,
with k = 100 -> parameter weight = 20, parameter value = 80

-Beta distribution:
	- ethnic-weight close to 1, value-weight close to 0, low heterogeneity: alpha = 8, beta = 0.1
	- bell curve: alpha = beta
	- ethnic-weight close to 0, value-weight close to 1, low heterogeneity: alpha = 0.1, beta = 8

## THINGS TO NOTICE

- Weight-choice-population: the beta distribution of ethnic-weights [0,1] for overall population (independent of ethnic membership). Value-weight for each agent 1-ethnic weight. The actual beta distribution is the red one (for ethnic weight).
Final parameter in relocation choice and random utility model:
	- Importance of ethnic composition: k * ethnic weight
	- Importance of value composition: k * value weight


- utility-current: mean ethnic and value utility of the current neighborhood of the agent
- current-alternative: mean ethnic and value difference between current patch and one alternative patch
- prob_move_alternative: mean probability to move to alternative patch

- Similar-ethnics: global ethnic segregation as in Schelling (% similars in current neighborhood)
- Ethnic-weight-distribution: population mean of the distance [ethnic weight of agent - average ethnic weight of current neighborhood]

Random utility model and weight of the relocation decision:
- k=0: choice totally random, the probability to relocate to alternative is 0.50, not matter the degree of utility
- increase  k = the probability depends on the best option, check with the plot for utility of current node and difference between alternative and current node
- difference alternative - current= 1: alternative is better, -1 alternative has the lowest utility

Stable patterns should rise when prob_move_alternative approximates to 0.

## EXTENDING THE MODEL

- Introducing the heterogeneity of preferences ethnic threshold and value threshold. Now it is only heterogeneity of random behavior, with agents varying on how important the value composition or the ethnic composition is (k=0 total random). Heterogeneity of ethnic preferences was done by Xie and Zhou (2009), we would include heterogeneity of the value composition, and the heterogeneity on what dimension is more important than the other and how they matter in a relocation choice. I think this would fit Hess (2018): people can vary both for their tastes and for their random behavior (k * eth-weight/k * val-weight now).

- Doubt on the definition of value-similarity, I think it should be based on an independent parameter which is not related to the ethnic weight or ethnic preferences.
Include a parameter of opinion/value [0,1], which gives how agents distribute along a dimension independent of ethnicity, might it be tolerance towards diversity, political orientation etc. And agents define similarity based on the distance within the distribution. Those defined as similar used in the calculation of value composition of the neighborhood. I think this would fit the ACS point of similarity as not twofold, exhaustive and recognizable, but now individually defined, continuous and inclusive across dimensions Schelling mentioned as ethnicity, gender etc. ACS conditions would be those of interval to define similarity close to 0 (extremely similar) and binary distribution intolerant or tolerant (plus beta = 1) in the population.

- The distribution of poeple along one dimension in the population and independent of ethnic/beta weights might be the dimension which interacts with the neighborhood characteristics when exploring data with conditional logit. Van Ham for instance used conditional logit on relocation probability (p = exp(beta * xe)/sum(exp(beta * xe) with ethnic composition of neighborhood as charactetistic of option and how the coefficient of regression varies according to socioeconomic status * ethnicity of participant as characteristic of the selector. A simpler scenario might be to have discrete groups (e.g. rich/poor, left-wing/right wing) and for each the ethnic/value weight distribution.


## CREDITS AND REFERENCES

Xie, Y., & Zhou, X. (2012). Modeling individual-level heterogeneity in racial residential segregation. Proceedings of the National Academy of Sciences, 109(29), 11646-11651.)
Hess, S., Daly, A., & Batley, R. (2018). Revisiting consistency with random utility maximisation: theory and implications for practical work. Theory and Decision, 84(2), 181-204.
Boschman, S., & Van Ham, M. (2015). Neighbourhood selection of non-Western ethnic minorities: testing the own-group effects hypothesis using a conditional logit model. Environment and Planning A, 47(5), 1155-1174.
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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10"/>
    <metric>count turtles</metric>
    <metric>count turtles with [diff_e &lt;= 0]</metric>
    <metric>count turtles with [diff_v &lt;= 0]</metric>
    <metric>mean [proba] of turtles</metric>
    <metric>mean [proba] of turtles with [diff_e &lt;= 0 and diff_v &lt;= 0]</metric>
    <metric>mean [ethnic-utility] of turtles</metric>
    <metric>mean [value-utility] of turtles</metric>
    <metric>mean [diff_e] of turtles</metric>
    <metric>mean [diff_v] of turtles</metric>
    <metric>count turtles with [ethnicity = "local"]</metric>
    <metric>count turtles  with [ethnicity = "minority"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles</metric>
    <metric>mean [dist-mean-neigh] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt;= median [eth-weight] of turtles]] of turtles</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles</metric>
    <metric>count turtles with [eth-weight &lt;= median [eth-weight] of turtles]</metric>
    <metric>count turtles with [diff_e &lt;= 0 and eth-weight &lt;= median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [diff_v &lt;= 0 and eth-weight &lt;= median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ eth-weight &lt;= median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles  with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [diff_e &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles  with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and diff_e &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [ethnicity = "local" and diff_v &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "local" and diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [ethnicity = "local" and  eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles  with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [ethnicity = "local" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and diff_e &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [ethnicity = "local" and diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "local" and  eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "local" and diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles  with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [ethnicity = "local" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "minority" and diff_e &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [ethnicity = "minority" and diff_v &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "minority" and diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [ethnicity = "minority" and  eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [ethnicity = "minority" and eth-weight &lt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>count turtles with [ethnicity = "minority" and diff_e &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>count turtles with [ethnicity = "minority" and diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "minority" and  eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [proba] of turtles with [ethnicity = "minority" and diff_e &lt;= 0 and diff_v &lt;= 0 and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [ethnic-utility] of turtles with  [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles ]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_e] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [diff_v] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &lt;= weight_distance]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &gt; [eth-weight] of myself]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [abs (eth-weight - [eth-weight] of myself) &gt; weight_distance and eth-weight &lt; [eth-weight] of myself]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [dist-mean-neigh] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &lt; median [eth-weight] of turtles]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <metric>mean [count (turtles-on neighbors) with [eth-weight &gt; median [eth-weight] of turtles]] of turtles with [ethnicity = "minority" and eth-weight &gt; median [eth-weight] of turtles]</metric>
    <enumeratedValueSet variable="weight_distance">
      <value value="0.5"/>
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S_v">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="0.1"/>
      <value value="8"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0.1"/>
      <value value="2"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_e">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M_v">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discrete-weight">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_v">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
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
