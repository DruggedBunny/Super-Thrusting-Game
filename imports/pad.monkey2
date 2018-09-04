
Class Pad

	Public
	
		Method New (x:Float, y:Float, z:Float, size:Float = 8.0)
		
			Local thickness:Float = 1.0 ' Pass in as param?
			
			Local box:Boxf = New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			model = Model.CreateBox (box, 2, 2, 2, New PbrMaterial (Color.Grey))
			
			model.Name = "Pad [spawned at " + Time.Now () + "]"
			
			model.Move (x, y, z)
			
			collider = model.AddComponent <BoxCollider> ()
			collider.Box = box
	
			body = model.AddComponent <RigidBody> ()
			body.Mass = 0.0
	
			body.CollisionMask	= COLL_PAD
			body.CollisionGroup	= PAD_COLLIDES_WITH

		End

	Property PadModel:Model ()
		Return model
	End
	
	Property PadBody:RigidBody ()
		Return body
	End
	
	Private

		Field model:Model				' mojo3d Model
		Field collider:BoxCollider		' Bullet physics collider
		Field body:RigidBody			' Bullet physics body
	
		Field color:Color
		
End
