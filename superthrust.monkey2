
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

' Hacks...

Const VR_MODE:Int = False
Const TMP_LEVEL_COMPLETE:Bool = False

' Yes, this is stupid! But it highlights better than comments AND prompts me to reduce clutter in Output window!

Function InitTODOs ()
	
	TODO ("Convert remaining physics entities to Behaviours; remaining: Rocket, DummyOrb (too simple?)")
	TODO ("Move Game.State into GameController")
	TODO ("Generate misc hit sounds for terrain bumps")
	
	TODO ("Have player drop orb into cup [SPACE PORTAL UNLOCK THINGY]? More involvement/skill, plus flying to portal with orb is... boring")
	TODO ("Pads have to be spawned AFTER level created... ideally would be in Level.New...")
	TODO ("VR: Scaling not right on monitor display")
	TODO ("HUD blackout should be framerate-independent (as should lots of other things)")
	TODO ("HUD skull image to 3d sprite (render text to texture??) -- to appear in VR. Started but not working")
	TODO ("Point in direction of fall when ballistic (out of fuel)... ? FUCKING IMPOSSIBLE")
	TODO ("Remove over-cautious object?.thing checks")
	TODO ("Disable one control method if other used -- per-loop (eg. can double-boost using Xbox pad AND space!)")
	
End

Function Main ()

	InitTODOs ()
	ListTODOs ()
	
	Local width:Int		= 1024
	Local height:Int	= 768
	
	Run3D (AppName, width, height, WindowFlags.Center)
	'Run3D (AppName, 0, 0, WindowFlags.Fullscreen)		' 0, 0 means desktop resolution
	
End
