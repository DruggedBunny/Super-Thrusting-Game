
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class RocketParticle Extends Behaviour

	Public
	
		Function Create:RocketParticle (rocket:Rocket, thrust:Vec3f, size:Float = 0.5, fadeout:Float = 0.95)

			Local model:Model = Model.CreateBox (New Boxf (-0.5, -0.5, -0.5, 0.5, 0.5, 0.5), 1, 1, 1, New PbrMaterial (Color.White), rocket.RocketModel)'New Sprite (New SpriteMaterial (), rocket.RocketModel)
		
				model.Move (0.0, -2.1, 0.0)
				
				model.Parent				= Null
				model.Scale					= New Vec3f (size, size, size)
				model.Alpha					= 1.0
				model.CastsShadow			= False
				
			Local sp:RocketParticle			= New RocketParticle (model)
			
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
				Game.PhysStack.Add (body)
				
				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_NOTHING
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				Local cs:Model			= Cast <Model> (Entity)
				Local sm:PbrMaterial	= Cast <PbrMaterial> (cs.Material)
				
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
					Entity.Alpha = Entity.Alpha * (0.95 * Game.Delta) ' TODO: Needs adjusting for framerate!
				Else
					color_change = color_change * update_fader ' TODO: Needs adjusting for framerate!
				End
				
				' Slow particle down (air resistance)... very dependent on start speed and alpha fade amount...
				
				Entity.GetComponent <RigidBody> ().LinearDamping = (1.0 - color_change)
				
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
