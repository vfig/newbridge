=============================================================================
 Sep 26, 2018
 Making a Profit - Beta 1

! BETA FOR TESTING ONLY ! Please do not distribute this!
Please visit the test forum at Shalebridge Cradle for the latest version
and all discussion:

    http://shalebridgecradle.co.uk/testing/viewforum.php?f=405

=============================================================================

Author                  : vfig (Andy Durdin)
Contact Info            : me@andy.durdin.net
Homepage                : http://backslashn.com
Version                 : Beta 1
Date of Release         : Sep 26, 2018

Description:

    A professional acquaintance of mine, Argaux, got in touch with an offer
    of a job in Newbridge. He won't give me any details--maybe he's afraid
    I'll do it on the sly and he'll lose out on his fee?--but he says it's
    urgent. And it pays generously.

    I've never been to Newbridge before, but I hear it's a dark, quiet little
    backwater on the outskirts of the city. The area's under the thumb of
    Lady di Rupo, a wealthy grandee with a fancy mansion up on the cliffside.
    I'll need to keep an eye open for her guards while I'm in the
    neighbourhood: they're not exactly welcoming to thieves.

    Reportedly the Hammers have recently started trying to wrestle control of
    the district for themselves, and this has been causing trouble. People
    tell me di Rupo has no love for the Order of the Hammer--but then neither
    do I. Although I do like all the gold they use to decorate their temples.

    Whatever else this job entails, visiting Newbridge will be an interesting
    change of scene. I'll go along and meet Argaux by the fountain, and hear
    what he has to say.

=============================================================================
* Summary *

Game                    : Thief Gold, NewDark 1.26
Mission Title           : Making a Profit
File Name               : miss20.mis
Briefing                : Yes
Difficulty Settings     : Normal/Hard/Expert
Equipment Store         : Yes
Map                     : Yes
Auto Map                : Yes
New Graphics            : No
New Sounds              : Yes
Multi-Language Support  : No (not yet... FIXME!)
Build Time              : 532 hours over 98 calendar days (so far)

=============================================================================
* Installation *

The NewDark 1.26 patch is required to run this mission. The GOG release of
Thief Gold is recommended, as it comes with the latest NewDark preinstalled:

    https://www.gog.com/game/thief_gold

If your Thief Gold comes from another source, you must apply the NewDark
1.26 patch manually (http://www.ttlg.com/forums/showthread.php?t=146448)
or using TFix (http://www.ttlg.com/forums/showthread.php?t=134733).
This mission was designed with the original low-resolution textures and
models in mind, and the use of any enhancement packs or texture packs is not
recommended. They probably won't break anything, but might not look right.

You should use NewDark's FMSel feature to run this mission. You can run the
game with the -fm argument to launch the FM selector:

    THIEF.EXE -fm

You should configure FMSel with an archive path, and move this .zip file
in there, without unpacking it. FMSel will unpack it for you when it installs
the mission. Please see FMSel.pdf in your NewDark distribution for more
information on using FMSel.

This mission has not been tested with other FM loaders such as DarkLoader,
so their use is not recommended.

=============================================================================
* Configuration *

The 'new mantle' feature in NewDark makes climbing easier and significantly
more reliable, so I recommend using it. However, the mission has been fully
tested without it, so if you prefer the original climbing behaviour, you
should be okay.

If you want to enable 'new mantle', edit USER.CFG in your Thief Gold
directory and add the following line:

    new_mantle

Note that changes made to USER.CFG will take effect for the entire game and
all fan missions.

=============================================================================
* Languages and Subtitles *

The text in this mission is available in the following languages:

    ...FIXME!

The 'language' setting in INSTALL.CFG sets the main language used by the
game. If you would like to have text and subtitles in a different language
(where available), you must edit INSTALL.CFG, and change the 'language'
setting to your preferred language and add a 'variant_path' setting with the
original language. For example, if you are playing the German version of Thief
Gold (Dark Project: Der Meisterdieb: Director's Cut), but would prefer to
see Italian text in the mission, you would edit INSTALL.CFG to have the
following lines:

    ; Resources in this language will be used when available:
    language italian
    ; If not available, then these languages will be tried in order:
    variant_path german;english

This mission contains subtitles for all its original dialog. To enable them,
edit USER.CFG in your Thief Gold directory and add the following line:

    enable_subtitles

Subtitles will be shown in the same language as the text, where available.
Please see subtitles.txt in your NewDark distribution for more information
on configuring font sizes and colours, and what kinds of subtitles are shown.

Note that changes made to INSTALL.CFG and USER.CFG will take effect for the
entire game and all fan missions.

=============================================================================
* Credits *

Design and build        :  FIXME!

Story                   :

Briefing art            :

Voice acting:
    Garrett             :
    Lady di Rupo        : Shadow Creepr
    Keeper              : Yandros
    Prophet             :
    The Eternal Benny   : Yandros
    Irate Sergeant      : MasterThief3
    Heathen guard       : Yandros
    Cowardly Hammerite  : McTaffer
    Danno the meister   : Yandros
    Olver the digger    : McTaffer
    Morten the berk     : Nobody, cause he's dead
    Hammerite priest    : McTaffer
    Hammerite watchman  : Yandros

Translation             :
                        :
                        :

Beta testing            :
                        :
                        :

Special thanks          :
                        :
                        :

=============================================================================
* Copyright Notice *

This mission is ©2018 by Andy Durdin.

Distribution of this mission is allowed as long as it is free and unmodified.

This level was not made and is not supported by Looking Glass Studios or Eidos 
Interactive.
