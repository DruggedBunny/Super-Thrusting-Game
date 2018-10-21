
' SUPER THRUSTING GAME!

' https://translate.google.com/?source=osdd#auto/ja/super%20thrusting%20game
' Er, translates back as "Super thrashing game"
' Sūpāsurasshingugēmu
' https://translate.google.com/?source=osdd#auto/en/%E3%82%B9%E3%83%BC%E3%83%91%E3%83%BC%E3%82%B9%E3%83%A9%E3%83%83%E3%82%B7%E3%83%B3%E3%82%B0%E3%82%B2%E3%83%BC%E3%83%A0
' Bonus: https://www.youtube.com/watch?v=ga62uiXbEjI

#Import "imports/imports"
#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Const AppName:String = "Super Thrusting Game!"

Global Game:GameWindow

' Hacks...

Const VR_MODE:Int = False
Const TMP_LEVEL_COMPLETE:Bool = False

' Yes, this is stupid! But it highlights better than comments AND prompts me to reduce clutter in Output window!

Function InitTODOs ()

	' Done: It was while adding TrumpWall ("er...") that I realised Private-isation is a wonderful thing. Fixed public Behaviour stuff that should have been private.
	' Done: Orb is easier to collect now that IT HAS A COLLISION RADIUS!
	' Done: HUD is now a proper object with methods, rather than a collection of public functions.
	' Done: HUD death-skull is finally a sprite! Should (SHOULD) now appear in VR, yet to test...
	' Done: Smoke is now more dynamic; clears up quicker and rises. May need to be changed to an option for performance, dunno yet.
	
	TODO ("DO SOON! Pause fups uck Game.Delta, leads to camera looking at nothing! R or Xbox pad Start to reset")
	
	TODO ("Can now add refueling sound after figuring out reliable non-colliding state; reset a collision flag each loop in GameController.ProcessGame!")
	TODO ("TrumpWall needs re-arranged in Level so each border can flash when hit")
	TODO ("Damage visibility/explosions")
	TODO ("Add Options class for performance tweaks, etc")
	TODO ("HUD skull image to 3d sprite (render text to texture??) -- to appear in VR. Should be able to implement now, thanks to recent sprite fix.")
	TODO ("Convert remaining physics entities to Behaviours; remaining: Rocket, DummyOrb (too simple?)")
	TODO ("Move Game.State into GameController")
	TODO ("Generate misc hit sounds for terrain bumps")
	
	TODO ("Have player drop orb into cup [SPACE PORTAL UNLOCK THINGY]? More involvement/skill, plus flying to portal with orb is... boring")
	TODO ("Pads have to be spawned AFTER level created... ideally would be in Level.New...")
	TODO ("VR: Scaling not right on monitor display")
	TODO ("Point in direction of fall when ballistic (out of fuel)... ? FUCKING IMPOSSIBLE")
	TODO ("Remove over-cautious object?.thing checks")
	
'	TODO ("LIKELY MOJO BUG: Deactivating window and releasing joystick, then activating window, acts as if joystick still held")
	
End

Function Main ()

'	SetConfig ("MOJO_OPENGL_PROFILE", "compatibility")
'	SetConfig ("MOJO3D_RENDERER", "forward")

	InitTODOs ()
	ListTODOs ()
	
	Local width:Int		= 1024
	Local height:Int	= 768
	
	Run3D (AppName, width, height, WindowFlags.Center)
'	Run3D (AppName, 0, 0, WindowFlags.Fullscreen)		' 0, 0 means desktop resolution
	
End
