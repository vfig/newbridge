// MANOR - mounted burrick head
schema alaspoorburrick
archetype AMB_M20
no_repeat
volume -3000
bk1die_2


//The butler wakes up (this is to interrupt his snoring loop without an alert)
schema sv1wakeup
archetype AI_NONE
volume -500
sv1a0sn2
schema_voice normal1 1 nbwakeup

// The pond
schema m20pond
archetype AMB_M20
mono_loop 0 0
volume -1000
wtr__md3

schema m20frogs
archetype AMB_M20
mono_loop 0 0
volume -1000
forest4


// -------------------------- AMBIENCE ----------------------------

// 1. At mission start

// Manor 1 loop
schema m20man1loop
archetype AMB_M20
volume -1000
mono_loop 0 0
subson2

// 5. After hand-off/keeper intervention

// Manor 5 loop
schema m20man5loop
archetype AMB_M20
volume -2500
mono_loop 0 0
m13str

// Interior mood
schema m20manintmood
archetype AMB_M20
volume -1000
mono_loop 6280 6280
no_repeat
btrem1 btrem3 btrem5

// Interior tension
schema m20manintten
archetype AMB_M20
volume -2000
mono_loop 10000 20000
delay 8000
no_repeat
gr3 gr5 gr6 gr7 gr9
