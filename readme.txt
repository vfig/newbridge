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

You should use NewDark's FMSel feature to run this mission. If you don't have
one already, create a directory for mission zips, and move this zip file in
there, without unpacking it. When launching FMSel for the first time, it will
ask you if you want to configure an archive path: tell it yes, and select
this directory. FMSel will then manage unpacking and installing the mission
for you.

To launch the FM selector, run the game with the -fm argument:

    THIEF.EXE -fm

Alternatively you can edit CAM_MOD.INI to always run the FM selector; the
instructions for doing this are in the file. Please see FMSel.pdf in your
NewDark distribution for more information on using FMSel.

If you prefer a different mission loader, such as NewDarkLoader, then you
already know what to do.

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

This mission contains subtitles for all its original dialog. To enable them,
edit USER.CFG in your Thief Gold directory and add the following line:

    enable_subtitles

Subtitles will be shown in the same language as texts, where available (see
below for more on configuring languages). Please see subtitles.txt in your
NewDark distribution for more information on configuring font sizes and
colours, and what kinds of subtitles are shown.

Texts and subtitles in this mission are available in the following languages:

    ...FIXME!

The 'language' setting in INSTALL.CFG sets the languages used by the game.
By default this is set to the language that your version of Thief uses.
If you prefer to have text and subtitles in a different language where
available, you must edit INSTALL.CFG, and add your preferred language at
the start of the setting, followed by a '+'.

For example, if you are playing the English version of Thief, but would
prefer to see Italian texts in the mission, you would edit INSTALL.CFG and
change this line:

    language english

To this:

    language italian+english

Note that changes made to INSTALL.CFG and USER.CFG will take effect for the
entire game and all fan missions.

=============================================================================
* Credits *

FIXME! - some credits still missing.

Created by              : vfig

Story                   : vfig & Aaron Dron

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

Translation:
    Deutsch             : Baeuchlein
    Italiano            : Piesel
                        :
                        :
Proofreading            : Gnartsch
                        :
                        :

Beta testing            : FIXME!
                        :
                        :

Special thanks          : FIXME!
                        :
                        :

=============================================================================
* Copyright Notice *

This mission is ©2018 by Andy Durdin.

Distribution of this mission is allowed as long as it is free and unmodified.

This level was not made and is not supported by Looking Glass Studios or Eidos
Interactive.
