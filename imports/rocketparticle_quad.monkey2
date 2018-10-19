
Class RocketParticle Extends Behaviour

	Public
	
		' TODO: Make private
		
		Field thrust:Vec3f
		Field update_fader:Float
		Field color_change:Float = 0.99
		
		Field quad_mode:SpriteMode
		Field current_camera:Camera
		
		Global Quad:Model
		
		Function Create:RocketParticle (rocket:Rocket, mat:PbrMaterial, thrust:Vec3f, size:Float = 1.0, fadeout:Float = 0.95)

			size = size * 0.5

			If Not RocketParticle.Quad
			
				RocketParticle.Quad				= New Model (Mesh.CreateRect (New Rectf (-size, -size, size, size)), mat)
	
					RocketParticle.Quad.Visible	= False
					RocketParticle.Quad.Alpha	= 1.0

			Endif
			
			Local quad:Model = RocketParticle.Quad.Copy (rocket.RocketModel)

				quad.Move (0.0, Rnd (-2.0, -2.25), 0.0)

				quad.CastsShadow			= False
				quad.Parent					= Null
				quad.Visible				= True
				
			Local rp:RocketParticle			= New RocketParticle (quad)
			
				rp.thrust					= thrust
				rp.update_fader				= fadeout
				rp.quad_mode				= SpriteMode.Billboard
				rp.current_camera			= Game.MainCamera.Camera3D ' TODO ODODODO
				
				Return rp
								
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

				If quad_mode = SpriteMode.Billboard
					Entity.Rotation = current_camera.Rotation 'New Vec3f (current_camera.Rotation.X, current_camera.Rotation.Y, current_camera.Rotation.Z)
				Else
					Entity.Rotation = New Vec3f (0.0, current_camera.Rotation.Y, 0.0)
				Endif
		
		End
		
		Method OnUpdate (elapsed:Float) Override

			If quad_mode = SpriteMode.Billboard
				Entity.Rotation = current_camera.Rotation 'New Vec3f (current_camera.Rotation.X, current_camera.Rotation.Y, current_camera.Rotation.Z)
			Else
				Entity.Rotation = New Vec3f (0.0, current_camera.Rotation.Y, 0.0)
			Endif

			If Game.GameState.GetCurrentState () <> States.Paused
			
				Local model:Model		= Cast <Model>			(Entity)
				Local mat:PbrMaterial	= Cast <PbrMaterial>	(model.Material)

				Select Int (color_change * 5.0) ' There are 5 sprite materials
					Case 0
						mat.ColorFactor = Color.Black
					Case 1
						mat.ColorFactor = Color.Red
					Case 2
						mat.ColorFactor = Color.Orange
					Case 3
						mat.ColorFactor = Color.Yellow
					Case 4
						mat.ColorFactor = Color.White
				End
				
				If mat.ColorFactor = Color.Black
					Entity.Alpha = Entity.Alpha * 0.975 * Game.Delta ' TODO: Needs adjusting for framerate!
				Else
					color_change = color_change * update_fader ' TODO: Needs adjusting for framerate!
				End
'				
'				' Slow particle down (air resistance)... very dependent on start speed and alpha fade amount...
'				
				Entity.GetComponent <RigidBody> ().LinearDamping = (1.0 - color_change)' * 0.95 ' Trial and error!
				
				If Entity.Alpha < 0.075
					Entity.Destroy ()
				Endif
			
			Endif
			
		End
	
End
