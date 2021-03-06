
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class GameCamera

	Public
	
		Property CameraDistance:Float ()
			Return camera_distance
			Setter (distance:Float)
				camera_distance = distance
		End
		
		Property Camera3D:Camera ()
			Return real_camera
			Setter (new_cam:Camera)
				real_camera = new_cam
		End
		
		Method New (viewport:Recti, current_camera:GameCamera, range_far:Float)
			
			If current_camera Then current_camera.Destroy ()
			
			camera_pivot = New Pivot
			
			camera_pivot.Name = "Camera pivot [spawned at " + Time.Now () + "]"
			
			Camera3D			= New Camera (camera_pivot)
			Camera3D.Near		= 0.01
			Camera3D.Far		= range_far * Sqrt (3.0) ' Terrain cube diagonal
			Camera3D.FOV		= 90.0 ' Mojo3d default
			
			Camera3D.Viewport = viewport
	
			Camera3D.Name = "Camera [spawned at " + Time.Now () + "]"
				
			' Chase target -- position camera tries to move towards...
			
			chase_target 					= Model.CreateSphere (1, 32, 32, New PbrMaterial (Color.Red))
			chase_target.Alpha				= 0.5
			chase_target.Material.CullMode	= CullMode.None
			chase_target.Visible			= False
			
			chase_target.Name = "Camera chase target [spawned at " + Time.Now () + "]"
			
			up = New Vec3f (0.0, up_y_default, 0.0)
			
			Reset ()
			
		End
		
		Method Destroy ()
		
			camera_pivot?.Destroy ()
			real_camera?.Destroy ()
			chase_target?.Destroy ()
			
		End
		
		Method Reset ()
	
			Camera3D.FOV = 90.0
	
'			chase_target.Position = New Vec3f (0.0, 0.0, 0.0)
'			camera.Position = New Vec3f (0.0, 15.0, -15.0)
	
			If Not Game Print "No game"
			If Not Game.CurrentLevel Print "No current level"
			
			chase_target.Position = New Vec3f (Game.CurrentLevel.SpawnX, Game.CurrentLevel.SpawnY, Game.CurrentLevel.SpawnZ)
			camera_pivot.Position = New Vec3f (Game.CurrentLevel.SpawnX, Game.CurrentLevel.SpawnY, Game.CurrentLevel.SpawnZ - 10.0)
	
			lastvel = New Vec3f (0, 0, 15)
			prevvel = lastvel
	
		End
		
		Method Update (player:Rocket)
	
			If player.Alive
			
				' Camera positioning...
				
				prevvel = lastvel
				
				If player.RocketBody.LinearVelocity.XZ.Length > 5.0
				' ((1.0 - elapsed) * 
					lastvel = lastvel.Blend (player.RocketBody.LinearVelocity, 0.045 * Game.Delta) ' FUCKFUCKFUCK no elapsed!
'					lastvel = lastvel.Blend (player.RocketBody.LinearVelocity, (1.0 - elapsed) * 0.045)
				Endif
				
				chase_target.Position = (player.RocketModel.Position + up) - lastvel * CameraDistance

				camera_pivot.Move ((chase_target.Position - camera_pivot.Position) * (0.1 * Game.Delta), True)
				camera_pivot.PointAt (player.RocketModel)

				Local cam_dist:Float = Game.Player.RocketModel.Position.Distance (Game.MainCamera.Camera3D.Position)
				
				Local closeup:Float = 10.5
				Local closer:Float = 0.1
				
				' Mess!
				
				If Game.Player.CurrentOrb
					closeup = 18.5
					closer = 0.025
				Endif
				
				If cam_dist < closeup
					Camera3D.FOV = Blend (Camera3D.FOV, TransformRange (cam_dist, 1.0, closeup, 130.0, 90.0), closer * Game.Delta)
					up.Y = Blend (up.Y, 3.0, 0.01 * Game.Delta)
				Else
					Camera3D.FOV = Blend (Camera3D.FOV, 90.0, 0.075 * Game.Delta)
					up.Y = Blend (up.Y, up_y_default, 0.01 * Game.Delta)
				Endif
				
			Else
			
				' Rising camera post-death...
				
				camera_pivot.Move (New Vec3f (0.0, 0.05, -0.05) * Game.Delta)
				Camera3D.FOV = Camera3D.FOV * 0.995
				
			Endif
	
		End
		
		'Method ShortestVec:Vec3f (v1:Vec3f, v2:Vec3f)
		'	If v1.Length < v2.Length Then Return v1 Else Return v2
		'End
		
		'Method LongestVec:Vec3f (v1:Vec3f, v2:Vec3f)
		'	If v1.Length > v2.Length Then Return v1 Else Return v2
		'End
		
		Method Move (tv:Vec3f, localSpace:Bool = False)
			camera_pivot.Move (tv, localSpace)
		End
		
		Method Move (tx:Float, ty:Float, tz:Float)
			camera_pivot.Move (tx, ty, tz)
		End
		
		Method PointAt (target:Entity)
			camera_pivot.PointAt (target)
		End
		
		Method Position (v3:Vec3f)
			camera_pivot.Position = v3
		End

		Method RenderVR (canvas:Canvas)
#If __TARGET__ <> "emscripten"
			canvas.DrawRect	(0, App.ActiveWindow.Height, App.ActiveWindow.Width, -App.ActiveWindow.Height, Game.VR_Renderer.LeftEyeImage)
			canvas.Scale	(App.ActiveWindow.Width / App.ActiveWindow.Width, App.ActiveWindow.Height / App.ActiveWindow.Height)
#Endif
		End
		
	Private
	
		Field camera_pivot:Pivot
		Field real_camera:Camera
		
		Field chase_target:Model
	
		Field lastvel:Vec3f
		Field prevvel:Vec3f
	
		Field up:Vec3f
		Field up_y_default:Float = 1.5
		
		Field camera_distance:Float = 0.55
		
End
