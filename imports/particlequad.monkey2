
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class ParticleQuad
	
	Field model:Model
	
	Method New (color:Color, parent:Entity = Null)
	
		Local mat:Material = New PbrMaterial (color)
		
		model = New Model (CreateQuad (), mat, parent)
		
	End
	
	Method CreateQuad:Mesh (width:Float = 1.0, height:Float = 1.0)
	
	#Rem
	
		SHARED VERTEX VERSION:
		
				Triangle #1 formed by vertices v0, v1 and v2:
				
				Triangle index 0 points to v0
				Triangle index 1 points to v1
				Triangle index 2 points to v2
				
				o v0 -----------o v1
				 \				|
				  \				|
				   \			|
				    \			|
				     \			|
				      \			|
				       \		|
				        \		|
				         \		|
				          \		|
				           \	|
				            \	|
				             \	|
				              \	|
				               \|
				X v3			o v2
				
				Triangle #2 formed by vertices v0, v2 and v3:
	
				Triangle index 3 points to v2
				Triangle index 4 points to v3
				Triangle index 5 points to v0
	
				o v0			o v1
				|\
				| \
				|  \
				|   \
				|    \
				|     \
				|      \
				|       \
				|        \
				|         \
				|		   \
				|           \
				|            \
				|             \
				|              \
				X v3 -----------o v2
				
	#End
	
		' Raw vertices:
	
		Local vertices:Vertex3f [] = New Vertex3f [4]
		
			vertices [0].position = New Vec3f (0.0, 0.0, 0.0)
			vertices [1].position = New Vec3f (width, 0.0, 0.0)
			vertices [2].position = New Vec3f (width, -height, 0.0)	
			vertices [3].position = New Vec3f (0.0, -height, 0.0)
		
		' Each triangle index 'points' to a specific vertex:
	
		Local triangle_indices:UInt [] = New UInt [6]
		
			triangle_indices [0] = 0
			triangle_indices [1] = 1
			triangle_indices [2] = 2
	
			' Re-using bottom-right and top-left vertices, only index 4 being new...
			
			triangle_indices [3] = 2
			triangle_indices [4] = 3
			triangle_indices [5] = 0
	
		Local mesh:Mesh = New Mesh (vertices, triangle_indices)
		
		Return mesh
		
	End
	
End
