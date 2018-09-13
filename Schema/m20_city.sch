// Clock tower gears
schema m20cityclock
archetype AMB_M20
volume -1000
gears2


// City streets ambience 1 (room tone)
schema m20citytone
archetype AMB_M20
volume -3000
mono_loop 0 0
diffuse
// -- I don't much like this as a tone... it's got a recurrent 'tick' that's distracting

schema m20cityloop
archetype AMB_M20
volume -2000
mono_loop 30000 120000
fb1 fb2 fb3 fb4

//// Catacombs ambience 1 (room tone)
//schema m20catatone
//archetype AMB_M20
//volume -1000
//mono_loop 0 0
//cavetone
//
//// Catacombs ambience 2 (voices)
//schema m20catavoice
//archetype AMB_M20
//volume -1500
//mono_loop 10000 20000
//delay 5000
//no_repeat
//pan_range 3000
//mgbab1 mgbab2 mgbab3 mgbab4 mgbab5
//
//// Catacombs ambience 3 (nervous loop)
//schema m20cataloop1
//archetype AMB_M20
//volume -1000
//mono_loop 0 0
//humfire
//
//// Catacombs ambience 4 (tension loop)
//schema m20cataloop2
//archetype AMB_M20
//volume -1000
//mono_loop 0 0
//loloop2
