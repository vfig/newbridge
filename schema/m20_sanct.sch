// Sanctuary bell rings
schema m20sanctbell
archetype AMB_M20
volume -1
bellchur

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
volume -1000
mono_loop 0 0
choirlo

// Sanctuary 2 tension
schema m20sanct2ten
archetype AMB_M20
volume -2000
mono_loop 3000 3000
me1 me2 me3

// - Crypt -

// Sanctuary 3 tension
schema m20sanct3ten
archetype AMB_M20
volume -1
mono_loop 0 0
thdown3
