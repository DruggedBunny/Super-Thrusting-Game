
#Rem




	Method AppControl ()

		If Keyboard.KeyHit (Key.Escape)
			App.Terminate ()
		Endif

		If Keyboard.KeyHit (Key.R) Or (Player.joy And Player.joy.Attached And Player.joy.ButtonPressed (7))

			If SmokeParticle.ParticleList Then SmokeParticle.ParticleList.Clear ()

			If PhysicsTri.PhysicsTriList

				For Local pt:PhysicsTri = Eachin PhysicsTri.PhysicsTriList
					pt.Destroy ()
				Next

				PhysicsTri.PhysicsTriList.Clear ()

			Endif

			orb?.Destroy ()
			orb = Null

			' Store LOCAL position and orientation prior to un-parenting...
			
'			Local tcamlp:Vec3f = cam.LocalPosition
'			Local tcamlbas:Mat3f = cam.LocalBasis

'			Local tctamlp:Vec3f = cam_target.LocalPosition
'			Local tctamlbas:Mat3f = cam_target.LocalBasis
			
'			cam.Parent = Null
'			cam_target.Parent = Null
			
			Player.Destroy ()

			Player = New Rocket (0.0, 20.0, 0.0, 1.2, 4.0, 10.0)

			'cam.Parent = Player.model

			Game.MainCamera.Position (New Vec3f (0.0, 10.0, -25.0))
			
'			cam_target.Parent = Player.model
'			cam_target.Move (0, 0, -25)
'			cam_target.Position = cam.Position
		'	
			
			' Restore LOCAL position and orientation...
			
'			cam.LocalPosition = tcamlp
'			cam.LocalBasis = tcamlbas

'			cam_target.LocalPosition = tctamlp
'			cam_target.LocalBasis = tctamlbas
			
			If orb_toggle
				orb = New Orb (Player, 10.0, 8.0)
			Else
				orb?.Destroy ()
				orb = Null
			Endif
			
			' Needed or physics fails...
			
			scene.Update ()
			
		Endif

		TempControls ()
		
	End
	




'		canvas.Color = Color.Blue

			' Need to translate orb.constraint.Pivot:Vec3f to world position somehow -- this one isn't working!
			
	'		Local rcpos:Vec2f = cam.ProjectToViewport (orb.model.Position + orb.constraint.Pivot)
	'		DrawCross (canvas, rcpos.x, rcpos.y)

'		canvas.Color = Color.Yellow

'			Local ocpos:Vec2f = cam.ProjectToViewport (orb.model.Position + orb.constraint.ConnectedPivot)
'			DrawCross (canvas, ocpos.x, ocpos.y)
			
'		Local rpos:Vec2f = Game.MainCamera.camera.ProjectToViewport (Player.model.Position)
'		Local opos:Vec2f
		
'		If orb And Not Player.exploded
'			opos = Game.MainCamera.camera.ProjectToViewport (orb.model.Position)
'			canvas.Color = Color.Lime
'			canvas.DrawLine (rpos, opos)
'		Endif
			
			
			
			
			


#End
