
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class RocketParticle Extends Behaviour

	Public
	
		Global SMat:SpriteMaterial
		
		Function Create:RocketParticle (rocket:Rocket, thrust:Vec3f, size:Float = 0.5, fadeout:Float = 0.95)

			If Not SpriteMat Then SpriteInit ()

'			Local sprite:Sprite = New Sprite (SpriteMat [4], rocket.RocketModel)

			' TEMP: Should be as above, but cannot change materials on-the-fly -- mojo3d bug?
			
			Local sprite:Sprite = New Sprite (New SpriteMaterial (), rocket.RocketModel)
		
				sprite.Move (Rnd (-0.1, 0.1), Rnd (-2.1, -2.5), Rnd (-0.1, 0.1))
				
				sprite.Parent				= Null
				sprite.Scale				= New Vec3f (size, size, 1.0)
				sprite.Alpha				= 1.0
				sprite.CastsShadow			= False
				
			Local sp:RocketParticle			= New RocketParticle (sprite)
			
				sp.thrust					= thrust
				sp.update_fader				= fadeout
				
			Return sp
			
		End

	Private
	
		Global SpriteMat:SpriteMaterial []

		Function SpriteInit ()

			' Sprite material array setup...
			
			If SpriteMat Then Return
			
			SpriteMat								= SpriteMat.Resize (5)
			
			For Local loop:Int = 0 Until SpriteMat.Length
				SpriteMat [loop]					= New SpriteMaterial ()
			Next
		
			SpriteMat [0].ColorFactor				= Color.Black
			SpriteMat [1].ColorFactor				= Color.Red
			SpriteMat [2].ColorFactor				= Color.Orange
			SpriteMat [3].ColorFactor				= Color.Yellow
			SpriteMat [4].ColorFactor				= Color.White
				
		End
			
		Method New (entity:Entity)
		
			Super.New (entity)

			AddInstance ()
			
		End

		Method OnStart () Override

			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> () ' Unexpected: Collider needs to be added BEFORE applying impulse!

			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()
' No Boxf!
				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_NOTHING
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				Local cs:Sprite	= Cast <Sprite> (Entity)
				Local sm:SpriteMaterial	= Cast <SpriteMaterial> (cs.Material)

				Local t:Int = Int (color_change * 5.0)
				
				Select Int (color_change * 5.0)
'				sm = SpriteMat [t] ' There are 5 sprite materials
					Case 0
'						Entity.Color = Color.Black
						sm.ColorFactor = Color.Black
					Case 1
'						Entity.Color = Color.Red
						sm.ColorFactor = (Color.Red + (Color.Orange * 0.75) * 0.5)
					Case 2
'						Entity.Color = Color.Orange
						sm.ColorFactor = Color.Orange
					Case 3
'						Entity.Color = Color.Yellow
						sm.ColorFactor = Color.Yellow
					Case 4
'						Entity.Color = Color.White
						sm.ColorFactor = Color.White
				End
'				
				If sm.ColorFactor = Color.Black' = SpriteMat [0]
					Entity.Alpha = Entity.Alpha * (0.96 * Game.Delta)
					Entity.Scale = Entity.Scale * ((1.0 + Rnd (0.033)) * Game.Delta)
					Entity.GetComponent <RigidBody> ().ApplyForce (New Vec3f (0.0, 0.15, 0.0))
				Else
					color_change = color_change * (update_fader * Game.Delta) ' TODO: Needs adjusting for framerate!
				End
				
				' Slow particle down (air resistance)... very dependent on start speed and alpha fade amount...
				
				Entity.GetComponent <RigidBody> ().LinearDamping = (1.0 - color_change)' * 0.95 ' Trial and error!
				
				If Entity.Alpha < 0.075
					Entity.Destroy ()
				Endif
			
			Endif
			
		End
	
		' Rocket thrust level -- need to temp-store here as OnStart can't be passed custom params!
		
		Field thrust:Vec3f
		Field update_fader:Float
		Field color_change:Float = 0.99
		
End
