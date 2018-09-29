// Mausoleum door is locked
schema doormaus_locked
archetype DOORS
hwoosto3

// Mausoleum ambience 1 (room tone)
schema m20maustone
archetype AMB_M20
volume -500
mono_loop 0 0
subson1

// Mausoleum spooky torch dousing
schema m20mausdous
archetype AMB_M20
volume -500
squeaks1

// Mausoleum wind ambience
schema m20mauswind
archetype AMB_M20
volume -2000
mono_loop 5000 10000
no_repeat
wind1 wind3 wind4

// Mausoleum water ambience
schema m20mauswater
archetype AMB_M20
volume -1500
mono_loop 400 400
no_repeat
drip1 drip2 drip3

// Mausoleum puzzle sound 1
schema m20mauspuz1
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 2
schema m20mauspuz2
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 3
schema m20mauspuz3
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 4
schema m20mauspuz4
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 5
schema m20mauspuz5
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 6
schema m20mauspuz6
archetype AMB_M20
volume -750
mono_loop 0 0
delay 500
bridge1

// Mausoleum puzzle sound 7
schema m20mauspuz7
archetype AMB_M20
volume -1
delay 3250
whgasp

// Catacombs ambience 1 (room tone)
schema m20catatone
archetype AMB_M20
volume -1000
mono_loop 0 0
cavetone

// Catacombs ambience 2 (voices)
schema m20catavoice
archetype AMB_M20
volume -500
mono_loop 10000 20000
delay 5000
no_repeat
pan_range 3000
mgbab1 mgbab2 mgbab3 mgbab4 mgbab5

// Catacombs ambience 3 (nervous loop)
schema m20cataloop1
archetype AMB_M20
volume -1000
mono_loop 0 0
humfire

// Catacombs ambience 4 (tension loop)
schema m20cataloop2
archetype AMB_M20
volume -1000
mono_loop 0 0
loloop2

// Catacombs ambience 5 (bells)
schema m20catabells
archetype AMB_M20
volume -1500
mono_loop 1000 3000
no_repeat
bells1 bells2 bells3 bells4

// Catacombs bracelet sound
schema m20catabrace
archetype AMB_M20
volume -1
vbreath
