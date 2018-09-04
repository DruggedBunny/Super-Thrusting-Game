
Class PhysicsTri

	Public
	
		Method New ()
		
			' Uses a list rather than a component -- only used to clear after death,
			' no manual update involved...
			
			If Not PhysicsTriList Then PhysicsTriList = New List <PhysicsTri>
			PhysicsTriList.AddLast (Self)
			
		End
	
		Method Destroy:Void ()
			model?.Destroy ()
			If body Then body = Null
		End
	
		Function Explode (model:Model, body:RigidBody)

			For Local mat:Int = 0 Until model.Mesh.NumMaterials
			
				For Local loop:UInt = 0 Until model.Mesh.GetIndices (mat).Length Step 3 * TRI_SKIPPER ' Set in consts.monkey2
					
					Local ptri:PhysicsTri		= New PhysicsTri
					
					ptri.model					= ModelFromTriangle (model, loop, mat)
					
					ptri.model.Parent			= Null
					ptri.model.CastsShadow		= False
	
					ptri.collider				= ptri.model.AddComponent <BoxCollider> ()
					ptri.collider.Box			= ptri.model.Mesh.Bounds
					
					ptri.body					= ptri.model.AddComponent <RigidBody> ()
					ptri.body.Mass				= 1.0
					ptri.body.Restitution		= 0.25
					ptri.body.Friction			= 0.5
					ptri.body.AngularDamping	= 1.0
					
					ptri.body.CollisionMask		= COLL_TRI
					ptri.body.CollisionGroup	= TRI_COLLIDES_WITH
					
					' Tri centre...
					
					Local centroid:Vec3f	= (ptri.model.Mesh.GetVertex (0).position + ptri.model.Mesh.GetVertex (1).position + ptri.model.Mesh.GetVertex (2).position) / 3.0
	
					' Tri position relative to model centre, range 0-1...
					
					Local core_vec:Vec3f	= ((model.Position + centroid) - model.Position).Normalize ()
					
					' Add velocity...

					Local with_vel:Vec3f	= body.LinearVelocity + core_vec * Rnd (1.0, 5.0)
					' Boom!
					
					ptri.body.ApplyImpulse (with_vel)
					
					' Crumble!
					' ptri.body.ApplyImpulse (body.LinearVelocity)
	
					' Circular!
					' Local power:Float = 5.0
					' ptri.body.ApplyImpulse (body.LinearVelocity + (model.Basis * New Vec3f (Rnd (-1.0, 1.0), Rnd (-1.0, 1.0), Rnd (-1.0, 1.0))).Normalize () * power)
	
				Next
			
			Next
		
		End
		
		Function Clear ()
	
			If PhysicsTri.PhysicsTriList
	
				For Local pt:PhysicsTri = Eachin PhysicsTri.PhysicsTriList
					pt.Destroy ()
				Next
	
				PhysicsTri.PhysicsTriList.Clear ()
	
			Endif
	
		End
	
	Private

		Global PhysicsTriList:List <PhysicsTri>
		
		Field model:Model
		Field body:RigidBody
		Field collider:BoxCollider
	
End
