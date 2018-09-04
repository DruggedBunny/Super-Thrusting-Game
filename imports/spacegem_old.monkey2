
'Class SpaceGem
'
'	Public
'
'		Method New (x:Float, y:Float, z:Float, size:Float = 1.0, color:Color = Null)
'
'			If Not CollectedSound Then CollectedSound = Sound.Load (ASSET_PREFIX_AUDIO + "collected.ogg")
'			
'			If Not CollectedSound Then Abort ("SpaceGem: Failed to load collected audio!")
'			
'			Local box:Boxf = New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5)
'			
'			If Not color Then color = Color.Red
'			
'			model = Model.CreateBox (box, 1, 1, 1, New PbrMaterial (color))
'			Cast <PbrMaterial> (model.Material).MetalnessFactor = 1.0
'
'			model.Move (x, y + size * 3.0, z)
'			model.Alpha = 0.5
'	
'			collider = model.AddComponent <BoxCollider> ()
'			collider.Box = box
'	
'			body = model.AddComponent <RigidBody> ()
'			body.Mass = 1.0
'			body.AngularDamping = 0.0
'			body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
'	
'			body.CollisionMask	= COLL_GEM
'			body.CollisionGroup	= GEM_COLLIDES_WITH
'			
'			body.ApplyTorqueImpulse (New Vec3f (1.0, 2.0, 4.0))
'		
'			body.Collided += Lambda (other_body:RigidBody)
'	
'				If Not collected
'	
'					Cast <PbrMaterial> (model.Material).ColorFactor = Color.Lime
'					
'					model.Scale = model.Scale * 1.2
'	
'					collected_channel = CollectedSound.Play (False)
'					collected_channel.Volume = 0.25
'					
'					Game.CurrentLevel.SpaceGemCollected ()
'	
'					collected = True
'					
'				Endif
'	
'			End
'
'			behaviour = model.AddComponent <SpaceGemBehaviour> ()
'			behaviour.gem = Self
'			
'			Game.CurrentLevel.SpaceGemAdded ()
'			
'		End
'		
'		Method Destroy ()
'			model?.Destroy ()
'			If body Then body = Null
'		End
'	
'	Private
'
'		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
'	
'		Global CollectedSound:Sound
'		
'		Field collected_channel:Channel
'	
'		Field model:Model
'		Field behaviour:SpaceGemBehaviour
'	
'		Field body:RigidBody			' Bullet physics body
'		Field collider:BoxCollider		' Bullet physics collider
'	
'		Field collected:Bool = False
'		
'End
'
'Class SpaceGemBehaviour Extends Behaviour
'	
'	Field gem:SpaceGem
'	
'	Method New (entity:Entity)
'		
'		Super.New (entity)
'		
'		AddInstance ()
'
'	End
'	
'	Method OnUpdate (elapsed:Float) Override
'	
'		Entity.GetComponent <RigidBody> ()?.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
'
'		If gem.collected
'
'			Local secs_per_frame:Float = 1000.0 / App.FPS
'			
'			gem.model.Alpha = gem.model.Alpha - (THOUSANDTH * secs_per_frame) * 0.25 ' Don't get why 0.25 scales this to 1 sec!
'			
'			If gem.model.Alpha > THOUSANDTH
'				gem.body.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -5.0, 1.0)) ' Boost upwards...
'			Else
'			
'				Destroy ()
'				
'				gem?.model?.Destroy ()
'				gem?.model = Null
'				
'				gem.body = Null
'				gem = Null
'				
'			Endif
'			
'		Endif
'		
'	End
'	
'End
'