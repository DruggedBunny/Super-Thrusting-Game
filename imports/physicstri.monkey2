
Class PhysicsTri Extends Behaviour

	Public

		Function Explode (model:Model, body:RigidBody)

			For Local mat:Int = 0 Until model.Mesh.NumMaterials
			
				For Local loop:UInt = 0 Until model.Mesh.GetIndices (mat).Length Step 3 * TRI_SKIPPER ' Set in consts.monkey2
					
					Local model:Model		= ModelFromTriangle (model, loop, mat)
					
						model.Parent		= Null
						model.CastsShadow	= False
	
					Local ptri:PhysicsTri	= New PhysicsTri (model)

						ptri.src_body		= body

				Next
			
			Next
		
		End
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()

			If Not PhysicsTriList Then PhysicsTriList = New List <PhysicsTri>
			PhysicsTriList.AddLast (Self)
			
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
		
			Entity.Alpha = Entity.Alpha * 0.9875
			
			If Entity.Alpha < 0.005
				Entity.Destroy ()
			Endif
			
		End
	
	Private

		Global PhysicsTriList:List <PhysicsTri>
		
		Field src_body:RigidBody
		
End
