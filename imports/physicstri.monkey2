
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class PhysicsTri Extends Behaviour

	Public

	
		Global TMP_ELAPSED_AVG:Float
		Global TMP_ELAPSED_LOOPS:Int
		Global TMP_SHOW_ME:Float
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()

			If Not physics_tri_stack Then physics_tri_stack = New Stack <PhysicsTri>
			physics_tri_stack.Add (Self)
			
		End
		
		Property SrcBody:RigidBody ()
			Return src_body
			Setter (body:RigidBody)
				src_body = body
		End
		
		Property FromRocket:Bool ()
			Return from_rocket
			Setter (state:Bool)
				from_rocket = state
		End
		
	Private

		Field physics_tri_stack:Stack <PhysicsTri>
		Field src_body:RigidBody
		
		Field from_rocket:Bool
		
		Method OnStart () Override

			Local model:Model			= Cast <Model> (Entity)
			
			Local collider:BoxCollider	= model.AddComponent <BoxCollider> ()
			
				collider.Box			= model.Mesh.Bounds
			
			Local body:RigidBody		= model.AddComponent <RigidBody> ()

				Game.PhysStack.Add (body)

				body.Mass				= 1.0
				body.Restitution		= 0.25
				body.Friction			= 0.5
				body.AngularDamping		= 1.0
				
				body.CollisionMask		= COLL_TRI
				body.CollisionGroup		= TRI_COLLIDES_WITH
					
			' Tri centre...
			
			Local centroid:Vec3f		= (model.Mesh.GetVertex (0).position + model.Mesh.GetVertex (1).position + model.Mesh.GetVertex (2).position) / 3.0

			' Tri position relative to model centre, range 0-1...
			
			Local core_vec:Vec3f		= ((model.Position + centroid) - model.Position).Normalize ()
			
			' Add velocity...

			Local with_vel:Vec3f		= src_body.LinearVelocity + core_vec * Rnd (1.0, 5.0)
			
			body.ApplyImpulse (with_vel)
			
			' Crumble!
			' ptri.body.ApplyImpulse (body.LinearVelocity)

			' Circular!
			' Local power:Float = 5.0
			' ptri.body.ApplyImpulse (body.LinearVelocity + (model.Basis * New Vec3f (Rnd (-1.0, 1.0), Rnd (-1.0, 1.0), Rnd (-1.0, 1.0))).Normalize () * power)
	
		End
		
		Method OnUpdate (elapsed:Float) Override

			TMP_ELAPSED_AVG = TMP_ELAPSED_AVG + elapsed
			TMP_ELAPSED_LOOPS = TMP_ELAPSED_LOOPS + 1
			
			If TMP_ELAPSED_LOOPS Mod 10 = 0
				TMP_ELAPSED_AVG = TMP_ELAPSED_AVG / 10.0
				TMP_SHOW_ME = TMP_ELAPSED_AVG
				TMP_ELAPSED_AVG = 0
			Endif
			
			If from_rocket
			
				If Game.GameState.GetCurrentState () = States.PlayStarting' Or Game.GameState.GetCurrentState () = States.Playing
					Entity.Destroy ()
				Endif
				
			Else

'				Entity.Alpha = Entity.Alpha * (0.98 * Game.Delta)
				Entity.Alpha = Entity.Alpha * FrameStretch (0.98, elapsed)'((1.0 - elapsed) * 0.98)
			
				If Entity.Alpha < 0.005
					Entity.Destroy ()
				Endif
		
			Endif
			
		End
	
End
