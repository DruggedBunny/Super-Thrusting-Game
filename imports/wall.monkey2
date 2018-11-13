
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' Bouncy wall used for level borders and ceiling. Cool flash effect on colliding!

' A touch over-complicated by DebugAlpha, which makes walls easily viewable, called
' via TrumpWall.SetDebugAlpha (value)...

' Held in a collection, TrumpWall, in PhysicsTerrain...

Class Wall Extends Behaviour

	Public

		' Yuk! Thought Behaviour.Destroy would do this!
		
		Method Remove ()
			Entity.Destroy ()
		End
		
		Property DebugAlpha:Float ()
		
			Return debug_alpha
			
			Setter (new_alpha:Float)
			
				debug_alpha		= new_alpha
				WallModel.Alpha	= debug_alpha
				
		End
		
		Function InitSound ()
	
			BumpSound = Sound.Load (ASSET_PREFIX_AUDIO + "wall_bump.ogg")
			
				If Not BumpSound Then Abort ("PhysicsTerrain/Wall: InitSound failed to load wall-bump audio!")

		End

		Function Create:Wall (box:Boxf, pos:Vec3f, y_rotation:Float, material:PbrMaterial, name:String = "")

			Local thickness:Float	= 1.0 ' Pass in as param?
			
			'Local box:Boxf			= New Boxf (-size * 0.5, -thickness * 0.5, -size * 0.5, size * 0.5, thickness * 0.5, size * 0.5)
			
			Local model:Model		= Model.CreateBox (box, 2, 2, 2, material)
				
				model.Name			= name + " [spawned at " + Time.Now () + "]"

				model.Rotate (0.0, y_rotation, 0.0)
				model.Move (pos)
			
			Local wall:Wall			= New Wall (model)
			
				wall.collision_box	= box
				
			model.Alpha				= wall.DebugAlpha
			
			Return wall
			
		End

		Property WallModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property WallBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Global BumpSound:Sound
		Global BumpFader:Fader
		Global BumpChannelTime:Int
		
		Field collision_box:Boxf
		Field debug_alpha:Float = 0.0
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override

			' Sound for bumping into invisible walls at outer edge of terrain/upper ceiling limit...
	
			If Not BumpFader
			
				BumpFader			= Game.MainMixer.AddFader ("PhysicsTerrain: Bump", BumpSound.Play (False))
				BumpFader.Paused	= True
				
				BumpChannelTime		= Millisecs ()
				
			Endif
			
			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> ()

				collider.Box			= collision_box
				collision_box			= Null ' Not required after creating collider
				
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

				body.Mass				= 0.0
				body.Restitution		= 1.0 ' Bouncy!
				
				body.CollisionMask		= COLL_WALL
				body.CollisionGroup		= WALL_COLLIDES_WITH

				' Collision response function...
				
				body.Collided += Lambda (other_body:RigidBody)
			
					' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
					
					If Millisecs () - BumpChannelTime > 250
			
						' Make brighter if using debug_alpha to view walls...
						
						If DebugAlpha
							Entity.Alpha = 1.0
						Else
							Entity.Alpha = 0.5
						Endif
						
						' Un-pause channel (ie. play)...
						
						BumpFader.Paused	= False
					
						' Start a new instance playing, but paused...
						
						BumpFader			= Game.MainMixer.AddFader ("PhysicsTerrain: ", BumpSound.Play (False))
						BumpFader.Paused	= True
						
						' Reset timer...
						
						BumpChannelTime		= Millisecs ()
					
					Endif
					
				End

		End
		
		Method OnUpdate (elapsed:Float) Override
		
			If Entity.Alpha > DebugAlpha

				Local stretch:Float = 0.85
				
				If DebugAlpha > 0.5 Then stretch = 0.99
				
				Entity.Alpha = Entity.Alpha * FrameStretch (stretch, elapsed)
				
				If Entity.Alpha <= 0.01
					Entity.Alpha = DebugAlpha
				Endif
			
			Endif
			
		End
		
End
