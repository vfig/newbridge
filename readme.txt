=============================================================================
 Nov 19, 2018
 Making a Profit - Release Candidate 2

! BETA FOR TESTING ONLY ! Please do not distribute this!
Please visit the test forum at Southquarter for the latest version
and all discussion:

    http://www.southquarter.com/beta/viewforum.php?f=11
=============================================================================

Bitte herunterscrollen für deutschen Text!
Per favore scrollare in basso per l'Italiano.
Faire défiler vers le bas pour le français!
Чтобы прочесть русскую версию, пожалуйста, прокрутите до самого конца.



***********
* ENGLISH *
***********

=============================================================================

Author                  : vfig (Andy Durdin)
Contact Info            : me@andy.durdin.net
Homepage                : http://backslashn.com
Version                 : RC2
Date of Release         : Nov 19, 2018

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
New Graphics            : Yes
New Sounds              : Yes
Multi-Language Support  : Yes (English, French, German, Italian, Russian)
Build Time              : 671 Dromed hours / 146 days

=============================================================================
* Installation *

The NewDark 1.26 patch or later is required to run this mission. The GOG
release of Thief Gold is recommended, as it comes with the latest NewDark
preinstalled:

    https://www.gog.com/game/thief_gold

If your Thief Gold comes from another source, you must apply the NewDark
1.26 patch manually (http://www.ttlg.com/forums/showthread.php?t=146448)
or using TFix (http://www.ttlg.com/forums/showthread.php?t=134733) version
1.26a or later. This mission was designed with the original low-resolution
textures and models in mind, and the use of any enhancement packs or texture
packs is not recommended. They won't break anything, but parts of the mission
might not look as intended.

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
will be fine.

If you want to enable 'new mantle', edit USER.CFG in your Thief Gold
directory and add the following line:

    new_mantle

Note that changes made to USER.CFG will take effect for the entire game and
all fan missions.

=============================================================================
* Languages and Subtitles *

This mission contains subtitles for all its new dialog. To enable them, edit
USER.CFG in your Thief Gold directory and add the following line:

    enable_subtitles

Subtitles will be shown in the same language as texts, where available (see
below for more on configuring languages). Please see subtitles.txt in your
NewDark distribution for more information on configuring font sizes and
colours, and what kinds of speech and sound effects subtitles will be shown
for.

If you want subtitles for all the stock Thief dialog and sound effects, you
will have to install a Thief Gold subtitle pack. An English subtitle pack can
be found at http://www.ttlg.com/forums/showthread.php?t=144354

Texts and subtitles for this mission are available in English, French, German,
Italian, and Russian. The 'language' setting in INSTALL.CFG sets the languages
used by the game. By default this is set to the language that your version of
Thief uses. If you prefer to have text and subtitles in a different language
where available, you must edit INSTALL.CFG, and add your preferred language at
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
* Distant Buildings *

This mission is quite aggressive on view distances, as the hilltop and some
other parts of the city are visible from almost everywhere. From some vantage
points, you may occasionally see distant buildings appear and vanish. If this
bothers you, find and disable the 'wr_render_zcomp' setting in CAM_EXT.CFG.

Note that changes made to CAM_EXT.CFG will take effect for the entire game
and all fan missions.

=============================================================================
* Credits *

Created by              : vfig (Andy Durdin)

Story                   : vfig
                        : Aaron Dron

Briefing illustrations  : Kayleigh Boyd

Voice acting:
    Garrett             : M. Alasdair MacKenzie
    Lady di Rupo        : Shadow Creepr
    The Keeper          : Yandros
    The Eternal Benny   : Yandros
    Irate Sergeant      : MasterThief3
    Heathen guard       : Yandros
    Cowardly Hammerite  : McTaffer
    Danno the meister   : Yandros
    Olver the digger    : McTaffer
    Morten the berk     : (Nobody, cause he's dead)
    Hammerite priest    : McTaffer
    Hammerite watchman  : Yandros

Translation:
    French              : Athalle
    German              : baeuchlein
    Italian             : piesel
    Russian             : MoroseTroll

Proofreading            : gnartsch

Beta testing            : Alex Lemcovich
                        : bob_doe_nz
                        : Cardia
                        : Dillon Rogers
                        : Dr.Sahnebacke
                        : Freddy Fox
                        : Gloria Creep
                        : itllrun10s
                        : Justin Keverne
                        : M. Alasdair MacKenzie
                        : marbleman
                        : nightshifter
                        : Norgg
                        : prjames
                        : R Soul
                        : Rachel Crawford
                        : Ravenhook

Special thanks:

    To Skacky, Unna Oertdottir, and Yandros for their help when Dromed tried
    to murder this mission in its infancy.

    To Athalle and Fortuni for putting me in touch with the translators and
    giving me a place on the 'Shadow' forum.

    To Tannar, Brethren, and Dussander for providing the 'Shalebridge Cradle'
    and 'Southquarter' beta test forums.

    To 'Le Corbeau', for NewDark.

    To all the fan mission authors who came before me and inspired me to get
    my hands dirty with Dromed.

    To all you taffers out there, on TTLG and beyond, who have kept Thief
    alive for the past twenty years!

=============================================================================
* Copyright Notice *

This mission is ©2018 by Andy Durdin.

Distribution of this mission is allowed as long as it is free and unmodified.

This level was not made and is not supported by Looking Glass Studios or Eidos
Interactive.



***********
* DEUTSCH *
***********

=============================================================================
 19. November 2018
 Ein netter Profit
=============================================================================

Autor                   : vfig (Andy Durdin)
Kontakt                 : me@andy.durdin.net
Homepage                : http://backslashn.com
Version                 : RC2
Datum                   : 19. November 2018

Einführung:

    Ein Bekannter von mir, Argaux, hat mir ein Angebot für einen Auftrag
    in Newbridge verschafft. Er wollte mir keine Einzelheiten mitteilen -
    vielleicht hat er Angst, dass ich es hinter seinem Rücken durchziehe?
    Aber er sagt, es wäre eilig. Und die Bezahlung wäre es wert.

    Ich war nie in Newbridge, aber ich habe gehört, es sei ein dunkler und
    stiller kleiner Ort im Randbereich der Stadt. Lady di Rupo, eine reiche
    Dame mit einem modischen Anwesen oben auf den Klippen, hat de facto das
    Sagen in dieser Gegend. Ich muss auf ihre Wachen achtgeben, während ich
    mich dort befinde; die sind nicht gerade begeistert von Dieben.

    Die Hammeriten sollen seit kurzem versuchen, selber die Kontrolle über
    den Bezirk zu übernehmen, und das hat Ärger ausgelöst. Man sagte mir,
    di Rupo wäre dem Orden des Hammers nicht wohl gesonnen - aber gut, das
    bin ich auch nicht, obwohl ich das ganze Gold, mit dem sie ihre Tempel
    dekorieren, durchaus zu schätzen weiß.

    Welche weiteren Details dieser Auftrag auch noch bereithalten mag, ein
    Besuch in Newbridge wird eine willkommene Abwechslung sein. Ich werde
    mich zum Brunnen begeben, dort Argaux treffen und hören, was er zu sagen
    hat.

=============================================================================
* Informationen zur Mission *

Spiel                   : Thief Gold, NewDark v1.26
Missionsname            : Ein netter Profit
Missionsdatei           : miss20.mis
Einführungsfilm         : ja
Schwierigkeitsgrad      : Normal/Hart/Experte
Ausrüstungsladen        : ja
Karte                   : ja
Automap                 : ja
Neue Grafiken           : ja
Neue Sounds             : ja
Mehrsprachen-Unter-
 stützung               : ja (Deutsch, Englisch, Französisch, Italienisch,
                              Russisch)
Bauzeit                 : 671 Stunden im Dromed / 146 Tage

=============================================================================
* Weitere Informationen *

NewDark v1.26 (Patch) wird zum Spielen der Mission benötigt. Die GOG-Version
von Thief Gold wird empfohlen, da sie schon die neueste NewDark-Version be-
inhaltet. Zu finden ist sie unter

    https://www.gog.com/game/thief_gold

Wer Thief Gold (deutsch: "Dark Projekt Directors Cut") aus einer anderen
Quelle erhalten hat, muss den NewDark-Patch auf Version 1.26 entweder "von
Hand" installieren (vgl. http://www.ttlg.com/forums/showthread.php?t=146448)
oder aber TFix Version 1.26a oder neuer benutzen (siehe dazu
http://www.ttlg.com/forums/showthread.php?t=134733).

Diese Mission wurde unter Verwendung der ursprünglichen Texturen niedriger
Auflösung erstellt, und das Benutzen von Verbesserungen wie dem "Enhancement
pack" oder anderen Textur-Zusatzpaketen wird nicht empfohlen. Sie würden
zwar vermutlich das Spiel nicht ernsthaft stören, aber könnten evtl. nicht
zum restlichen Aussehen der Mission passen.

Man sollte den FM-Selektor von NewDark zum Spielen dieser Mission benutzen.
Dazu muss man die Zip- oder 7Zip-Dateien, die die Missionen enthalten, in
einen Ordner speichern; den Ordner erstellt man, wenn man noch keinen hat.
Die Missionsdateien braucht man nicht zu entpacken, das macht der FM-Selektor
automatisch. Wenn man den FM-Selektor zum ersten Mal startet, fragt er, ob
man einen "FM Archive path" (das ist der Ordner mit den Missionsdateien)
einstellen will. Man sollte dann "yes" wählen und danach denjenigen Ordner
angeben, in den man die Missionsdateien speichert. Der FM-Selektor kümmert
sich dann selbst um das Entpacken und Installieren von Missionen.
Man kann den FM-Selektor mit dem Spiel starten, wenn man "-fm" als
Kommandozeilen-Parameter an das Spiel übergibt:

    THIEF.EXE -fm

Man kann stattdessen aber auch die Datei CAM_MOD.INI im Ordner des Spiels
ändern. Nähere Informationen dazu stehen in dieser Datei.

Mehr Informationen zu FM-Selektor enthält die Datei FMSel.pdf, die mit
NewDark mitgeliefert wird.

Wer ein anderes Programm zum Starten der Missionen vorzieht, wie z.B.
NewDarkLoader, weiß vermutlich schon, wie er dieses dann benutzt.

=============================================================================
* Einstellungen für das Spielen der Mission *

Die Funktion "new mantle" von NewDark macht das Klettern im Spiel einfacher,
und es funktioniert auch viel zuverlässiger damit, daher empfiehlt der Autor,
"new mantle" zu benutzen. Die Mission wurde aber auch ohne "new mantle"
getestet; wer das Klettern ohne diese Funktion vorzieht, sollte keine
Probleme haben.

Um "new mantle" einzuschalten, kann man die Datei USER.CFG im Ordner von
"Thief Gold" ("Der Meisterdieb - Directors Cut") öffnen und folgende Zeile
hinzufügen:

    new_mantle

Beachten Sie bitte, dass Änderungen an USER.CFG auch für andere Missionen
sowie das Originalspiel wirksam werden.

=============================================================================
* Sprache und Untertitel *

Diese Mission enthält Untertitel für neue Dialoge. Um diese Untertitel
sichtbar zu machen, muss man in die Datei USER.CFG im Ordner des Spiels
folgende Zeile eintragen:

    enable_subtitles

Untertitel, sofern vorhanden, werden in derselben Sprache wie die übrigen
Texte angezeigt; zur Einstellung der Sprache siehe den übernächsten Abschnitt
dieses Texts. Mehr Informationen über Einstellungen zu den Untertiteln
(Farben, Größe der verwendeten Schrift, Auswahl der angezeigten Untertitel)
findet man in der Datei subtitles.txt im Ordner DOC innerhalb des
NewDark-Ordners.

Wer Untertitel für die vom Originalspiel stammenden Gespräche und
Soundeffekte haben möchte, muss nach solchen Untertiteln suchen und sie
installieren. Eine Zusammenstellung von Untertiteln auf Englisch gibt es
unter http://www.ttlg.com/forums/showthread.php?t=144354 ; falls es eine
deutsche Zusammenstellung dafür geben sollte, erfährt man davon
wahrscheinlich auf https://www.ttlg.de.

Texte und Untertitel für diese Mission sind in Englisch, Deutsch, Französisch,
Italienisch und Russisch vorhanden. Die Einstellung "language" in der Datei
INSTALL.CFG im NewDark-Verzeichnis bestimmt, welche Sprachen im Spiel benutzt
werden. Normalerweise ist hier die Sprache eingestellt, die das Originalspiel
nutzt. Wer Texte und Untertitel in einer anderen als dieser Sprache
angezeigt haben will, muss INSTALL.CFG öffnen und die gewünschte Sprache
vor die eingestellte schreiben, gefolgt von einem Plus-Zeichen ("+").

Wenn man also eine englische Version des Spiels besitzt, aber lieber Texte
auf Deutsch liest, muss man INSTALL.CFG öffnen und nach einer Zeile suchen,
die

    language english

lautet. Die ändert man dann in

    language german+english

und speichert INSTALL.CFG. Denken Sie daran, dass Änderungen in INSTALL.CFG
und USER.CFG sich auch auf andere Fan-Missionen sowie das Originalspiel
auswirken.

=============================================================================
* Anzeige weit entfernter Gebäude *

In dieser Mission sind zum Teil weit entfernte Dinge zu sehen; die Spitze des
Hügels und einige andere Teile der Stadt können von fast überall im Spiel
gesehen werden. Von einigen Punkten aus kann man manchmal weit entfernte
Gebäude erscheinen und wieder verschwinden sehen. Falls Sie das stört, können
Sie die Einstellung "wr_render_zcomp" in der Datei CAM_EXT.CFG suchen und
ausschalten.

Bedenken Sie, dass Änderungen in CAM_EXT.CFG auch in anderen Fan-Missionen
sowie im Originalspiel wirksam werden.


=============================================================================
* Danksagung usw. *

Design und Baukunst     : vfig (Andy Durdin)

Story                   : vfig
                        : Aaron Dron

Illustrationen für den
Einführungsfilm         : Kayleigh Boyd

Stimmen:
    Garrett             : M. Alasdair MacKenzie
    Lady di Rupo        : Shadow Creepr
    Hüter               : Yandros
    Der Ewige Benny     : Yandros
    Wütender Sergeant   : MasterThief3
    Wache der Heiden    : Yandros
    Feiger Hammerit     : McTaffer
    Meister Danno       : Yandros
    Hosenscheißer Olver : McTaffer
    Glückloser Morten   : (keiner, der ist tot!)
    Hammeritenpriester  : McTaffer
    Hammeritenwache     : Yandros

Übersetzung:
    Deutsch             : baeuchlein
    Französisch         : Athalle
    Italienisch         : piesel
    Russisch            : MoroseTroll

Korrekturlesen          : gnartsch

Betatester              : Alex Lemcovich
                        : bob_doe_nz
                        : Cardia
                        : Dillon Rogers
                        : Dr.Sahnebacke
                        : Freddy Fox
                        : Gloria Creep
                        : itllrun10s
                        : Justin Keverne
                        : M. Alasdair MacKenzie
                        : marbleman
                        : nightshifter
                        : Norgg
                        : prjames
                        : R Soul
                        : Rachel Crawford
                        : Ravenhook

Besonderer Dank gebührt:

    Skacky, Unna Oertdottir und Yandros für ihre Hilfe, als Dromed versuchte,
    diese Mission in ihrer Kindheit zu ermorden.

    Athalle und Fortuni, die mich in Kontakt mit den Übersetzern und dem
    'Shadow'-Forum brachten.

    Tannar, Brethren und Dussander, die die Betatest-Foren 'Shalebridge
    Cradle' und 'Southquarter' betreiben.

    'Le Corbeau', für NewDark.

    Allen Autoren von Fan-Missionen, die vor mir aktiv waren und mich dazu
    inspirierten, mir selbst mit Dromed die Hände schmutzig zu machen.

    Allen von euch "Dieben", auf TTLG und anderswo. Ihr habt "Thief" in den
    vergangenen zwanzig Jahren am Leben erhalten!

=============================================================================
* Copyright *

©2018 Andy Durdin.

Die Weiterverbreitung dieser Mission ist erlaubt, solange
das ohne Bezahlung passiert und die Mission nicht verändert wird.

Diese Mission wurde nicht von Looking Glass Studios oder Eidos Interactive
erstellt, und Support leisten sie daher auch nicht dafür.



************
* ITALIANO *
************

=============================================================================
 19. Novembre 2018
 Trarre Profitto
=============================================================================

Autore                    : vfig (Andy Durdin)
Informazioni sui contatti : me@andy.durdin.net
Homepage                  : http://backslashn.com
Versione                  : RC2
Data di Pubblicazione     : Nov 19, 2018

Descrizione:

    Una mia conoscenza professionale, Argaux, mi ha offerto un lavoro a
    Newbridge. Non mi ha dato alcun dettaglio - forse teme che io lo possa
    ingannare e che cosi' perda la sua tariffa? - ma dice che e' urgente. E
    paga generosamente.

    Non son mai stato a Newbridge prima, ma ho sentito che e' un'ombroso e
    quieto luogo isolato alla periferia della citta'. L'area e' in mano alla
    Signora di Rupo, una nobile facoltosa che possiede una raffinata magione
    sulla scogliera. Dovro' stare attento alle sue guardie mentre saro' nel
    quartiere: non daranno certo il benvenuto ad un ladro.

    A quanto si dice gli Hammeriti hanno recentemente iniziato a provare a
    rendere il controllo del distretto, e cio' sta causando problemi. Delle
    persone mi han detto che di Rupo non ha amore per l'Ordine del Martello -
    e nemmeno io. Anche se ho una passione per tutto l'oro con cui decorano i
    loro templi.

    Qualsiasi cosa questo lavoro comporti, visitare Newbridge sara' un
    interessante cambio di scenario. Andro' ad incontrare Argaux alla fontana,
    ed ascoltero' cos'ha da dirmi.

=============================================================================
* Informazioni di Gioco *

Gioco                     : Thief Gold, NewDark 1.26
Titolo della Missione     : Trarre Profitto
Nome del File             : miss20.mis
Briefing                  : Si
Settaggi Difficoltà       : Normale/Difficile/Esperto
negozio d'Equipaggiamento : Si
Mappa                     : Si
Auto-Mappa                : Si
Nuove Grafiche            : Si
Nuovi Suoni               : Si
Supporto Multi-Lingua     : Si (Francese, Inglese, Italiano, Russo, Tedesco)
Tempo di Costruzione      : 671 ore in Dromed / 146 giorni

=============================================================================
* Informazioni di Caricamento *

La patch 1.26 di NewDark è richiesta per utilizzare questa missione. E'
raccomandata la versione GOG di Thief Gold, già  aggiornata all'ultima
versione di NewDark:

    https://www.gog.com/game/thief_gold

Se il tuo Thief Gold arriva da un'altra fonte, dovrai applicare il patch 1.26
di NewDark manualmente (http://www.ttlg.com/forums/showthread.php?t=146448)
od usare TFix (http://www.ttlg.com/forums/showthread.php?t=134733) versione
1.26a o successive. Questa missione è stata ideata con in mente gli originali
modelli e texture a bassa risoluzione, l'utilizzo di qualsiasi pacchetto di
miglioramento o pacchetto di texture è sconsigliato. Probabilmente non
danneggerebbero nulla, ma parti della missione non apparirebbero in modo
corretto.

Dovresti utilizzare NewDark's FMSel per far partire questa missione. Se già
non ne hai una, crea una directory per gli zip delle missioni e mettici dentro
questo pacchetto, senza scompattarlo. Quando lancerai FMSel per la prima
volta, ti chiederà se vuoi configurare un percorso epr gli archivi: rispondi
si, e seleziona questa directory. A questo punto FMSel scompatterà ed
installerà la missione per te.

Per lanciare il selettore di FM, fai partire il gioco con il comando:

    THIEF.EXE -fm

Alternativamente puoi editare CAM_MOD.INI per far partire sempre il selettore
di FM; le relative istruzioni sono nel file. Per favore consulta FMSel.pdf nel
tuo pacchetto di NewDark per maggiori informazioni sull'utilizzo di FMSel.

Se preferissi un differente caricatore di missioni, come NewDarkLoader, allora
sai già cosa fare.

=============================================================================
* Configurazione *

La funzione 'new mantle' di Newdark rende l'arrampicarsi più semplice e
decisamente più affidabile, quindi raccomando di utilizzarla. In ogni caso la
missione è stata completamente testata senza, quindi se preferissi le
originali meccaniche di arrampicata, non avrai problemi.

Se volessi attivare 'new mantle', edita USER.CFG nella tua directory di Thief
Gold ed aggiungi la seguente linea:

      new_mantle

Nota che le modifiche apportate ad USER.CFG avranno effetto sull'intero gioco
e tutte le missioni.

=============================================================================
* Linguaggi e Sottotitoli *

Questa missione contiene sottotitoli per tutti i nuovi dialoghi. Per
attivarli, edita USER.CFG nella tua directory di Thief Gold ed aggiungi la
seguente linea:

      enable_subtitles

Se disponibili, i sottotitoli appariranno nella stessa lingua dei testi (leggi
sotto per come configurare i linguaggi). Per favore leggi subtitles.txt nel
tuo pacchetto NewDark per maggiori informazioni sul come configurare la
dimensione ed il colore dei caratteri, e quali tipi di parlato e sottotitoli
degli effetti sonori verranno mostrati.

Se desideri i sottotitoli per tutti i dialoghi ed effetti sonori originali di
Thief, dovrai installare il pacchetto di sottotitoli di Thief Gold. Un
pacchetto di sottotitoli in Inglese è disponibile a:
http://www.ttlg.com/forums/showthread.php?t=144354

Testi e sottotitoli per questa missione sono disponibili in Inglese, Francese,
Italiano, Russo, ed Tedesco. Il settaggio 'language' in INSTALL.CFG seleziona
la lingua utilizzata dal gioco. Di default corrisponde a quella utilizzata
dalla tua versione di Thief. Se preferissi avere testi e sottotitoli in una
lingua differente, dovrai editare INSTALL.CFG ed aggiungere la tua lingua
preferita all'inizio del settaggio, seguito da un '+'.

Ad esempio, se stessi giocando la versione Inglese di Thief, ma preferissi
vedere testi in Italiano nella missione, dovrai editare INSTALL.CFG e
modificare la linea:

       language english

In:

       language italian+english

Nota che modifiche apportate ad INSTALL.CFG ed USER.CFG avranno effetto
sull'intero gioco e tutte le missioni.

=============================================================================
* Edifici Distanti *

Questa missione è piuttosto aggressiva sulla distanza delle visuali, visto che
la cima della collina ed altre parti della città sono visibili da quasi
ovunque. Da alcuni punti privilegiati, potresti occasionalmente vedere edifici
diatanti apparire e scomparire. Se ciò ti disturbasse, trova e disattiva il
settaggio 'wr_render_zcomp' in CAM_EXT.CFG.

Nota che modifiche apportate a CAM_EXT.CFG avranno effetto sull'intero gioco e
tutte le missioni.

=============================================================================
* Riconoscimenti *

Ideazione e costruzione : vfig (Andy Durdin)

Storia                  : vfig
                        : Aaron Dron

Arte del Briefing       : Kayleigh Boyd

Doppiaggio:
    Garrett             : M. Alasdair MacKenzie
    Signora di Rupo     : Shadow Creepr
    Keeper              : Yandros
    L'Eterno Benny      : Yandros
    Sergente Irato      : MasterThief3
    Guardia pagana      : Yandros
    Hammerita Codardo   : McTaffer
    Danno il campione   : Yandros
    Olver lo scavatore  : McTaffer
    Morten il fesso     : (Nobody, cause he's dead)
    Prelato hammerita   : McTaffer
    Sentinella Hammerita: Yandros

Traduzioni:
    Francese            : Athalle
    Italiano            : piesel
    Russo               : MoroseTroll
    Tedesco             : baeuchlein

Correzione di bozze     : gnartsch

Beta testing            : Alex Lemcovich
                        : bob_doe_nz
                        : Cardia
                        : Dillon Rogers
                        : Dr.Sahnebacke
                        : Freddy Fox
                        : Gloria Creep
                        : itllrun10s
                        : Justin Keverne
                        : M. Alasdair MacKenzie
                        : marbleman
                        : nightshifter
                        : Norgg
                        : prjames
                        : R Soul
                        : Rachel Crawford
                        : Ravenhook

Ringraziamenti Speciali:

    A Skacky, Unna Oertdottir, e Yandros per il loro aiuto quando Dromed ha
    provato ad uccidere questa missione nella sua infanzia.

    Ad Athalle e Fortuni per avermi messo in contatto con i traduttori ed
    avermi ospitato nello 'Shadow' forum.

    A Tannar, Brethren, e Dussander per aver reso disponibili i forum di beta
    testing 'Shalebridge Cradle' e 'Southquarter'.

    A Le Corbeau, per NewDark.

    A tutti gli autori di missioni che son venuti prima di me e che mi hanno
    ispirato a sporcarmi le mani con Dromed.

    A tutti i taffers in giro, su TTLG ed oltre, che hanno tenuto Thief in
    vita per gli ultimi venti anni!

=============================================================================
* Informazioni sui Diritti d'Autore *

Questa missione è ©2018 di Andy Durdin.

La distribuzione di questa missione è autorizzata fin quando sia gratuita e
non modificata.

Qusto livello non è stato fatto e non è supportato da Looking Glass Studios o
Eidos Interactive.



***********
* FRANCAIS *
***********

=============================================================================
 19 Novembre 2018
 Faire un Profit
=============================================================================

Auteur                  : vfig (Andy Durdin)
Contact Info            : me@andy.durdin.net
Homepage                : http://backslashn.com
Version                 : RC2
Date de Sortie          : 19 Novembre 2018

Description:

    Argaux, l'une de mes relations professionnelles, a pris contact avec moi
    pour me proposer un boulot à Newbridge. Il ne me donnera aucun détail -
    peut-être a-t-il peur que je le fasse en douce et il perdrait alors ses
    honoraires? Mais il a dit que c'était urgent. Et cela paye généreusement.

    Je ne suis jamais allé à Newbridge auparavant, mais j'ai entendu dire que
    c'était un coin sombre, calme et mortel à la périphérie de la ville. La
    zone est sous la coupe de Lady di Rupo, une personne influente avec un
    hôtel particulier sur les hauteurs au bord de la falaise. Je devrais
    garder à l'oeil ses gardes pendant que je serais dans les parages: ils ne
    sont pas particulièrement accueillants avec les voleurs.

    Selon certaines sources, les marteleurs auraient récemment commencé à
    tenter de prendre le contrôle du district, ce qui a causé des problèmes.
    Des gens m'ont dit que di Rupo n'aimait pas l'Ordre du Marteau - alors moi
    non plus. Même si j'aime tout l'or qu'ils utilisent pour décorer leurs
    temples.

    Quoique ce travail implique, visiter Newbridge sera un dépaysement
    intéressant. J'irai à la rencontre d'Argaux à la fontaine afin d'écouter
    ce qu'il a à me dire.

=============================================================================
* Informations de Jeu *

Jeu                     : Thief Gold, NewDark 1.26
Titre de la Mission     : Faire un Profit
Nom du Fichier          : miss20.mis
Briefing                : Oui
Niveaux de Difficulté   : Normal/Difficile/Expert
Magasin d'Équipment     : Oui
Carte                   : Oui
Auto Map                : Oui
Nouveaux Graphiques     : Non
Nouveaux Sons           : Oui
Multi-Language Support  : Oui (Allemand, Anglais, Français, Italien, Russe)
Temps de Construction   : 671 heures à Dromed / 146 jours

=============================================================================
* Installation *

NewDark 1.26 ou supérieur est requis pour faire fonctionner cette mission.
La version Thief Gold de GOG est recommendée, car elle est mise à jour avec
la dernière version de NewDark préinstallée:

    https://www.gog.com/game/thief_gold

Si votre Thief Gold vient d'une autre source, vous devrez installer le patch
NewDark 1.26 manuellement (http://www.ttlg.com/forums/showthread.php?t=146448)
ou utiliser TFix (http://www.ttlg.com/forums/showthread.php?t=134733) version
1.26a ou supérieure. Cette mission a été créée avec les textures et modèles
basse résolution, et l'utilisation des packs d'amélioration n'est pas 
recommandé. Ils ne casseront rien mais certaines parties de la mission
pourraient ne pas apparaître comme voulu.

Vous devriez utiliser FMSel (de Newdark) pour lancer cette mission. Si vous
ne l'avez pas encore installé, créé un répertoire pour les zips des missions
et déplacez ce zip à l'intérieur sans le décompresser. Quand vous lancez
FMSel la première fois, il sera demandé si vous voulez configurer le chemin
pour les archives: dites oui et selectionnez le répertoire que vous avez créé.
FMSel se chargera alors d'installer et de décompresser les missions pour vous.

Pour lancer FMSel, lancer le jeu avec l'argument -fm:

    THIEF.EXE -fm

Vous pouvez aussi éditer CAM_MOD.INI pour toujours lancer les missions avec
le lanceur de FM: les instructions pour le faire sont dans le fichier.
Veuillez consulter FMSel.pdf dans votre zip de Newdark pour plus
d'information.

Si vous préférez un autre lanceur de Fm, comme NewDarkLoader, alors vous savez
déjà comment faire.

=============================================================================
* Configuration *

L'option 'new mantle' de NewDark permet d'escalader beaucoup plus facilement
aussi je vous recommande de l'utiliser. Quoiqu'il en soit, la mission a été
testée sans, alors si vous préférez le style original pour escalader, cela
fonctionnera également.

Si vous voulez activer 'new mantle', éditer USER.CFG dans votre répertoire de
Thief Gold et ajouter la ligne:

    new_mantle

Notez que ce changement dans USER.CFG affectera tout le jeu ainsi que toutes
les fans missions.

=============================================================================
* Langages et Sous-titres *

Cette mission contient des sous-titres pour tous les nouveaux dialogues.
Pour les activer, éditez USER.CFG dans votre répertoire de Thief Gold et
ajoutez la ligne suivante:

    enable_subtitles

Les sous-titres apparaîtront dans la même langue disponible que les textes, 
(voir ci-dessous pour configurer les langues). Référez-vous à subtitles.txt de
votre archive NewDark pour plus d'information concernant la taille et la 
couleur des polices, ainsi que les autres options des sous-titres.

Si vous voulez des sous-titres pour tous les dialogues de Thief, vous devrez
installer Thief Gold subtitle pack. Une version anglaise du pack peut être
trouvée ici: http://www.ttlg.com/forums/showthread.php?t=144354

Les textes et sous-titres pour cette mission seront disponibles en anglais,
allemand, français, italien et russe. Le paramêtre de 'langue' dans
INSTALL.CFG affiche les langues utilisées par le jeu. Par défaut, il est
configuré sur la langue utilisée par votre version de Thief. Si vous préférez
avoir les textes et sous-titres dans une autre langue disponible, vous devez
éditer INSTALL.CFG, et ajouter votre langage au début, suivi par un '+'.

Par exemple, si vous jouez à une version anglaise de Thief, mais préférez voir
les textes français dans cette mission, vous devez éditer INSTALL.CFG et
changer la ligne:

    language english

par celle-ci:

    language french+english

Notez que les changements effectués dans INSTALL.CFG et USER.CFG affecteront
tout le jeu ainsi que les fans missions.

=============================================================================
* Bâtiments distants *

Cette mission est plutôt agressive sur les distances de vue, comme le sommet
des collines et certaines autres parties de la ville sont visibles de
quasiment partout. Selon votre position, pour pourriez occasionnellement voir
les bâtiments distants apparaître ou disparaître. Si cela vous gêne, trouvez
et désactivez dans CAM_EXT.CFG la ligne 'wr_render_zcomp'.

Notez que les changements effectués dans INSTALL.CFG et USER.CFG affecteront
tout le jeu ainsi que les fans missions.

=============================================================================
Créée par               : vfig (Andy Durdin)

Histoire                : vfig
                        : Aaron Dron

Briefing illustrations  : Kayleigh Boyd

Doublage Voix:
    Garrett             : M. Alasdair MacKenzie
    Lady di Rupo        : Shadow Creepr
    Gardien             : Yandros
    L'éternel Benny     : Yandros
    Le Sergent énervé   : MasterThief3
    Garde païen         : Yandros
    Marteleur lâche     : McTaffer
    Danno le boss       : Yandros
    Olver le terrassier : McTaffer
    Morten le connard   : Personne, parcequ'il est mort
    Prêtre Marteleur    : McTaffer
    Gardien Marteleur   : Yandros

Traduction:
    Allemand            : baeuchlein
    Français            : Athalle
    Italien             : piesel
    Russe               : MoroseTroll

Relecture (Allemand)    : gnartsch

Béta-testeurs           : Alex Lemcovich
                        : bob_doe_nz
                        : Cardia
                        : Dillon Rogers
                        : Dr.Sahnebacke
                        : Freddy Fox
                        : Gloria Creep
                        : itllrun10s
                        : Justin Keverne
                        : M. Alasdair MacKenzie
                        : marbleman
                        : nightshifter
                        : Norgg
                        : prjames
                        : R Soul
                        : Rachel Crawford
                        : Ravenhook

Remerciements spéciaux:

    A Skacky, Unna Oertdottir, et Yandros pour leur aide lorsque Dromed a
    tenté d'assassiner cette mission à ses débuts.

    A Athalle et Fortuni pour m'avoir mis en contact avec les traducteurs
    et fait une place sur le forum 'Shadow'.

    A Tannar, Brethren, et Dussander pour fournir les forums de béta-test de
    'Shalebridge Cradle' et 'Southquarter'.

    A 'Le Corbeau', pour NewDark.

    A tous les auteurs de fan missions qui ont oeuvré avant moi et m'ont
    donné l'envie de me salir les mains avec Dromed.

    A vous tous, sur TTLG et au-delà, qui avez gardé vivant Thief tout au 
    long de ces vingt dernières années!


=============================================================================
* Information de Droits d'Auteur*

Cette mission est ©2018 par Andy Durdin.

La distribution de cette mission est autorisée tant qu'elle reste gratuite et
que le zip n'est pas modifié.

Ce niveau n'est pas supporté et n'a pas été créé par Looking Glass Studios ou
Eidos Interactive.



***********
* РУССКИЙ *
***********

=============================================================================
 19 ноября 2018 г.
 Про судьбу и рок
=============================================================================

Автор                   : vfig (Andy Durdin / Энди Дёрдин)
Контакт                 : me@andy.durdin.net
Домашняя страницы       : http://backslashn.com
Версия                  : RC2
Дата выхода             : 19 ноября 2018 г.

Описание:

    Один мой профессиональный знакомый, Арго, взялся за дело в районе
    Нью-Бридж. Подробностями он со мной пока не поделился - может, боялся,
    что я оставлю его с носом, а он потеряет свою долю? - но сказал,
    что это срочно. И оплата будь здоров.

    В Нью-Бридже я никогда раньше не был, но слышал, что это тёмная,
    тихая маленькая заводь на окраине города. Район тот находится под пятой
    леди ди Рупо, богатой вельможи с причудливым особняком на краю утёса.
    Мне придётся держать ухо востро, когда я буду там по соседству:
    тамошняя стража ворам особо не радуется.

    Хаммериты вроде как недавно начали пытаться управлять районом сами,
    но гладко было на бумаге... Люди говорят мне, что ди Рупо не питает
    особой любви к Ордену Молота, но, должен заметить, и я тоже. Хотя мне
    нравится всё то золото, что они использовали для украшения своих храмов.

    Во что бы эта работёнка ни вылилась, мне будет полезно сменить чуток
    обстановку и посетить Нью-Бридж. Я отправлюсь на встречу с Арго, к фонтану,
    и послушаю, что он мне расскажет.

=============================================================================
* Общая информация *

Игра                    : Thief Gold, NewDark 1.26
Название миссии         : Making a Profit / "Про судьбу и рок"
Имя файла               : miss20.mis
Брифинг                 : Да
Difficulty Settings     : Normal/Hard/Expert
Equipment Store         : Да
Map                     : Да
Auto Map                : Да
New Graphics            : Да
New Sounds              : Да
Multi-Language Support  : Да (английский, французский, немецкий, итальянский
                              и русский)
Потрачено времени       : 671 часов в Dromed / 146 дней

=============================================================================
* Устанока *

Требуется NewDark 1.26 или выше. Рекомендуется версия игры с GOG, поскольку
она идёт уже с предустановленной последней версией NewDark:

    https://www.gog.com/game/thief_gold

Если ваша версия Thief Gold взята из другого источника, вам придётся установить
NewDark 1.26 вручную (http://www.ttlg.com/forums/showthread.php?t=146448) или
используя TFix (http://www.ttlg.com/forums/showthread.php?t=134733) версии
1.26a или выше. Эта миссия была разработана с прицелом на применение оригинальных
текстур и моделей низкого разрешения, так что использования разнообразных
"улучшайзеров" не рекомендуется. Они ничего не испортят, но некоторые части
миссии могут выглядеть не так, как было задумано.

Рекомендуется использовать FMSel для загрузки этой миссии. Если у вас этого
компонента ещё нет, создайте папку для архивов миссии и переместите этот
zip-файл тут, не распаковывая. При запуске FMSel в первый раз он попросит
вас указать путь к папке с архивами: ответьте 'да' и выберите ту папку. Всё
остальное FMSel возьмёт на себя.

Для запуска FMSel укажите игре параметр -fm:

    THIEF.EXE -fm

В качестве альтернативы, вы можете отредактировать CAM_MOD.INI так, чтобы
игра всегда сначала запускала FMSel; инструкция о том, как это сделать,
находится дальше. Пожалуйста, прочтите FMSel.pdf в папке NewDark, если
хотите больше узнать об FMSel.

Если же вы предпочитаете другой загрузчик, скажем, NewDarkLoader, то вы уже
знаете, что делать.

=============================================================================
* Конфигурация *

Настройка 'new mantle' в NewDark делает подтягивание проще и куда более надёжнее,
так что я рекомендую его включить. Однако эта миссия была полностью протестирована
без упомянутой настройки, так что, если вы предпочитаете играть со старым механизмом
подтягивания, то всё равно всё будет в порядке.

Если хотите включить 'new mantle', отредактируйте USER.CFG в папке, где лежит
Thief Gold и добавьте следующую строку:

    new_mantle

Имейте в виду, что изменения в USER.CFG влияют на всю игру и все фанатские миссии.

=============================================================================
* Языки и субтитры *

Эта миссия содержит субтитры для всех имеющихся диалогов. Чтобы включить их,
отредактируйте USER.CFG и добавьте следующую строку:

    enable_subtitles

Субтитры будут на том же языке, что и тексты в игре, если такое возможно
(см. ниже о том, как выбрать себе язык). Пожалуйста, ознакомьтесь с файлом
subtitles.txt в NewDark, если хотите получить больше информации об управлении
размером шрифтов и их цветом, а также, для каких видов речи и звуковых эффектов
они будут показываться.

Если вы хотите субтитры для всех имеющихся в оригинальном Thief диалогов и
звуковых эффектов, то вам придётся установить Thief Gold subtitle pack.
Английская версия его находится на http://www.ttlg.com/forums/showthread.php?t=144354

Тексты и субтитры в этой миссии доступны на английском, французском, немецком,
итальянском и русском языках. Настройка 'language' в файле INSTALL.CFG
устанавливает язык в игре. По умолчанию, этот тот же самый язык, что и в вашей
версии Thief. Если вы предпочитаете, чтобы текст и субтитры были на разных
языках, то отредактируйте INSTALL.CFG и укажите предпочтительный язык через
знак '+'.

Например, если вы играете в английскую версию, но хотели бы видеть русские
тексты в этой миссии, то измените в INSTALL.CFG строку:

    language english

на:

    language russian+english

Помните, что сделанные в INSTALL.CFG и USER.CFG изменения влияют на всю игру
и все фан-мисии.

=============================================================================
* Далёкие строения *

Эта миссия активно использует дальние виды, так как вершина холма или некоторые
части города видны практически отовсюду. С нескольких точек обзора вы случайно
можете заметить, что некоторые здания исчезают и появляются снова. Если вас это
беспокоит, то отключите настройку 'wr_render_zcomp' в CAM_EXT.CFG.

Помните, что сделанные в CAM_EXT.CFG изменения влияют на всю игру и все фан-мисии.

=============================================================================
* Авторство *

Создана                 : vfig (Энди Дёрдин)

Сценарий                : vfig
                        : Aaron Dron

Иллюстрации к брифингу  : Kayleigh Boyd

Озвучка:
    Гарретт             : M. Alasdair MacKenzie
    Леди ди Рупо        : Shadow Creepr
    Хранитель           : Yandros
    Вечный Бенни        : Yandros
    Гневный сержант     : MasterThief3
    Язычник-озранник    : Yandros
    Трусливый хаммерит  : McTaffer
    Данно-маэстро       : Yandros
    Олвер-копатель      : McTaffer
    Мортен-мудила       : (Никто, потому что он мёртв)
    Священник-хаммерит  : McTaffer
    Смотритель-хаммерит : Yandros

Перевод:
    Французский         : Athalle
    Немецкий            : baeuchlein
    Итальянский         : piesel
    Русский             : MoroseTroll

Выверка текстов         : gnartsch

Бета-тестирование       : Alex Lemcovich
                        : bob_doe_nz
                        : Cardia
                        : Dillon Rogers
                        : Dr.Sahnebacke
                        : Freddy Fox
                        : Gloria Creep
                        : itllrun10s
                        : Justin Keverne
                        : M. Alasdair MacKenzie
                        : marbleman
                        : nightshifter
                        : Norgg
                        : prjames
                        : R Soul
                        : Rachel Crawford
                        : Ravenhook

Особая благодарность:

    Skacky, Unna Oertdottir и Yandros за их помощь с Dromed, попытавшимся
    как-то раз убить данную миссию, потому ему этого захотелось.

    Athalle и Fortuni за то, что подогнали мне переводчиков и выделили место
    на форуме 'Shadow'.

    Tannar, Brethren и Dussander за предоставление 'Shalebridge Cradle'
    и 'Southquarter' для бета-теста.

    'Le Corbeau' за NewDark.

    Всем авторам миссий за то, что вдохновили меня замарать свои руки DromEd.

    Всем тафферам на свете, на TTLG и вообще, по чьей вине Thief ещё жив
    вот уже двадцать лет!

=============================================================================
* Авторское право *

Эта миссия ©2018 Энди Дёрдин.

Распространение этой миссии разрешено до тех лишь пор, пока это делается бесплатно,
а она сама остаётся нетронутой.

Этот уровень сделан не Looking Glass Studios и не Eidos Interactive и не поддерживается ими.
