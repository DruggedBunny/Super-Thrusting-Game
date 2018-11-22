
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' VERY WIP!!! TODO: Separate sphere's rocket/orb collisions -- orb should not collide, but trigger portal.

Class PortalLockSphere Extends Behaviour

	Public

		Function Create:PortalLockSphere (lock:Model, size:Float = 12.0)

				Local sphere:Model			= Model.CreateSphere (size, 32, 32, New PbrMaterial (Color.Silver, 0.15, 0.0), lock)
				
					sphere.Name				= "PortalLockSphere [spawned at " + Time.Now () + "]"
			
					sphere.Alpha			= 0.075
					
					sphere.Move (0.0, 12.0, 0.0)
					
			Local portal_lock_sphere:PortalLockSphere	= New PortalLockSphere (sphere)
			
				portal_lock_sphere.collision_radius	= size

			Return portal_lock_sphere
			
		End

		Property PortalLockSphereModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property PortalLockSphereBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Field collision_radius:Float
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:SphereCollider	= Entity.AddComponent <SphereCollider> ()

				collider.Radius			= collision_radius
				
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

'				Game.PhysStack.Add (body)

				body.Mass				= 0.0
				body.Friction			= 0.0
				body.Restitution		= 1.1
				body.CollisionMask		= COLL_PORTAL_LOCK
				body.CollisionGroup		= PORTAL_LOCK_COLLIDES_WITH

				' Collision response function...
				
				body.Collided += Lambda (other_body:RigidBody)
			
					' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
					
'					If Millisecs () - BumpChannelTime > 250
'			
'						' Make brighter if using debug_alpha to view walls...
'						
'						If DebugAlpha
							Entity.Alpha = 0.75'1.0
							Entity.Color = Color.Red
'						Else
'							Entity.Alpha = 0.5
'						Endif
						
						' Un-pause channel (ie. play)...
						
'						BumpFader.Paused	= False
					
						' Start a new instance playing, but paused...
						
'						BumpFader			= Game.MainMixer.AddFader ("PhysicsTerrain: ", BumpSound.Play (False))
'						BumpFader.Paused	= True
						
						' Reset timer...
						
'						BumpChannelTime		= Millisecs ()
					
'					Endif
					
				End

		End

		Method OnUpdate (elapsed:Float) Override
		
			If Entity.Alpha > 0.075

				Entity.Alpha = Entity.Alpha * FrameStretch (0.85, elapsed)
				Entity.Color = Entity.Color.Blend (Color.Silver, 0.05)
				
				If Entity.Alpha <= 0.075
					Entity.Alpha = 0.075
					Entity.Color = Color.Silver
				Endif
			
			Endif
			
		End
		
End

Class PortalLockRing Extends Behaviour

	Public

		Function Create:PortalLockRing (lock:Model, radius:Float = 8.0)

			' Wide cylinder?   |___|
			
			' Collider will have to be based on geometry -- open-topped upright cylinder
			
			' Or base on low-to-ground portal?
			
			Local thickness:Float			= 1.0 ' Pass in as param?
			
			Local ring:Model				= Model.CreateTorus (radius, 0.5, 16, 16, New PbrMaterial (Color.White, 0.1, 0.0), lock)
				
				ring.Name					= "Lower PortalLockRing [spawned at " + Time.Now () + "]"
				ring.CastsShadow			= False

				Cast <PbrMaterial> (ring.Material).EmissiveFactor = Color.White

				ring.Move (0.0, 8.0, 0.0)
				ring.Rotate (22.5, 0.0, 0.0)
			
				ring.Parent					= Null

			Return New PortalLockRing (ring)
			
		End

		Property PortalLockRingModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property PortalLockRingBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:CylinderCollider	= Entity.AddComponent <CylinderCollider> ()
'				
'				collider.Box			= collision_box
'				collision_box			= Null ' Not required after creating collider
				
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

'				Game.PhysStack.Add (body)

				body.Mass				= 1.0
				body.AngularDamping		= 0.0
				body.CollisionMask		= COLL_NOTHING
		
				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
						
				body.ApplyTorqueImpulse (New Vec3f (0.0, 1.0, 0.0))

		End

		Method OnUpdate (elapsed:Float) Override
			PortalLockRingBody.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
		End
		
End

Class PortalLock Extends Behaviour

	Public

		Function Create:PortalLock (x:Float, y:Float, z:Float, size:Float = 16.0)

			' Wide cylinder?   |___|
			
			' Collider will have to be based on geometry -- open-topped upright cylinder
			
			' Or base on low-to-ground portal?
			
			Local thickness:Float			= 1.0 ' Pass in as param?
			
			Local box:Boxf					= New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			Local model:Model				= Model.CreateBox (box, 2, 2, 2, New PbrMaterial (Color.Lime, 0.5, 0.0))
				
				model.Name					= "PortalLock [spawned at " + Time.Now () + "]"
			
				model.Move (x, y, z)
			
				
'				Local sphere:Model			= Model.CreateSphere (12.0, 32, 32, New PbrMaterial (Color.Silver, 0.15, 0.0), model)
'				
'					sphere.Alpha			= 0.075
'					
'					sphere.Move (0.0, 12.0, 0.0)
'					
'					sphere.Parent = Null
'					Local sb:RigidBody = sphere.AddComponent <RigidBody> ()
'					sb.ApplyImpulse (New Vec3f (0.0, -10.0, 0.0))
'					ExplodeModel (sphere, sb, 4)
					
			Local portal_lock:PortalLock	= New PortalLock (model)
			
				portal_lock.collision_box	= box

			Local sphere:PortalLockSphere = PortalLockSphere.Create (model)
			
			PortalLockRing.Create (model)

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

'				Game.PhysStack.Add (body)

				body.Mass				= 0.0
				body.CollisionMask		= COLL_PORTAL_LOCK
				body.CollisionGroup		= PORTAL_LOCK_COLLIDES_WITH
		
		End
		
End
