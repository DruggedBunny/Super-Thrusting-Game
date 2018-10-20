
Class RocketParticle Extends Behaviour

	Public
	
		Function Create:RocketParticle (rocket:Rocket, thrust:Vec3f, size:Float = 0.5, fadeout:Float = 0.95)

			Local sprite:Sprite = New Sprite (New SpriteMaterial (), rocket.RocketModel)
		
				Cast <SpriteMaterial> (sprite.Material).ColorFactor = Color.White
				
				'sprite.Move (Rnd (-0.1, 0.1), Rnd (-2.1, -2.5), Rnd (-0.1, 0.1))
				
				sprite.Move (0.0, -2.1, 0.0)
				
				sprite.Parent				= Null
				sprite.Scale				= New Vec3f (size, size, 0.0)
				sprite.Alpha				= 1.0
				sprite.CastsShadow			= False
				'sprite.Mode					= SpriteMode.Fixed
				
			Local sp:RocketParticle			= New RocketParticle (sprite)
			
				sp.thrust					= thrust
				sp.update_fader				= fadeout
				
			Return sp
			
		End

	Private
	
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

				Select Int (color_change * 5.0) ' There are 5 sprite materials
					Case 0
						sm.ColorFactor = Color.Black
					Case 1
						sm.ColorFactor = Color.Red
					Case 2
						sm.ColorFactor = Color.Orange
					Case 3
						sm.ColorFactor = Color.Yellow
					Case 4
						sm.ColorFactor = Color.White
				End
				
				If sm.ColorFactor = Color.Black
					Entity.Alpha = Entity.Alpha * 0.975 * Game.Delta ' TODO: Needs adjusting for framerate!
				Else
					color_change = color_change * update_fader ' TODO: Needs adjusting for framerate!
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
