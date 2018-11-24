
' This class holds a collection of Behaviours (physics-controlled entities in this case)...

Class PortalLock

	Public

		Method New (x:Float, y:Float, z:Float, size:Float = 16.0)

			' Basic sphere model, later used for visible glass sphere (collides with rocket) and
			' invisible sphere, used for orb collision detection without physics response...
			
			ProtoSphere			= Model.CreateSphere (12.0, 32, 32, New PbrMaterial (Color.Silver, 0.15, 0.0))
			ProtoSphere.Visible = False

			' Parts of PortalLock...
			
			' Pad:				the main lime-green pad
			' Ring:				the rotating white ring
			' Sphere:			the visible 'glass' sphere
			' SphereContact:	the invisible sphere used to detect orb contact
			
			Pad					= PortalLockPad.Create (Self, x, y, z)
			Ring				= PortalLockRing.Create (Self)
			Sphere				= PortalLockSphere.Create (Self)
			SphereContact		= PortalLockSphereContact.Create (Self)
			
			' Don't need this any more...
			
			ProtoSphere.Destroy ()
			
		End

		' ---------------------------------------------------------------------
		' Pad...
		' ---------------------------------------------------------------------
		
		Property Pad:PortalLockPad ()
			Return lock_pad
			Setter (pad:PortalLockPad)
				lock_pad = pad
		End
	
		Property PadModel:Model ()
			Return Cast <Model> (Pad.Entity)
		End
	
		Property PadBody:RigidBody ()
			Return Pad.Entity.GetComponent <RigidBody> ()
		End

		' ---------------------------------------------------------------------
		' Ring...
		' ---------------------------------------------------------------------

		Property Ring:PortalLockRing ()
			Return lock_ring
			Setter (ring:PortalLockRing)
				lock_ring = ring
		End

		Property RingModel:Model ()
			Return Cast <Model> (Ring.Entity)
		End
			
		Property RingBody:RigidBody ()
			Return Ring.Entity.GetComponent <RigidBody> ()
		End

		' ---------------------------------------------------------------------
		' Sphere...
		' ---------------------------------------------------------------------
	
		Property Sphere:PortalLockSphere ()
			Return lock_sphere
			Setter (sphere:PortalLockSphere)
				lock_sphere = sphere
		End
		
		Property SphereModel:Model ()
			Return Cast <Model> (lock_sphere.Entity)
		End
			
		Property SphereBody:RigidBody ()
			Return lock_sphere.Entity.GetComponent <RigidBody> ()
		End
		
		' ---------------------------------------------------------------------
		' Sphere contact...
		' ---------------------------------------------------------------------

		Property SphereContact:PortalLockSphereContact ()
			Return lock_sphere_contact
			Setter (sphere_contact:PortalLockSphereContact)
				lock_sphere_contact = sphere_contact
		End

		Property SphereContactModel:Model ()
			Return Cast <Model> (lock_sphere_contact.Entity)
		End
			
		Property SphereContactBody:RigidBody ()
			Return lock_sphere_contact.Entity.GetComponent <RigidBody> ()
		End
	
		' ---------------------------------------------------------------------
		' Prototype sphere model...
		' ---------------------------------------------------------------------
		
		Property ProtoSphere:Model ()
			Return proto_sphere
			Setter (model:Model)
				proto_sphere = model
		End

		' ---------------------------------------------------------------------
		' Portal lock status...
		' ---------------------------------------------------------------------

		Property Unlocked:Bool ()
			Return unlocked
			Setter (state:Bool)
				Local current:Bool = unlocked
				unlocked = state
				If current <> unlocked
					LockStatusChanged = True
				Else
					LockStatusChanged = False
				Endif
		End

		Property LockStatusChanged:Bool ()
			Return lock_status_changed
			Setter (state:Bool)
				lock_status_changed = state
		End

		Method Reset ()
			Unlocked = True
		End
		
	Private

		Field proto_sphere:Model
		
		Field lock_pad:PortalLockPad
		Field lock_ring:PortalLockRing
		Field lock_sphere:PortalLockSphere
		Field lock_sphere_contact:PortalLockSphereContact
		
		Field unlocked:Bool
		Field lock_status_changed:Bool
		
