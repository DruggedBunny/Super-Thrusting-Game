
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

Const TERRAIN_SIZE:Int = 256

' Hacks...

Const FULL_SCREEN:Bool				= True
Const VR_MODE:Int					= False
Const TMP_LEVEL_COMPLETE:Bool		= False
Const TMP_QUICK_LEVEL_TWEEN:Bool	= False

' Yes, this is stupid! But it highlights better than comments AND prompts me to reduce clutter in Output window!

Function InitTODOs ()
	
	TODO ("MAIN ITEM: Portal open/close logic needs revising now that orb gets dropped into portal lock")
	
	TODO ("Some pads cause damage and others don't... WTF?!")
	
	TODO ("Revise DummyOrb spawning logic to match other Behaviours")
	
	' *** WASM CRASH: "C:\Users\James\Desktop\wasm integer overflow.txt"
	
	' Done: WIP portal lock -- player will carry orb into sphere to trigger portal, then fly away without orb. Looks pretty cool!
	
	TODO ("Clouds don't spawn on Moon, which is good... but I haven't told it not to?! Currently in GameController.SpawnLevel...")
	
	TODO ("*** REVISIT DELTA TIMING -- BROKEN! Also, sprites in VR broken (along with delta), may be related")
	
	TODO ("GameState -> Proper object!")
	
	TODO ("Might add emergency air-jump to fix lying on side on ground... though finally detecting tilt angle and blowing up probably better...")
	TODO ("Damage visibility/explosions")
	TODO ("Add Options class for performance tweaks, etc")
	TODO ("Can get stuck between levels if alt-tabbing away/back!")
	TODO ("Convert remaining physics entities to Behaviours; remaining: Rocket, DummyOrb (too simple?)")
	TODO ("Generate misc hit sounds for terrain bumps")
	TODO ("Pads have to be spawned AFTER level created... ideally would be in Level.New...")
	TODO ("VR: Scaling not right on monitor display")
	TODO ("VR: See if skull sprite works, and may need to create full-screen sprite in place of fading canvas to black, not sure yet...")
	TODO ("Point in direction of fall when ballistic (out of fuel)... ? FUCKING IMPOSSIBLE")
	TODO ("Remove over-cautious object?.thing checks")
	TODO ("Add endless unskippable logos at startup")
	
'	TODO ("LIKELY MOJO BUG: Deactivating window and releasing joystick, then activating window, acts as if joystick still held")
	
End

Function Main ()

'	SetConfig ("MOJO_OPENGL_PROFILE", "compatibility")
'	SetConfig ("MOJO3D_RENDERER", "forward")

	InitTODOs ()
	ListTODOs ()

#If __TARGET__ = "emscripten"
	Local width:Int		= 800'1024
	Local height:Int	= 480'768
#else
	Local width:Int		= 1024
	Local height:Int	= 768
#Endif

	If FULL_SCREEN
		Run3D (AppName, 0, 0, WindowFlags.Fullscreen)		' 0, 0 means desktop resolution
	Else
		Run3D (AppName, width, height, WindowFlags.Center | WindowFlags.Resizable)
	Endif
	
End
