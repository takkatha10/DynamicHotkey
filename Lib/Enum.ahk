/*
	Enum
	# Required files
	# Utility.ahk
	# Math.ahk
	# Array.ahk
*/
class EnumObject
{
	; Constructor
	__New(args*)
	{
		For index, param In args
		{
			params := StrSplit(param, ",")
			this.Set(params[1], params[2])
		}
	}

	; Getter
	__Get(key)
	{
		If (IsType(key, "Digit"))
		{
			Return InArray(this.GetEnum(), key)
		}
		Else
		{
			Object.__Get(this, key)
		}
	}

	; Setter
	__Set(key, num)
	{
		this.Set(key, num)
		Return
	}

	; Enumerator
	_NewEnum()
	{
		enum := this.GetEnum()
		keys := []
		For index, key In FlipArray(enum)
		{
			keys.Push(key)
		}
		Return New this.EnumOrder(enum, keys)
	}

	; Public method
	Set(key, num := "")
	{
		key := "" key
		num := num * 1
		enum := this.GetEnum()
		If (IsType(key, "Digit"))
		{
			Return False
		}
		If (num != "")
		{
			If (!IsType(num, "Digit"))
			{
				Return False
			}
			Else If (num > 0)
			{
				matchKey := InArray(enum, num)
				If (key != matchKey && matchKey)
				{
					this.Delete(matchKey)
				}
			}
		}
		Else If (enum.HasKey(key))
		{
			num := enum[key]
		}
		Else
		{
			flipped := FlipArray(enum)
			num := flipped.MaxIndex()
			num++
		}
		ObjRawSet(this, key, num)
		Return True
	}

	; Private method
	GetEnum()
	{
		enum := {}
		baseObj := ObjGetBase(this)
		ObjSetBase(this, "")
		For key, value In this
		{
			enum[key] := value
		}
		ObjSetBase(this, baseObj)
		Return enum
	}

	; Nested class
	class EnumOrder
	{
		; Variables
		array := ""
		enum := ""
		i := 0

		; Constructor
		__New(array, enum)
		{
			this.array := array
			this.enum := enum
		}

		; Enumerator
		Next(ByRef key, ByRef value := "")
		{
			this.i += 1
			If (this.i > this.enum.Count())
			{
				Return False
			}
			key := this.enum[this.i]
			value := this.array[key]
			Return True
		}
	}
}
