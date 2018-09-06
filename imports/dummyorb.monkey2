
Class DummyOrb

	Field model:Model
	Field body:RigidBody
	Field collider:SphereCollider
	
	Method New (x:Float, y:Float, z:Float)

		Local mat:PbrMaterial = New PbrMaterial (Color.HotPink)
			
		model		= Model.CreateSphere (0.75, 8, 8, mat)

			model.Move (x, y, z)
			
		body						= model.AddComponent <RigidBody> ()
		collider					= model.AddComponent <SphereCollider> ()

		body.Mass					= 0.0
		body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
			
		body.CollisionMask			= COLL_DUMMY_ORB
		body.CollisionGroup			= DUMMY_ORB_COLLIDES_WITH

		body.Collided += Lambda (other_body:RigidBody) ' Other colliding body
			
			Print "Dummy Orb colliding " + Millisecs ()
			
		End

	End
	
End
