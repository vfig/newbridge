// RITUAL celebration - APE1
schema ab1rcel
archetype AI_NONE
no_repeat
ab1atn_1 ab1atn_2 ab1atn_3 ab1atw_2 ab1atww1
schema_voice vape1 1 nbritcel

// RITUAL celebration - APE2
schema ab2rcel
archetype AI_NONE
no_repeat
ab2atn_1 ab2atn_2 ab2atn_3 ab2atw_2 ab2atww1 ab2atww2
schema_voice vape2 1 nbritcel

// RITUAL celebration - CRAYMAN
schema cr1rcel
archetype AI_NONE
no_repeat
CR1A3__1 CR1A3__2 CR1A3__3
schema_voice vcray 1 nbritcel

// RITUAL celebration - BUGBEAST
schema bb1rcel
archetype AI_NONE
no_repeat
bb1a3__1 bb1a3__2 bb1a3__3 bb1a3__4
schema_voice vbug 1 nbritcel

// Ritual marker stone
schema nbritmark
archetype AI_NONE
mono_loop 0 0
volume -500
squarelo

// Ritual aborted
schema nbritabort
archetype AMB_M20
volume -1
tension7

// Ritual summoning prophet
schema nbritfinale1
archetype AMB_M20
volume -1
egpedww

// Ritual summoned prophet now
schema nbritfinale2
archetype AMB_M20
volume -1
egzap

// Guess they don't expect you to hit ceramic things with the blackjack?
// There wasn't a schema for it!
schema blackjack_ceram
// This archetype makes it a minor anomaly
archetype HIT_MATERIAL
volume -1
ar_body1 ar_body2
env_tag (Event Collision) (WeaponType Blackjack) (Material Ceramic)


// -------------------------- AMBIENCE ----------------------------

// Cave 5 loop
schema m20cave5loop
archetype AMB_M20
volume -1000
mono_loop 0 0
cavetone

// Interior mood
schema m20cave5mood
archetype AMB_M20
volume -1500
mono_loop 0 0
drumloop

// Interior tension
schema m20cave5ten
archetype AMB_M20
volume -1500
mono_loop 6000 8000
m02bs2a m02bs2b m02bs2c m02bs2d

// Ritual loop
schema m20ritualloop1
archetype AMB_M20
volume -1500
mono_loop 0 0
eees1

// Ritual loop
schema m20ritualloop2
archetype AMB_M20
volume -1000
mono_loop 0 0
eees2

// Ritual loop
schema m20ritualloop3
archetype AMB_M20
volume -500
mono_loop 0 0
eees3

// Ritual final stage mood
schema m20ritualmood4
archetype AMB_M20
volume -500
mono_loop 0 0
dronelp

// Ritual failed mood
schema m20ritualmood5
archetype AMB_M20
volume -1
mono_loop 0 0
rising

// Post-ritual cave mood
schema m20cave7mood
archetype AMB_M20
volume -1000
mono_loop 6000 8000
cave1 cave5 cave6 cave8 cave10
