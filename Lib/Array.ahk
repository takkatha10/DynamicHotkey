/*
	Array
	# Required files
	# Utility.ahk
	# Math.ahk
*/
; 配列要素の交換
SwapArray(ByRef array, key1, key2)
{
	If (array.HasKey(key1) && array.HasKey(key2))
	{
		temp := array[key1]
		array[key1] := array[key2]
		array[key2] := temp
	}
}

; 配列の反転
ReverseArray(ByRef array)
{
	f := array.MinIndex()
	l := array.MaxIndex()
	i := Floor(array.Length() // 2)
	Loop, % i
	{
		SwapArray(array, f, l)
		f++
		l--
	}
}

; 配列のキーと値を入れ替える
FlipArray(array)
{
	flipped := []
	For key, value In array
	{
		flipped[value] := key
	}
	Return flipped
}

; 配列内で最初に検索文字列が一致した箇所のキーを返す
InArray(array, search)
{
	For key, value In array
	{
		If (value = search)
		{
			Return key
		}
	}
	Return False
}

; 配列内で検索文字列が一致した箇所を指定回数分置き換える
ArrayReplace(ByRef array, search, replace := "", limit := -1)
{
	i := j := 0
	For key, value In array.Clone()
	{
		If (i == limit)
		{
			Break
		}
		If (value = search)
		{
			If (replace)
			{
				array[key] := replace
			}
			Else If (IsArray(array))
			{
				array.RemoveAt(key - j)
				j++
			}
			Else
			{
				array.Delete(key)
			}
			i++
		}
	}
}

; 3つの値の中央値を求める
Median3(x, y, z, comparator := "less")
{
	Return Compare(x, y, comparator) ? (Compare(y, z, comparator) ? y : (Compare(z, x, comparator) ? x : z)) : (Compare(z, y, comparator) ? y : (Compare(x, z, comparator) ? x : z))
}

; 挿入ソート
InsertionSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	i := firstKey + 1
	While (i <= lastKey)
	{
		j := i
		While (j > firstKey && Compare(array[j], array[j - 1], comparator))
		{
			SwapArray(array, j - 1, j)
			j--
		}
		i++
	}
}

; ヒープソート
HeapSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	length := lastKey - firstKey + 1
	Heapify(array, length, comparator)
	SortHeap(array, firstKey, length, comparator)
}

Heapify(ByRef array, length, comparator)
{
	i := length // 2
	While (i)
	{
		SiftDown(array, i--, length, comparator)
	}
}

SortHeap(ByRef array, firstKey, length, comparator)
{
	While (length > firstKey)
	{
		SwapArray(array, firstKey, length--)
		SiftDown(array, firstKey, length, comparator)
	}
}

SiftDown(ByRef array, r, e, comparator)
{
	While ((c := r * 2) <= e)
	{
		If (c < e && Compare(array[c], array[c + 1], comparator))
		{
			c++
		}
		If (!Compare(array[r], array[c], comparator))
		{
			Break
		}
		SwapArray(array, r, c)
		r := c
	}
}

; アップヒープ
HeapSortUp(ByRef array, firstKey, lastKey, comparator := "less")
{
	length := lastKey - firstKey + 1
	HeapifyUp(array, firstKey, length, comparator)
	SortHeap(array, firstKey, length, comparator)
}

HeapifyUp(ByRef array, firstKey, length, comparator)
{
	i := firstKey + 1
	While (i <= length)
	{
		SiftUp(array, firstKey, i++, comparator)
	}
}

SiftUp(ByRef array, r, e, comparator)
{
	While (r < e)
	{
		p := e // 2
		If (!Compare(array[p], array[e], comparator))
		{
			Break
		}
		SwapArray(array, e, p)
		e := p
	}
}

; 部分ソート
PartialSort(ByRef array, firstKey, middleKey, lastKey, comparator := "less")
{
	length := middleKey - firstKey + 1
	If (length <= 1)
	{
		Return
	}
	Heapify(array, length, comparator)
	While (middleKey++ < lastKey)
	{
		If (array[middleKey] < array[firstKey])
		{
			SwapArray(array, firstKey, middleKey)
			SiftDown(array, firstKey, length, comparator)
		}
	}
	SortHeap(array, firstKey, length, comparator)
}

; クイックソート
QuickSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	less := []
	greater := []
	ptr := 1
	less[ptr] := firstKey
	greater[ptr++] := lastKey
	While (ptr-- > 1)
	{
		firstKey := less[ptr]
		lastKey := greater[ptr]
		While (firstKey < lastKey)
		{
			pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
			i := firstKey
			j := lastKey
			Loop
			{
				While (Compare(array[i], pivot, comparator))
				{
					i++
				}
				While (Compare(pivot, array[j], comparator))
				{
					j--
				}
				If (i >= j)
				{
					Break
				}
				SwapArray(array, i, j)
				i++
				j--
			}
			If (i - firstKey < lastKey - j)
			{
				less[ptr] := j + 1
				greater[ptr++] := lastKey
				lastKey := i - 1
			}
			Else
			{
				less[ptr] := firstKey
				greater[ptr++] := i - 1
				firstKey := j + 1
			}
		}
	}
}

