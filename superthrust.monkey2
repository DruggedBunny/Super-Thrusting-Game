
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' A simple 3D game/mojo3d demonstration featuring (difficult) "Thrust"-style controls.

' This is the main file, handling core application initialisation, some temp hacks, plus TODO items...

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

	' Done: Refueling status/text
	' Done: RocketParticle now adds sparks
	' Done: Accidentally improved close-up camera! Raised up to avoid smoke trail and noticed it made close-up work easier. Now raised/lowered dynamically in GameCamera.
	
	TODO ("*** REVISIT DELTA TIMING -- BROKEN! Also, sprites in VR broken (along with delta), may be related")
	
	TODO ("PortalLock: just started. Need to remove at end of level! Player will drop orb here to unlock. Mini-portal hovering above?")
	
	TODO ("Reset can leave skull on screen!")
	TODO ("New refueling sound. Maybe add landing timer to delay before triggering -- slightly tricky due to need to reset Rocket.landed per-frame!")
	TODO ("Can end up carrying two orbs if collecting new one prior to old one being destroyed (where rocket dies first)")
	TODO ("TrumpWall needs re-arranged in Level so each solid border can flash when hit. Might, er, rename TrumpWall...")
	TODO ("Damage visibility/explosions")
	TODO ("Add Options class for performance tweaks, etc")
	TODO ("Convert remaining physics entities to Behaviours; remaining: Rocket, DummyOrb (too simple?)")
	TODO ("Generate misc hit sounds for terrain bumps")
	TODO ("Have player drop orb into cup [SPACE PORTAL UNLOCK THINGY]? More involvement/skill, plus flying to portal with orb is... boring")
	TODO ("Pads have to be spawned AFTER level created... ideally would be in Level.New...")
	TODO ("VR: Scaling not right on monitor display")
	TODO ("VR: See if skull sprite works, and may need to create full-screen sprite in place of fading canvas to black, not sure yet...")
	TODO ("Point in direction of fall when ballistic (out of fuel)... ? FUCKING IMPOSSIBLE")
	TODO ("Remove over-cautious object?.thing checks")
	TODO ("Sprite clouds?")
	TODO ("Add endless unskippable logos at startup")
	
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
	'Run3D (AppName, 0, 0, WindowFlags.Fullscreen)		' 0, 0 means desktop resolution
	
End
