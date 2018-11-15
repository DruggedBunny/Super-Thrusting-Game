
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class PortalLock Extends Behaviour

	Public

		Function Create:PortalLock (x:Float, y:Float, z:Float, size:Float = 16.0)

			' Wide cylinder?   |___|
			
			' Collider will have to be based on geometry -- open-topped upright cylinder
			
			' Or base on low-to-ground portal?
			
			Local thickness:Float			= 1.0 ' Pass in as param?
			
			Local box:Boxf					= New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			Local model:Model				= Model.CreateBox (box, 2, 2, 2, New PbrMaterial (Color.HotPink))
				
				model.Name					= "PortalLock [spawned at " + Time.Now () + "]"
			
				model.Move (x, y, z)
			
			Local portal_lock:PortalLock	= New PortalLock (model)
			
				portal_lock.collision_box	= box
				
			Return portal_lock
			
		End

		Property PortalLockModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property PortalLockBody:RigidBody ()
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

				Game.PhysStack.Add (body)

				body.Mass				= 0.0
				body.CollisionMask		= COLL_PORTAL_LOCK
				body.CollisionGroup		= PORTAL_LOCK_COLLIDES_WITH
		
		End
		
End