End

Class PortalLockSphereContact Extends Behaviour

	Public

		Function Create:PortalLockSphereContact (belongs_to:PortalLock, size:Float = 12.0)

			Local sphere:Model											= belongs_to.ProtoSphere.Copy (belongs_to.SphereModel)
			
				sphere.Name												= "PortalLockSphereContact [spawned at " + Time.Now () + "]"
				sphere.Alpha											= 0.0
				sphere.Visible											= True
				sphere.LocalPosition									= New Vec3f (0.0, 0.0, 0.0)
				sphere.Parent											= Null
				
			Local portal_lock_sphere_contact:PortalLockSphereContact	= New PortalLockSphereContact (sphere)
			
				portal_lock_sphere_contact.collision_radius				= size
				portal_lock_sphere_contact.Parent						= belongs_to

			Return portal_lock_sphere_contact
			
		End

		Property Parent:PortalLock ()
			Return parent
			Setter (p:PortalLock)
				parent = p
		End
		
	Private
	
		Field parent:PortalLock
		Field collision_radius:Float
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:SphereCollider	= Entity.AddComponent <SphereCollider> ()

				collider.Radius				= collision_radius
				
			Local body:RigidBody			= Entity.AddComponent <RigidBody> ()

				body.Mass					= 0.0
				body.Friction				= 0.0
				body.Restitution			= 1.1
				body.CollisionMask			= COLL_PORTAL_LOCK_SPHERE_COLLIDER
				body.CollisionGroup			= PORTAL_LOCK_SPHERE_COLLIDER_COLLIDES_WITH

				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
				
				' Collision response function...
				
				body.Collided += Lambda (other_body:RigidBody)
				
					Game.Player.CurrentOrb.Destroy (False)
					
					Parent.Unlocked = True
					
'					Game.CurrentLevel.ExitPortal.Open ()
					
					' TEMP!
'					Local pos:Vec3f = Entity.Position
'					Local d:DummyOrb = New DummyOrb (pos.X, pos.Y, pos.Z)
'					d.DummyOrbModel.Scale = New Vec3f (2.0, 2.0, 2.0)
'					
					' Spawn dummy orb here!
					
				End

		End

End

Class PortalLockSphere Extends Behaviour

	Public

		Function Create:PortalLockSphere (belongs_to:PortalLock)

			Local sphere:Model							= belongs_to.ProtoSphere.Copy ()
			
				sphere.Name								= "PortalLockSphere [spawned at " + Time.Now () + "]"
				sphere.Alpha							= 0.075
				sphere.Visible							= True
				
				sphere.Parent							= belongs_to.PadModel
				
					sphere.LocalPosition				= New Vec3f (0.0, 0.0, 0.0)
					sphere.Move (0.0, 12.0, 0.0)
					
				sphere.Parent							= Null

			Local portal_lock_sphere:PortalLockSphere	= New PortalLockSphere (sphere)
			
				portal_lock_sphere.collision_radius		= sphere.Mesh.Bounds.Width * 0.5
				portal_lock_sphere.Parent				= belongs_to
				
			Return portal_lock_sphere
			
		End

		Property Parent:PortalLock ()
			Return parent
			Setter (p:PortalLock)
				parent = p
		End
		
	Private
	
		Field parent:PortalLock
		Field collision_radius:Float
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:SphereCollider	= Entity.AddComponent <SphereCollider> ()

				collider.Radius				= collision_radius
				
			Local body:RigidBody			= Entity.AddComponent <RigidBody> ()

				body.Mass					= 0.0
				body.Friction				= 0.0
				body.Restitution			= 1.1
				body.CollisionMask			= COLL_PORTAL_LOCK_SPHERE
				body.CollisionGroup			= PORTAL_LOCK_SPHERE_COLLIDES_WITH

				' Collision response function...
				
				body.Collided += Lambda (other_body:RigidBody)
				
					Entity.Alpha = 0.75
					Entity.Color = Color.Red
					
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

