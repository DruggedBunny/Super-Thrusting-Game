
Class Pad Extends Behaviour

	Public
	
		Function Create:Pad (x:Float, y:Float, z:Float, size:Float = 8.0)
		
			Local thickness:Float	= 1.0 ' Pass in as param?
			
			Local box:Boxf			= New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			Local model:Model		= Model.CreateBox (box, 2, 2, 2, New PbrMaterial (Color.Grey))
				
				model.Name			= "Pad [spawned at " + Time.Now () + "]"

				model.Move (x, y, z)
			
			Local pad:Pad			= New Pad (model)
			
				pad.collision_box	= box
				
			Return pad
			
		End

		Property PadModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property PadBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Field collision_box:Boxf
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> ()

				collider.Box			= collision_box
				collision_box			= Null ' Not required after creating collider
				
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

				body.Mass				= 0.0
				body.CollisionMask		= COLL_PAD
				body.CollisionGroup		= PAD_COLLIDES_WITH
		
		End
		
End
