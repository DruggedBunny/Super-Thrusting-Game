
' Quick port of http://mojolabs.nz/codearcs.php?code=2364
' ID: 2364
' Author: Queller
' Date: 2008-11-26 17:10:55
' Title: Gaussian Blur Filter
' Description: A true Gaussian blur filter

' NB. Copyright notice: declared as 'Public Domain' via original www.blitzbasic.com code submission.
' https://web.archive.org/web/20141229185926/http://www.blitzbasic.com/

Function GaussianBlur:Pixmap(tex:Pixmap, radius:Int)
	If radius <=0 Return tex
	
	If tex.Format <> PixelFormat.RGBA8 Then tex = tex.Convert (PixelFormat.RGBA8)
	
	Local texclone:Pixmap = tex.Copy()			'clone incoming texture
	Local filter:GaussianFilter = New GaussianFilter		'instantiate a new gaussian filter
		filter.radius = radius					'configure it
	Return filter.apply(tex, texclone)
End Function

Class GaussianFilter

	Field radius:Double
	Field kernel:Kernel
	
	Method apply:Pixmap(src:Pixmap, dst:Pixmap)
		kernel = makekernel(radius)
		convolveAndTranspose(kernel, src, dst, src.Width, src.Height, True)
		convolveAndTranspose(kernel, dst, src, dst.Height, dst.Width, True)
		dst = Null
		GCCollect()
		Return src
	End Method

'Make a Gaussian blur kernel.

	Method makekernel:Kernel(radius:Double)
		Local r:Int = Int(Ceil(radius))
		Local rows:Int = r*2+1
		Local matrix:Double[] = New Double[rows]
		Local sigma:Double = radius/3.0
		Local sigma22:Double = 2*sigma*sigma
		Local sigmaPi2:Double = 2*Pi*sigma
		Local sqrtSigmaPi2:Double = Sqrt(sigmaPi2)
		Local radius2:Double = radius*radius
		Local total:Double = 0
		Local index:Int = 0

		For Local row:Int = -r To r
			Local distance:Double = Double(row*row)
			If (distance > radius2)
				matrix[index] = 0
			Else
				matrix[index] = Double(Exp(-(distance/sigma22)) / sqrtSigmaPi2)
				total = total + matrix[index]
				index = index + 1
			End If
		Next

		For Local i:Int = 0 Until rows
			matrix[i] = matrix[i]/total			'normalizes the gaussian kernel
		Next 

		Return mkernel(rows, 1, matrix)
	End Method
	
	Function mkernel:Kernel(w:Int, h:Int, d:Double[])
		Local k:Kernel = New Kernel
			k.width = w
			k.height = h
			k.data = d
		Return k
	End Function


	Method convolveAndTranspose(kernel:Kernel, in:Pixmap, out:Pixmap, width:Int, height:Int, alpha:Int)
		Local inba:UByte Ptr = in.Data
		Local outba:UByte Ptr = out.Data
		Local matrix:Double[] = kernel.getKernelData()
		Local cols:Int = kernel.getWidth()
		Local cols2:Int = cols/2
		
		For Local y:Int = 0 Until height
			Local index:Int = y
			Local ioffset:Int = y*width
				For Local x:Int = 0 Until width
					Local r:Double = 0, g:Double = 0, b:Double = 0, a:Double = 0
					Local moffset:Int = cols2
						For Local col:Int = -cols2 To cols2
							Local f:Double = matrix[moffset+col]
					If (f <> 0)
						Local ix:Int = x+col
						If ( ix < 0 )
							ix = 0
						Else If ( ix >= width)
							ix = width-1
						End If
						
						Local rgb:Int = Cast <Int Ptr> (inba)[ioffset+ix] ' Was Int Ptr inba
						a = a + f *((rgb Shr 24) & $FF)
						b = b + f *((rgb Shr 16) & $FF)
						g = g + f *((rgb Shr 8) & $FF)
						r = r + f *(rgb & $FF)
					End If
				Next
				Local ia:Int
					If alpha = True Then ia = clamp(Int(a+0.5)) Else ia = $FF
				Local ir:Int =clamp( Int(r+0.5))
				Local ig:Int = clamp(Int(g+0.5))
				Local ib:Int = clamp(Int(b+0.5))
				Cast <Int Ptr> (outba)[index] =((ia Shl 24) | (ib Shl 16) | (ig Shl 8) | (ir Shl 0)) ' Was Int Ptr outba
				index = index + height
				Next
		Next
	End Method
End

Class Kernel

	Field width:Int
	Field height:Int
	Field data:Double[]
	
	Method getKernelData:Double[]()
		Return data
	End Method
	
	Method getWidth:Int()
		Return width
	End Method
	
	Method getHeight:Int()
		Return height
	End Method

End

Function clamp:Int(val:Int)
If val < 0
	Return 0
ElseIf val > 255
	Return 255
Else
	Return val
EndIf
End Function
