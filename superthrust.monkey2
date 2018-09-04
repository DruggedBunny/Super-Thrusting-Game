
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

Const VR_MODE:Int = False

Const AppName:String = "Super Thrusting Game!"

Const TMP_LEVEL_COMPLETE:Bool = False

' Yes, this is stupid! But it highlights better than comments AND prompts me to reduce clutter in Output window!

Function InitTODOs ()
	
	#Rem
	
		https://github.com/blitz-research/monkey2/issues/399#issuecomment-409764752
	
		In your SmokeParticle component, when alpha fades out you only actually need to destroy the entity the
		component is attached to, as destroying an entity will also destroy all its components, eg: just an
		Entity.Destroy() is enough.
		
		You don't really need the SmokeParticle class at all IMO, everything inside it can go into
		SmokeParticleComponent. This might help keep the code a bit more reusable and less confusing.
		
		You could create the bodies, collider etc inside Component.OnStart(), or you could even create a
		'prototype' SmokeParticle model/entity and just use Entity.Copy() to copy it when generating
		particles. This prototype/copy approach is actually how I intended it to work, and is basically
		(how I remember) b3d worked.
		
		I'd also personally advise less use of '?.' although I can't quite tell you why!
	
	#End
	
	TODO ("See REM...")

	TODO ("Properly spawn dummy orb/collection point")
	TODO ("Silence channels on level completion")
	TODO ("Generate misc hit sounds for terrain bumps")
	TODO ("Convert all physics entities to Behaviors")
	TODO ("Fix SpaceGem retardity! Create model in SpaceGem.New!")
	TODO ("SpaceGem -- OnUpdate -> OnBeginUpdate?")
	TODO ("Convert SmokeParticle and Orb to pure Behaviors")
	TODO ("Pads have to be spawned AFTER level created... ideally would be in Level.New...")
	TODO ("Clear all scene components... somehow (smoke/physicstris)") ' Did I do this?!
	TODO ("VR: Scaling not right on monitor display")
	TODO ("HUD blackout should be framerate-independent (as should lots of other things)")
	TODO ("HUD skull image to 3d sprite (render text to texture??) -- to appear in VR. Started but not working")
	TODO ("Point in direction of fall when ballistic (out of fuel)... ? FUCKING IMPOSSIBLE")
	
End

Function Main ()

	InitTODOs ()
	ListTODOs ()
		
	' 0, 0 = desktop size:
	
	Local width:Int		= 1024
	Local height:Int	= 768
	
	Run3D (AppName, width, height, WindowFlags.Center)
'	Run3D (AppName, 0, 0, WindowFlags.Fullscreen)
	
End
