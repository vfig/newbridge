// Sanctuary bell rings
schema m20sanctbell
archetype DEVICES_M20
volume -1
bellchur

// Sanctuary bell resonance
schema m20bellhum
archetype AMB_M20
volume -2000
mono_loop 0 0
belltoll

// Prison cells
schema m20cell
archetype AMB_M20
volume -1000
mono_loop 3000 4000
no_repeat
chain1 moan1 moan2 moan3 moan4

// Distant burricks
schema m20burricks
archetype AMB_M20
volume -2500
mono_loop 3000 7000
bk1a0br1 bk1a0br2 bk1a0br3 bk1a0br4 bk1a1__1 bk1a1__2 bk1a1__3 bk1a1__4 bk1a1__5

// Distant burrick footsteps
schema m20burrfeet
archetype AMB_M20
volume -2500
mono_loop 300 500
no_repeat
ft_bur1 ft_bur2 ft_bur3 ft_bur4 silenc1s silenc3s silenc9s

// -------------------------- AMBIENCE ----------------------------

// - Upper and lower floors (and some garden) -

// Sanctuary room tone
schema m20sanct1loop
archetype AMB_M20
volume -3000
mono_loop 0 0
chantlo

// Sanctuary tension
schema m20sanct1ten
archetype AMB_M20
volume -2000
mono_loop 3000 3000
me1 me2 me3

// - Basement -

// Sanctuary 2 room tone
schema m20sanct2loop
archetype AMB_M20
volume -1500
mono_loop 0 0
choirlo

// Sanctuary 2 tension
schema m20sanct2ten
archetype AMB_M20
volume -2500
mono_loop 3000 3000
me1 me2 me3

// - Crypt -

// Sanctuary 3 tension
schema m20sanct3ten
archetype AMB_M20
volume -500
mono_loop 0 0
thdown3
