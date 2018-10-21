
Class ExplosionParticle Extends Behaviour

	Public
	
		Function Create:ExplosionParticle (rocket:Rocket, thrust:Vec3f, size:Float = 0.5, fadeout:Float = 0.95)

			ExplosionParticle.SpriteInit ()
			
			Local sp:ExplosionParticle
			
			Local sprite:Sprite = New Sprite (SpriteMat [Int (Rnd (5))], rocket.RocketModel)
		
				'sprite.Move (Rnd (-0.1, 0.1), Rnd (-2.1, -2.5), Rnd (-0.1, 0.1))
				
				sprite.Parent				= Null
				sprite.Scale				= New Vec3f (size, size, size)
				sprite.Alpha				= 1.0 ' TMP

			sp								= New ExplosionParticle (sprite)
			
			sp.thrust						= thrust
			sp.update_fader					= fadeout

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

				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_NOTHING
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				Entity.Alpha = Entity.Alpha * (update_fader * Game.Delta) ' TODO: Needs adjusting for framerate!
				
				' Slow particle down (like air resistance)... very dependent on start speed and alpha fade amount...
				
				Entity.GetComponent <RigidBody> ().LinearDamping = (1.0 - Entity.Alpha)' * 0.95 ' Trial and error!
				
				If Entity.Alpha < 0.075
					Entity.Destroy ()
				Endif
			
			Endif
			
		End
	
		' Rocket thrust level -- need to temp-store here as OnStart can't be passed custom params!
		
		Field thrust:Vec3f
		Field update_fader:Float
		
End
