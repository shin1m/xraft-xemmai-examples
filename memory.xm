$Memory = Object + @
	Chunk = Object + @
		$bytes
		$next
		$__initialize = @ $bytes = Bytes(1024
	$_head
	$_tail
	$_offset
	$_current0
	$_current1
	$__initialize = @
		$_head = $_tail = Chunk(
		$_offset = 0
		$rewind(
	$rewind = @
		$_current0 = $_head
		$_current1 = 0
	$read = @(buffer, offset, size)
		n = 0
		while true
			if $_current0 === $_tail
				remain = $_offset - $_current1
				if size > remain
					size = remain
				break
			remain = $_current0.bytes.size() - $_current1
			size < remain && break
			$_current0.bytes.copy($_current1, remain, buffer, offset
			$_current0 = $_current0.next
			$_current1 = 0
			n = n + remain
			offset = offset + remain
			size = size - remain
		$_current0.bytes.copy($_current1, size, buffer, offset
		$_current1 = $_current1 + size
		n + size
	$write = @(buffer, offset, size)
		n = 0
		while true
			remain = $_tail.bytes.size() - $_offset
			size < remain && break
			buffer.copy(offset, remain, $_tail.bytes, $_offset
			$_tail = $_tail.next = Chunk(
			$_offset = 0
			n = n + remain
			offset = offset + remain
			size = size - remain
		buffer.copy(offset, size, $_tail.bytes, $_offset
		$_offset = $_offset + size
		n + size
