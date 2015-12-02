$Memory = Class() :: @
	$__initialize = @
		$_head = $_tail = Bytes(1024
		$_offset = 0
		$rewind(
	$own = @
		:$^own[$](
		bytes = $_head
		while true
			bytes.own(
			break if bytes === $_tail
			bytes = bytes.next
	$share = @
		:$^share[$](
		bytes = $_head
		while true
			bytes.share(
			break if bytes === $_tail
			bytes = bytes.next
	$rewind = @
		$_current0 = $_head
		$_current1 = 0
	$read = @(buffer, offset, size)
		n = 0
		while true
			if $_current0 === $_tail
				remain = $_offset - $_current1
				size = remain if size > remain
				break
			remain = $_current0.size() - $_current1
			break if size < remain
			$_current0.copy($_current1, remain, buffer, offset
			$_current0 = $_current0.next
			$_current1 = 0
			n = n + remain
			offset = offset + remain
			size = size - remain
		$_current0.copy($_current1, size, buffer, offset
		$_current1 = $_current1 + size
		n + size
	$write = @(buffer, offset, size)
		n = 0
		while true
			remain = $_tail.size() - $_offset
			break if size < remain
			buffer.copy(offset, remain, $_tail, $_offset
			$_tail = $_tail.next = Bytes(1024
			$_offset = 0
			n = n + remain
			offset = offset + remain
			size = size - remain
		buffer.copy(offset, size, $_tail, $_offset
		$_offset = $_offset + size
		n + size
