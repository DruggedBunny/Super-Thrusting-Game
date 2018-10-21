
Class PhysicsTri Extends Behaviour

	Public

		Function Explode (model:Model, body:RigidBody, chunk:UInt = 0, explosion_particles:Int = 500)

			Local particle_vel:Float = 1.0

			'QuickTimer.Start ()
			
			For Local particles:Int = 0 Until explosion_particles

				Local angle:Vec3f = Game.Player.RocketModel.Basis * New Vec3f (
				
									Rnd (-particle_vel, particle_vel),
									Rnd (-particle_vel, particle_vel),
									Rnd (-particle_vel, particle_vel))			.Normalize () * Rnd (particle_vel)

				ExplosionParticle.Create	(	Game.Player,		' Rocket
												angle,				' 3D angle
												Rnd (0.1, 1.0),		' Size
												0.99)				' Fadeout-multiplier

			Next
			
			'QuickTimer.Stop ()

			For Local mat:Int = 0 Until model.Mesh.NumMaterials
			
				' TESTING...
				
				Local mat_tris:UInt = model.Mesh.GetIndices (mat).Length / 3
				
				If Not chunk Then chunk = Max (12, Int (Rnd (mat_tris)))

				' Going through triangles of each material in turn...
				
				For Local tri:UInt = 0 Until model.Mesh.GetIndices (mat).Length Step 3 * chunk * TRI_SKIPPER ' Set in consts.monkey2
				
					Local model:Model		= ModelFromTriangles (model, tri, chunk, mat)
					
						model.Parent		= Null
						model.CastsShadow	= False
	
					Local ptri:PhysicsTri	= New PhysicsTri (model)

						ptri.src_body		= body

				Next
			
			Next
		
		End
		
	Private

		Global PhysicsTriStack:Stack <PhysicsTri>
		
		Field src_body:RigidBody
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()

			If Not PhysicsTriStack Then PhysicsTriStack = New Stack <PhysicsTri>
			PhysicsTriStack.Add (Self)
			
		End
		
		Method OnStart () Override

			Local model:Model			= Cast <Model> (Entity)
			
			Local collider:BoxCollider	= model.AddComponent <BoxCollider> ()
			
				collider.Box			= model.Mesh.Bounds
			
			Local body:RigidBody		= model.AddComponent <RigidBody> ()

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
		
			Entity.Alpha = Entity.Alpha * (0.97 * Game.Delta)
			
			If Entity.Alpha < 0.005
				Entity.Destroy ()
			Endif
			
		End
	
End
