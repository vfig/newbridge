// Clock tower gears
schema m20cityclock
archetype AMB_M20
volume -1000
gears2

// Canal water
schema m20canal
archetype AMB_M20
mono_loop 0 0
volume -1000
wtr__md4

// Fountain water
schema m20fountain
archetype AMB_M20
mono_loop 0 0
volume -1000
wtr__sm3

// The hanged man
schema m20cityrope
archetype AMB_M20
volume -1000
mono_loop 2000 2500
bowpull

// Mine softly arming
schema mine_arm_quiet
archetype AMB_M20
volume -1000
minearmg

// Got Argaux's puzzle wrong
schema m20argpuzfail
archetype AMB_M20
volume -1000
buzzer

// Shrine
schema m20shrine
archetype AMB_M20
volume -1000
mono_loop 500 500
no_repeat
singing1 singing2

// -------------------------- AMBIENCE ----------------------------

// 1. At mission start

// City streets 1 outdoor room tone
schema m20city1loop
archetype AMB_M20
volume -1000
mono_loop 0 0
lostcity

// City streets 1 outdoor ambience (crickets)
schema m20city1mood
archetype AMB_M20
volume -1500
mono_loop 0 0
cricket2

// City streets 1 tension (organ)
// At mission start.
schema m20city1ten
archetype AMB_M20
volume -1500
mono_loop 10000 20000
delay 8000
no_repeat
organ1
organ2

// 2. After not finding Argaux at the fountain, or after learning he's dead.

// City streets 2 tension (deep strings)
schema m20city2ten
archetype AMB_M20
volume -1000
mono_loop 8000 12000
no_repeat
pascal1
pascal2


// - Inside Argaux's place -

// Argaux's place indoor room tone
schema m20argloop
archetype AMB_M20
volume -1000
mono_loop 0 0
subson2

// Argaux's place indoor ambience
schema m20argmood
archetype AMB_M20
volume -1500
mono_loop 5000 5000
tonebend


// 3. After getting your objectives

// City streets 3 outdoor room tone
schema m20city3loop
archetype AMB_M20
volume -1500
mono_loop 0 0
abyss2

// City streets 3 outdoor ambience (crickets)
schema m20city3mood
archetype AMB_M20
volume -2000
mono_loop 0 0
cricket2

// City streets 3 tension (strings)
// At mission start.
schema m20city3ten
archetype AMB_M20
volume -2500
poly_loop 2 3000 10000
no_repeat
fb1 fb2 fb3 fb4


// 4. Going to the hand-off

// City streets 4 outdoor ambience (wind)
schema m20city4mood
archetype AMB_M20
volume -1500
mono_loop 1000 4000
wind1 wind2 wind3


// - Behind the fishmongers -

// Fishmongers indoor room tone
schema m20fishloop
archetype AMB_M20
volume -1000
mono_loop 0 0
subson2

// Fishmongers indoor ambience
schema m20fishmood
archetype AMB_M20
volume -750
mono_loop 5000 5000
tonebend


// 5. Mission complete, right? ... right?
schema m20city5loop
archetype AMB_M20
volume -1500
mono_loop 0 0
diffuse

schema m20city5ten
archetype AMB_M20
volume -2000
mono_loop 3000 10000
no_repeat
fb5 fb6 fb7


// 6. Keeper intervention

schema m20city6mood
archetype AMB_M20
volume -1000
mono_loop 1000 4000
wind1lo wind2lo wind3lo

schema m20city6ten
archetype AMB_M20
volume -1500
mono_loop 8000 12000
no_repeat
m04cat1b m04cat1c m04cat2b
