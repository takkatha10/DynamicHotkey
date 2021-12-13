/*
	Array
*/
; オブジェクトが配列かどうかをチェックする
IsArray(obj)
{
    Return obj.SetCapacity(0) == (obj.MaxIndex() - obj.MinIndex() + 1)
}

; オブジェクトが連想配列かどうかをチェックする
IsAssociative(obj)
{
    Return !obj.MaxIndex() ? True : False
}

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

; 配列内で最初に検索文字列が完全一致した箇所のキーを返す
InArray(array, search)
{
    For key, value In array
    {
        If (value == search)
        {
            Return key
        }
    }
    Return False
}

; 配列内で検索文字列が完全一致した箇所を指定回数分置き換える
ArrayReplace(ByRef array, search, replace := "", limit := -1)
{
    i := j := 0
    For key, value In array.Clone()
    {
        If (i == limit)
        {
            Break
        }
        If (value == search)
        {
            If (replace)
            {
                array[key] := replace
            }
            Else If (IsAssociative(array))
            {
                array.Delete(key)
            }
            Else
            {
                array.RemoveAt(key - j)
                j++
            }
            i++
        }
    }
}

; 配列のソート
SortArray(ByRef array, order := "A")
{
    maxIndex := array.MaxIndex()
    If (order = "R")
    {
        i := 0
        Loop, % maxIndex
        {
            array.Push(array.RemoveAt(maxIndex - i++))
        }
    }
    Else
    {
        partitions := "|" array.MinIndex() "," maxIndex
        While (partitions)
        {
            partition := SubStr(partitions, InStr(partitions, "|", False, 0) + 1)
            comma := InStr(partition, ",")
            sPos := pivot := SubStr(partition, 1, comma - 1)
            ePos := SubStr(partition, comma + 1) 
            If (order = "A")
            { 
                Loop, % ePos - sPos
                {
                    If (array[pivot] > array[A_Index + sPos])
                    {
                        array.InsertAt(pivot++, array.RemoveAt(A_Index + sPos))
                    }
                }
            }
            Else If (order = "D")
            {
                Loop, % ePos - sPos
                {
                    If (array[pivot] < array[A_Index + sPos])
                    {
                        array.InsertAt(pivot++, array.RemoveAt(A_Index + sPos))
                    }
                }
            }
            Else
            {
                Break
            }
            partitions := SubStr(partitions, 1, InStr(partitions, "|", False, 0) - 1)
            If ((pivot - sPos) > 1)
            {
                partitions .= "|" sPos "," pivot - 1
            }
            If ((ePos - pivot) > 1)
            {
                partitions .= "|" pivot + 1 "," ePos
            }
        }
    }
}
