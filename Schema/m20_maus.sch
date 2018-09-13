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

// Mausoleum wind dousing torch
schema m20mausdous
archetype AMB_M20
volume -1
mbreath1

// Mausoleum puzzle sound 1
schema m20mauspuz1
archetype AMB_M20
volume -1250
fade 500
delay 500
mono_loop 1000 3000
airtone3

// Mausoleum puzzle sound 2
schema m20mauspuz2
archetype AMB_M20
volume -1000
fade 500
delay 500
mono_loop 1000 3000
airtone2

// Mausoleum puzzle sound 3
schema m20mauspuz3
archetype AMB_M20
volume -750
fade 500
delay 500
mono_loop 1000 3000
airtone1

// Mausoleum puzzle sound 4
schema m20mauspuz4
archetype AMB_M20
volume -500
fade 500
delay 500
mono_loop 1000 3000
airtone6

// Mausoleum puzzle sound 5
schema m20mauspuz5
archetype AMB_M20
volume -250
fade 500
delay 500
mono_loop 1000 3000
airtone4

// Mausoleum puzzle sound 6
schema m20mauspuz6
archetype AMB_M20
volume -1
fade 500
delay 500
mono_loop 1000 3000
airtone5

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
