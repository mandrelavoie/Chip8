using System;

namespace Chip8
{
	class Stack
	{
		// Spec says that the stack is supposed to have at least 16 spots but that an implementation could choose to have more.
		private const int STACK_SIZE = 16;
		private uint16[] buffer = new .[STACK_SIZE] ~ delete _;
		private uint8 sp;

		public void Reset()
		{
			Array.Clear(this.buffer, 0, STACK_SIZE);
		}

		public void Push(uint16 val)
		{
			this.buffer[this.sp++] = val;
		}

		public uint16 Pop()
		{
			return this.buffer[--this.sp]; 
		}
	}
}