' The tilted, rotating ring... does nothing practical, has RigidBody only so it can be
' managed/updated as a physics object via Scene.Update ().

Class PortalLockRing Extends Behaviour

	Public

		Function Create:PortalLockRing (belongs_to:PortalLock, radius:Float = 8.0)

			Local ring_model:Model		= Model.CreateTorus (radius, 0.5, 16, 16, New PbrMaterial (Color.DarkGrey, 0.0, 1.0), belongs_to.PadModel)
				
				ring_model.Name			= "PortalLockRing [spawned at " + Time.Now () + "]"
				ring_model.CastsShadow	= False

				ring_model.Move (0.0, radius, 0.0)
				ring_model.Rotate (22.5, 0.0, 0.0)
			
				ring_model.Parent		= Null

				Cast <PbrMaterial> (ring_model.Material).EmissiveFactor = Color.Black

			Local ring:PortalLockRing	= New PortalLockRing (ring_model)
			
				ring.Parent				= belongs_to
				ring.model				= ring_model
				
			Return ring
			
		End

		Property Parent:PortalLock ()
			Return parent
			Setter (p:PortalLock)
				parent = p
		End
		
	Private
	
		Field parent:PortalLock
		Field body:RigidBody
		Field model:Model
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override

			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> () ' RigidBody won't work without a collider...
			
			body						= Entity.AddComponent <RigidBody> ()

				body.Mass				= 1.0
				body.AngularDamping		= 0.0

				body.CollisionMask		= COLL_NOTHING
				
				' Start spinning! No damping, so just keeps going...
				
				body.ApplyTorqueImpulse (New Vec3f (0.0, 1.0, 0.0))

		End

		Method OnUpdate (elapsed:Float) Override
		
			' Apply negative gravity per-update to keep hovering...
			
			body.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
			
			Local pbrm:PbrMaterial = Cast <PbrMaterial> (model.Material)
			
			If Parent.LockStatusChanged

				If Parent.Unlocked
					pbrm.ColorFactor		= Color.White
					pbrm.EmissiveFactor		= Color.Lime
					pbrm.MetalnessFactor	= 0.1
					pbrm.RoughnessFactor	= 0.0
				Else
					pbrm.ColorFactor		= Color.DarkGrey
					pbrm.EmissiveFactor		= Color.Black
					pbrm.MetalnessFactor	= 0.0
					pbrm.RoughnessFactor	= 1.0
				Endif
			
				Parent.LockStatusChanged	= False
			
			Endif
			
		End
		
End

Class PortalLockPad Extends Behaviour

	Public
	
		Function Create:PortalLockPad (belongs_to:PortalLock, x:Float, y:Float, z:Float, size:Float = 16.0)

			Local thickness:Float				= 1.0
			Local box:Boxf						= New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			Local pad:Model						= Model.CreateBox (box, 2, 2, 2, New PbrMaterial (Color.Lime, 0.5, 0.0))
				
				pad.Name						= "PortalLockPad [spawned at " + Time.Now () + "]"
				pad.Move (x, y, z)
			
			Local portal_lock_pad:PortalLockPad	= New PortalLockPad (pad)
			
				portal_lock_pad.collision_box	= box
				portal_lock_pad.Parent			= belongs_to
				
			Return portal_lock_pad
			
		End
		
		Property Parent:PortalLock ()
			Return parent
			Setter (p:PortalLock)
				parent = p
		End
		
	Private
	
		Field parent:PortalLock
		Field collision_box:Boxf
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override
		
			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> ()

				collider.Box			= collision_box
				collision_box			= Null
				
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

				body.Mass				= 0.0
				body.CollisionMask		= COLL_PORTAL_LOCK_PAD
				body.CollisionGroup		= PORTAL_LOCK_PAD_COLLIDES_WITH
		
		End
		
End