; イントロソート
IntroSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	depth := Floor(Log2(lastKey - firstKey + 1) * 2)
	less := []
	greater := []
	ptr := 1
	less[ptr] := firstKey
	greater[ptr++] := lastKey
	While (ptr-- > 1)
	{
		firstKey := less[ptr]
		lastKey := greater[ptr]
		While (firstKey < lastKey)
		{
			If (ptr == depth)
			{
				HeapSort(array, firstKey, lastKey, comparator)
				Break
			}
			pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
			i := firstKey
			j := lastKey
			Loop
			{
				While (Compare(array[i], pivot, comparator))
				{
					i++
				}
				While (Compare(pivot, array[j], comparator))
				{
					j--
				}
				If (i >= j)
				{
					Break
				}
				SwapArray(array, i, j)
				i++
				j--
			}
			If (i - firstKey < lastKey - j)
			{
				less[ptr] := j + 1
				greater[ptr++] := lastKey
				lastKey := i - 1
			}
			Else
			{
				less[ptr] := firstKey
				greater[ptr++] := i - 1
				firstKey := j + 1
			}
		}
	}
}

; ハイブリッドソート
Sort(ByRef array, firstKey, lastKey, comparator := "less")
{
	ThresholdedIntroSort(array, firstKey, lastKey, comparator)
	InsertionSort(array, firstKey, lastKey, comparator)
}

ThresholdedIntroSort(ByRef array, firstKey, lastKey, comparator)
{
	depth := Floor(Log2(lastKey - firstKey + 1) * 2)
	less := []
	greater := []
	ptr := 1
	less[ptr] := firstKey
	greater[ptr++] := lastKey
	While (ptr-- > 1)
	{
		firstKey := less[ptr]
		lastKey := greater[ptr]
		While (firstKey < lastKey)
		{
			If (lastKey - firstKey + 1 <= 32)
			{
				Break
			}
			If (ptr == depth)
			{
				HeapSort(array, firstKey, lastKey, comparator)
				Break
			}
			pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
			i := firstKey
			j := lastKey
			Loop
			{
				While (Compare(array[i], pivot, comparator))
				{
					i++
				}
				While (Compare(pivot, array[j], comparator))
				{
					j--
				}
				If (i >= j)
				{
					Break
				}
				SwapArray(array, i, j)
				i++
				j--
			}
			If (i - firstKey < lastKey - j)
			{
				less[ptr] := j + 1
				greater[ptr++] := lastKey
				lastKey := i - 1
			}
			Else
			{
				less[ptr] := firstKey
				greater[ptr++] := i - 1
				firstKey := j + 1
			}
		}
	}
}

; 再帰クイックソート
RecursiveQuickSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
	i := firstKey
	j := lastKey
	Loop
	{
		While (Compare(array[i], pivot, comparator))
		{
			i++
		}
		While (Compare(pivot, array[j], comparator))
		{
			j--
		}
		If (i >= j)
		{
			Break
		}
		SwapArray(array, i, j)
		i++
		j--
	}
	If (i - firstKey > 1)
	{
		RecursiveQuickSort(array, firstKey, i - 1, comparator)
	}
	If (lastKey - j > 1)
	{
		RecursiveQuickSort(array, j + 1, lastKey, comparator)
	}
}

; 再帰イントロソート
RecursiveIntroSort(ByRef array, firstKey, lastKey, depth, comparator := "less")
{
	If (depth == 0)
	{
		HeapSort(array, firstKey, lastKey, comparator)
		Return
	}
	pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
	i := firstKey
	j := lastKey
	Loop
	{
		While (Compare(array[i], pivot, comparator))
		{
			i++
		}
		While (Compare(pivot, array[j], comparator))
		{
			j--
		}
		If (i >= j)
		{
			Break
		}
		SwapArray(array, i, j)
		i++
		j--
	}
	If (i - firstKey > 1)
	{
		RecursiveIntroSort(array, firstKey, i - 1, depth - 1, comparator)
	}
	If (lastKey - j > 1)
	{
		RecursiveIntroSort(array, j + 1, lastKey, depth - 1, comparator)
	}
}

; 再帰ハイブリッドソート
RecursiveSort(ByRef array, firstKey, lastKey, comparator := "less")
{
	ThresholdedRecursiveIntroSort(array, firstKey, lastKey, Floor(Log2(lastKey - firstKey + 1) * 2), comparator)
	InsertionSort(array, firstKey, lastKey, comparator)
}

ThresholdedRecursiveIntroSort(ByRef array, firstKey, lastKey, depth, comparator)
{
	If (lastKey - firstKey + 1 <= 32)
	{
		Return
	}
	If (depth == 0)
	{
		HeapSort(array, firstKey, lastKey, comparator)
		Return
	}
	pivot := Median3(array[firstKey], array[Floor((firstKey + lastKey) // 2)], array[lastKey], comparator)
	i := firstKey
	j := lastKey
	Loop
	{
		While (Compare(array[i], pivot, comparator))
		{
			i++
		}
		While (Compare(pivot, array[j], comparator))
		{
			j--
		}
		If (i >= j)
		{
			Break
		}
		SwapArray(array, i, j)
		i++
		j--
	}
	If (i - firstKey > 1)
	{
		ThresholdedRecursiveIntroSort(array, firstKey, i - 1, depth - 1, comparator)
	}
	If (lastKey - j > 1)
	{
		ThresholdedRecursiveIntroSort(array, j + 1, lastKey, depth - 1, comparator)
	}
}
